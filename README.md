# Developing a Solution with SQL Server Machine Learning Services

This repository provides the supporting code for my presentation entitled [Developing a Solution with SQL Server Machine Learning Services](http://www.catallaxyservices.com/presentations/developing-machine-learning-services/).

## Prerequisites

On your local machine, you will need an installation of [R](https://www.r-project.org/).  I highly recommend installing [RStudio](https://rstudio.com), as well as the appropriate version of [Rtools](https://cran.r-project.org/bin/windows/Rtools/history.html) in order to build the Expense Reports source package.  In the event that you are unable to build the package, I did include a pre-built version in the repository.  For SQL Server 2019, the version of Rtools you will need is Rtools35.exe.  This may change for future versions of SQL Server.

In order to follow along with the script `01 - sqlmlutils.py`, you will need an installation of Python with pip installed.  I recommend the [Anaconda distribution](https://www.anaconda.com/products/individual).  Note that this is not strictly necessary for the demo, as we do not build and use a Python package, and the package we load (sklearn) is pre-installed with Machine Learning Services.

## Running the Code

There are **two** ways that you can get the demos working.  We will take each in turn.

### Run Docker Image

If you have Docker installed on your machine, you can grab the image from [Docker Hub](https://hub.docker.com/repository/docker/feaselkl/presentations).  Run the following commands to pull the Docker image and then start up a container running SQL Server with the `ExpenseReports` database pre-created.

```
docker pull docker.io/feaselkl/presentations:developing-ml-services-db
docker run --name developing-ml-services-db -p 52433:1433 docker.io/feaselkl/presentations:developing-ml-services-db
```

The first step is to run through the steps in `00 - sqlmlutils.R`.  You will need to run through steps 1, 2, and 4 and may go through step 3 as well, although I have pre-installed packages for you as a time-saving measure.  Note that to run step 2, you *will* need to uncomment one of the `db_connection` assignments and ensure that it is correct for your setup (e.g., changing the port or changing the username + password if you are using SQL authentication).

The `01 - sqlmlutils.py` script is for your reference and is not necessary to follow along with the demo.

After installing the Expense Reports R package, connect to `localhost,52433` from SQL Server Management Studio or Azure Data Studio and start running the SQL Scripts in the `scripts` directory starting from `02 - BasicResearch.sql`.

At the end, you will not need to run script `99 - Cleanup.sql` because you can stop and delete the container:

```
docker stop developing-ml-services-db
docker rm developing-ml-services-db
```

### Run Locally on SQL Server

If you would like to run the scripts but do not have Docker installed, restore the database named `ExpenseReports` from `data\ExpenseReports.bak`.  This does require SQL Server 2019 or later.

The next step is to run through the steps in `00 - sqlmlutils.R`.  You will need to run through each step in turn.  Note that to run step 2, you *will* need to uncomment one of the `db_connection` assignments and ensure that it is correct for your setup (e.g., changing the port or changing the username + password if you are using SQL authentication).

The `01 - sqlmlutils.py` script is for your reference and is not necessary to follow along with the demo.

After installing the Expense Reports R package, connect to `localhost,52433` from SQL Server Management Studio or Azure Data Studio and start running the SQL Scripts in the `scripts` directory starting from `02 - BasicResearch.sql`.

The script `99 - Cleanup.sql` allows you to re-run the scripts later, which is handy when presenting this session multiple times!