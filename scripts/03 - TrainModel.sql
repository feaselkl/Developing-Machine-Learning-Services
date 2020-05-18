USE [ExpenseReports]
GO
CREATE OR ALTER PROCEDURE dbo.ExpenseReports_TrainModelML
(
@language NVARCHAR(128),
@modelType NVARCHAR(30),
@trainedModel VARBINARY(MAX) OUTPUT
)
AS
BEGIN
	DECLARE
		@sql NVARCHAR(MAX),
		@remoteCommand NVARCHAR(MAX);

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
		er.ExpenseDate < ''2017-01-01'';';

	IF (@language = N'R')
	BEGIN
		SET @remoteCommand = N'
		require("ForensicAccountingR");
		trained_model <- ForensicAccountingR::TrainModel(ExpenseData, "{0}");
		';
		SET @remoteCommand = REPLACE(@remoteCommand, N'{0}', @modelType);
	END
	ELSE
	BEGIN
		-- Note that Python is whitespace-sensitive, so we don't want to mess with the alignment.
		SET @remoteCommand = N'
import pickle 
from sklearn.ensemble import RandomForestRegressor
clf = RandomForestRegressor() 
trained_model = pickle.dumps(clf.fit(ExpenseData[["ExpenseCategoryID", "ExpenseYear"]], ExpenseData[["Amount"]].values.ravel())) 
';
	END

	EXEC sp_execute_external_script
		@language = @language,
		@script = @remoteCommand,
		@input_data_1 = @sql,
		@input_data_1_name = N'ExpenseData',
		@params = N'@trained_model varbinary(max) OUTPUT',
		@trained_model = @trainedModel OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE dbo.ExpenseReports_TrainModel
(
@language NVARCHAR(128),
@modelType NVARCHAR(30)
)
AS
BEGIN
	DECLARE
		@trainedModel VARBINARY(MAX);

	EXEC dbo.ExpenseReports_TrainModelML
		@language = @language,
		@modelType = @modelType,
		@trainedModel = @trainedModel OUTPUT;

	INSERT INTO dbo.Model
	(
		ModelLanguage,
		ModelType,
		Model,
		IsNativeScored
	)
	VALUES
	(
		@language,
		@modelType,
		@trainedModel,
		0
	);
END
GO

-- Clear out any existing models.
TRUNCATE TABLE dbo.Model;

-- Load up the three models we want to use.
EXEC dbo.ExpenseReports_TrainModel
	@language = N'R',
	@modelType = N'linear';
EXEC dbo.ExpenseReports_TrainModel
	@language = N'R',
	@modelType = N'xgboost';
EXEC dbo.ExpenseReports_TrainModel
	@language = N'Python',
	@modelType = N'RandomForestRegression';
GO
