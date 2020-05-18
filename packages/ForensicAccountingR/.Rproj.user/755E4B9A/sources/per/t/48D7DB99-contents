GenerateLinearPredictions <- function(inputDataSet, serializedModel) {
  #Before using the model to predict, we need to unserialize it
  model <- unserialize(serializedModel);
  rxPredict(modelObject = model, data = inputDataSet);
}

GenerateXgBoostPredictions <- function(inputDataSet, serializedModel) {
  require("xgboost");
  require("data.table");

  model <- unserialize(serializedModel)
  data <- as.matrix(ExpenseData[, c("ExpenseYear", "ExpenseCategoryID")])
  predict(model, data)
}

#The InputDataSet contains the new data passed to this stored proc. We will use this data to predict.
GeneratePredictions <- function(inputDataSet, modelType, serializedModel) {
  require("RevoScaleR");
  modelType <- tolower(modelType)

  if (modelType == "linear") {
    pred <- GenerateLinearPredictions(inputDataSet, serializedModel)
  }
  else if (modelType == "xgboost") {
    pred <- GenerateXgBoostPredictions(inputDataSet, serializedModel)
  }
  else {
    msg <- "modelType must be either 'linear' or 'xgboost'.  You passed in '" + modelType + "' instead."
    stop(msg)
  }

  cbind(inputDataSet, pred)
}
