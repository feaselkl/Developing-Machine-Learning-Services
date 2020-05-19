# sqlmlutils installation instructions at https://docs.microsoft.com/en-us/sql/advanced-analytics/package-management/install-additional-r-packages-on-sql-server?view=sql-server-2017
# sqlmlutils details at https://github.com/microsoft/sqlmlutils/tree/master/R

# Step 1, installation:
if (!require(RODBCext))
{
  install.packages("RODBCext", repos = "https://cran.microsoft.com")
}
if (!require(sqlmlutils))
{
  # If this fails, check to see if the package version has updated.
  # https://github.com/microsoft/sqlmlutils/tree/master/R/dist
  install.packages("https://github.com/microsoft/sqlmlutils/raw/master/R/dist/sqlmlutils_0.7.1.tar.gz", repos = NULL)
  library(sqlmlutils)
}


# NOTE:  need to do this for *each* database!
db_connection <- connectionInfo(driver = "ODBC Driver 17 for SQL Server", server = "localhost", database = "ExpenseReports")

# Install one package.
sql_install.packages(
  connectionString = db_connection,
  pkgs = "tidyverse",
  scope = "PUBLIC",
  verbose = TRUE,
  repos = "https://cran.microsoft.com"
)
# Install multiple packages.
sql_install.packages(
  connectionString = db_connection,
  pkgs = c("forecast", "wkb", "data.table", "zoo", "xgboost"),
  scope = "PUBLIC",
  verbose = TRUE,
  repos = "https://cran.microsoft.com"
)

# This is a "safe," rerunnable installation.
sql_install.packages(
  connectionString = db_connection,
  pkgs = c("forecast", "wkb", "data.table", "zoo", "xgboost"),
  scope = "PUBLIC",
  verbose = TRUE
)

# Remove packages
# Watch how packages which are dependencies (like zoo) don't actually get removed.
sql_remove.packages(
  connectionString = db_connection,
  pkgs = c("zoo", "wkb"),
  scope = "PUBLIC",
  verbose = TRUE
)

# Review packages which we have already installed
r <- sql_installed.packages(connectionString = db_connection, fields=c("Package", "Version", "LibPath", "Attributes", "Scope"))
View(r)

# This works for custom packages as well.
# Note:  this will give you an error unless you actually have the package available.
if (1=2) {
  sql_install.packages(
    connectionString = db_connection,
    pkgs = "C:/SourceCode/Developing-Machine-Learning-Services/packages/ExpenseReportsR_0.1.0.zip",
    verbose = TRUE,
    scope = "PUBLIC",
    repos = NULL
  )
  sql_remove.packages(
    connectionString = db_connection,
    pkgs = "ForensicAccountingR",
    dependencies = FALSE,
    checkReferences = TRUE,
    scope = "PUBLIC",
    verbose = TRUE
  )
}
