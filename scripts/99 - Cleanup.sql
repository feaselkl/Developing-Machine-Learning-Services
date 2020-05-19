USE [ExpenseReports]
GO
DROP PROCEDURE IF EXISTS dbo.ExpenseReports_TrainModel;
DROP PROCEDURE IF EXISTS dbo.ExpenseReports_TrainModelML;
DROP PROCEDURE IF EXISTS dbo.ExpenseReports_GeneratePredictions;
DROP PROCEDURE IF EXISTS dbo.ExpenseReports_GeneratePredictionsML;
TRUNCATE TABLE dbo.Model;