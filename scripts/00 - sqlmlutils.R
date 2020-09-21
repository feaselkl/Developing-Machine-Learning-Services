# sqlmlutils installation instructions at https://docs.microsoft.com/en-us/sql/advanced-analytics/package-management/install-additional-r-packages-on-sql-server?view=sql-server-2017
# sqlmlutils details at https://github.com/microsoft/sqlmlutils/tree/master/R

# Step 1, installation:
if (!require(RODBCext))
{
  # Note that RODBCext is deprecated, but sqlmlutils currently uses it.
  # https://github.com/microsoft/sqlmlutils/pull/62
  install.packages("RODBCext", repos="https://mran.microsoft.com/snapshot/2019-02-01/")
}
if (!require(sqlmlutils))
{
  # If this fails, check to see if the package version has updated.
  # https://github.com/microsoft/sqlmlutils/tree/master/R/dist
  install.packages("https://github.com/microsoft/sqlmlutils/raw/master/R/dist/sqlmlutils_0.7.1.tar.gz", repos = NULL)
  library(sqlmlutils)
}

# Step 2, selecting a database connection:
# NOTE:  need to do this for *each* database!
# Uncomment this version if you want to connect to a Docker container.
#db_connection <- connectionInfo(driver = "ODBC Driver 17 for SQL Server", server = "localhost,52433", database = "ExpenseReports", uid="sa", pwd="SomeBadP@ssword3")
# Uncomment this version if you want to connect to a local installation of SQL Server 2019.
db_connection <- connectionInfo(driver = "ODBC Driver 17 for SQL Server", server = "localhost", database = "ExpenseReports")

# Step 3, installing and removing packages:
# NOTE:  this installation can be *very* slow in a Docker container.  For that reason, I have
# pre-installed them.  You might otherwise be waiting hours for tidyverse to finish installing
# (if it ever does...).
# Install one package.
sql_install.packages(
  connectionString = db_connection,
  pkgs = c("data.table"),
  scope = "PUBLIC",
  verbose = TRUE,
  repos = "https://cran.case.edu/"
)

# Install multiple packages.
# If you get an error here, you might need to install a couple of packages on your Linux container.
# apt-get install zlib1g-dev libicu-dev g++
sql_install.packages(
  connectionString = db_connection,
  pkgs = c("magrittr", "stringi", "xgboost"),
  scope = "PUBLIC",
  verbose = TRUE,
  repos = "https://cran.case.edu/"
)

# This is a "safe," rerunnable installation.
sql_install.packages(
  connectionString = db_connection,
  pkgs = c("xgboost"),
  scope = "PUBLIC",
  verbose = TRUE,
  repos = "https://cran.case.edu/"
)

# Remove packages
# Note that if you try to remove a package which another package depends upon,
# this won't let you remove the package.
sql_remove.packages(
  connectionString = db_connection,
  pkgs = c("stringi"),
  scope = "PUBLIC",
  verbose = TRUE
)

# Review packages which we have already installed
r <- sql_installed.packages(connectionString = db_connection, fields=c("Package", "Version", "LibPath", "Attributes", "Scope"))
View(r)

# Step 4:  installing the Expense Reports R package.
# This works for custom packages as well.
# Note:  this will give you an error unless you actually have the package available.
if (1=2) {
  # When you do try to install this, make sure you change this line to set the appropriate package location!
  sql_install.packages(
    connectionString = db_connection,
    pkgs = "C:/SourceCode/Developing-Machine-Learning-Services/packages/ExpenseReportsR_0.1.0.zip",
    verbose = TRUE,
    scope = "PUBLIC",
    repos = NULL
  )
  sql_remove.packages(
    connectionString = db_connection,
    pkgs = "ExpenseReportsR",
    dependencies = FALSE,
    checkReferences = TRUE,
    scope = "PUBLIC",
    verbose = TRUE
  )
}
