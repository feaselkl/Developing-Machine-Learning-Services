# pip install sqlmlutils

import sqlmlutils
from sqlmlutils.packagemanagement.scope import Scope

# Connect to the Database
conn = sqlmlutils.ConnectionInfo(server="localhost", database="ExpenseReports")
sqlpy = sqlmlutils.SQLPythonExecutor(conn)
pkgmanager = sqlmlutils.SQLPackageManager(conn)
# Install a package as dbo, allowing anybody to use it.
# Upgrade if there is a newer version than what is already installed.
pkgmanager.install("werkzeug", upgrade = True, scope = Scope.public_scope())
# By default, install just for your account if you are not a sysadmin.
# You can also specify a private scope.
pkgmanager.install("termcolor")

# We can also install and uninstall our own custom packages.
#pkgmanager.uninstall("my_custom_package", scope = Scope.public_scope())
#pkgmanager.install(package = "C:\\Temp\\MyCustomPackage\\dist\\my_custom_package-0.0.1-py3-none-any.whl", scope = Scope.public_scope())
