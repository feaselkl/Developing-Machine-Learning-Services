USE [ExpenseReports]
GO
-- Means haven't changed much, though they are a little higher.
SELECT
	c.CalendarYear,
	COUNT(*) as N,
	SUM(Amount) AS Total,
	AVG(Amount) AS Mean
FROM dbo.ExpenseReport ed
	INNER JOIN dbo.Calendar c
		ON ed.ExpenseDate= c.Date
GROUP BY
	c.CalendarYear
ORDER BY
	c.CalendarYear;

-- We can see a major change in mean from 2016 to 2017 for inexpensive cities.
-- The others appear not to have changed much.
SELECT
	c.CalendarYear,
	ed.ExpenseCategoryID,
	COUNT(*) as N,
	SUM(Amount) AS Total,
	AVG(Amount) AS Mean
FROM dbo.ExpenseReport ed
	INNER JOIN dbo.Calendar c
		ON ed.ExpenseDate= c.Date
GROUP BY
	c.CalendarYear,
	ed.ExpenseCategoryID
ORDER BY
	ed.ExpenseCategoryID,
	c.CalendarYear;