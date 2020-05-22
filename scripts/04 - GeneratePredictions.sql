USE [ExpenseReports]
GO
CREATE OR ALTER PROCEDURE dbo.ExpenseReports_GeneratePredictionsML
(
@language NVARCHAR(128),
@modelType NVARCHAR(30)
)
AS
BEGIN
	DECLARE
		@sql NVARCHAR(MAX),
		@remoteCommand NVARCHAR(MAX),
		@trainedModel VARBINARY(MAX);

	SET @sql = N'
	SELECT
		er.EmployeeID,
		CONCAT(e.FirstName, '' '', e.LastName) AS EmployeeName,
		ec.ExpenseCategoryID,
		ec.ExpenseCategory,
		er.ExpenseDate,
		YEAR(er.ExpenseDate) AS ExpenseYear,
		-- Python requires FLOAT values--it does not support DECIMAL
		CAST(er.Amount AS FLOAT) AS Amount
	FROM dbo.ExpenseReport er
		INNER JOIN dbo.ExpenseCategory ec
			ON er.ExpenseCategoryID = ec.ExpenseCategoryID
		INNER JOIN dbo.Employee e
			ON e.EmployeeID = er.EmployeeID
	WHERE
		er.ExpenseDate >= ''2017-01-01'';';

	SELECT
		@trainedModel = model
	FROM dbo.Model
	WHERE
		ModelLanguage = @language
		AND ModelType = @modelType
		AND IsNativeScored = 0;

	IF (@language = N'R')
	BEGIN
		SET @remoteCommand = N'
		require("ExpenseReportsR");
		OutputDataSet <- ExpenseReportsR::GeneratePredictions(ExpenseData, "{0}", trained_model);
		';
		SET @remoteCommand = REPLACE(@remoteCommand, N'{0}', @modelType);
	END
	ELSE
	BEGIN
		-- Note that Python is whitespace-sensitive, so we don't want to mess with the alignment.
		SET @remoteCommand = N'
import pickle
import pandas as pd
model = pickle.loads(trained_model)
pred = pd.DataFrame({"AmountPrediction" : model.predict(ExpenseData[["ExpenseCategoryID", "ExpenseYear"]]) })
OutputDataSet = pd.concat([ExpenseData, pred], axis=1)
';
	END

	EXEC sp_execute_external_script
		@language = @language,
		@script = @remoteCommand,
		@input_data_1 = @sql,
		@input_data_1_name = N'ExpenseData',
		@params = N'@trained_model varbinary(max)',
		-- My naming may seem a little weird, so I wanted to call it out here in a comment.
		-- I want to show that the internal parameter (trained_model) does not need to have
		-- the same name as the output variable (trainedModel). In practice, it makes sense
		-- to keep these the same unless you have a good reason not to.
		@trained_model = @trainedModel
	WITH RESULT SETS
	((
		EmployeeID INT,
		EmployeeName VARCHAR(101),
		ExpenseCategoryID TINYINT,
		ExpenseCategory VARCHAR(30),
		ExpenseDate DATE,
		ExpenseYear INT,
		Amount DECIMAL(5,2),
		AmountPrediction FLOAT
	));
END
GO

CREATE OR ALTER PROCEDURE dbo.ExpenseReports_GeneratePredictions
(
@language NVARCHAR(128),
@modelType NVARCHAR(30)
)
AS
BEGIN
	DROP TABLE IF EXISTS #Predictions;
	CREATE TABLE #Predictions
	(	
		EmployeeID INT,
		EmployeeName VARCHAR(101),
		ExpenseCategoryID TINYINT,
		ExpenseCategory VARCHAR(30),
		ExpenseDate DATE,
		ExpenseYear INT,
		Amount FLOAT,
		AmountPrediction FLOAT
	);


	INSERT INTO #Predictions
	(
		EmployeeID,
		EmployeeName,
		ExpenseCategoryID,
		ExpenseCategory,
		ExpenseDate,
		ExpenseYear,
		Amount,
		AmountPrediction
	)
	EXEC dbo.ExpenseReports_GeneratePredictionsML
		@language = @language,
		@modelType = @modelType;

	SELECT
		p.EmployeeName,
		p.ExpenseCategory,
		COUNT(*) AS NumberOfExpenseReports,
		SUM(c.Amount) as Total,
		SUM(c.AmountPredicted) as TotalPredicted,
		CAST(ABS(SUM(c.AmountPredicted) - SUM(c.Amount)) / COUNT(*) AS DECIMAL(7,2)) AS MAE,
		CAST(100.0 * SUM(c.Amount - c.AmountPredicted) / SUM(c.Amount) AS DECIMAL(7,2)) AS MAPE
	FROM #Predictions p
		CROSS APPLY
		(
			SELECT
				CAST(p.Amount AS DECIMAL(5,2)) AS Amount,
				CAST(AmountPrediction AS DECIMAL(5,2)) AS AmountPredicted
		) c
	GROUP BY
		p.EmployeeName,
		p.ExpenseCategory
	ORDER BY
		p.EmployeeName,
		p.ExpenseCategory;
END
GO


EXEC dbo.ExpenseReports_GeneratePredictions
	@language = N'R',
	@modelType = N'xgboost';
EXEC dbo.ExpenseReports_GeneratePredictions
	@language = N'R',
	@modelType = N'linear';
EXEC dbo.ExpenseReports_GeneratePredictions
	@language = N'Python',
	@modelType = N'RandomForestRegression';