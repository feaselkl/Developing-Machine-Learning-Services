TrainLinearModel <- function(inputDataSet) {
  rxLinMod(Amount ~ ExpenseYear + ExpenseCategory, data = inputDataSet);
}

TrainXgBoostModel <- function(inputDataSet) {
  require("xgboost");
  require("data.table");

  label <- inputDataSet$Amount
  data <- as.matrix(inputDataSet[, c("ExpenseYear", "ExpenseCategoryID")])
  xgboost(data = data, label = label, max.depth = 4, nrounds = 6, objective="reg:squarederror");
}

#The InputDataSet contains the training data passed in from a stored procedure.
# modelType must be one of "linear" or "xgboost" or else we return an error.
TrainModel <- function(inputDataSet, modelType) {
  require("RevoScaleR");
  modelType <- tolower(modelType)

  if (modelType == "linear") {
    model <- TrainLinearModel(inputDataSet)
  }
  else if (modelType == "xgboost") {
    model <- TrainXgBoostModel(inputDataSet)
  }
  else {
    msg <- "modelType must be either 'linear' or 'xgboost'.  You passed in '" + modelType + "' instead."
    stop(msg)
  }

  # Before saving the model, we need to serialize it.
  trained_model <- as.raw(serialize(model, connection=NULL));
  trained_model
}

