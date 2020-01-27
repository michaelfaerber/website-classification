#Funktion für xgboost Klassifikator

# INPUT: Data for Train / Val / test, Parameters

master$fn_xgboost <- function(tvt_data, maxdepth = 6, gamma = 2, nround = 400, earlystop = 15, globalSeed = 1337) {
  require(tictoc)
  require(caret)
  require(xgboost)
  # Train Model
  tic()
  set.seed(globalSeed)
  xg_model <- xgboost(data = tvt_data[[1]], # the data  
                      label = tvt_data[[4]],
                      booster = "gblinear", 
                      num_class = 4, 
                      nround = nround,
                      objective = "multi:softmax",
                      max.depth = maxdepth, # default is 6
                      gamma = gamma, # Regularization against Overfitting
                      early_stopping_rounds = earlystop)
  traintime <- toc()
  
  # Model validation
  tic()
  Prediction_Val  <- predict(xg_model, as.matrix(tvt_data[[2]]))
  valtime <- toc()
  
  tic()
  Prediction_Test <- predict(xg_model, as.matrix(tvt_data[[3]]))
  testtime <- toc()
  
  # Metriken aus caret Package:
  cfm_val  <- caret::confusionMatrix(as.factor(Prediction_Val)  ,as.factor(tvt_data[[5]]))
  cfm_test <- caret::confusionMatrix(as.factor(Prediction_Test) ,as.factor(tvt_data[[6]]))
  cfm_val_plot <- bs$ggplotConfusionMatrix(cfm_val)
  cfm_test_plot <- bs$ggplotConfusionMatrix(cfm_test)
  
  #Return: Confusionmatrices, Plots, Executiontimes
  return(
    list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, unname(traintime$toc - traintime$tic), unname(valtime$toc - valtime$tic), unname(testtime$toc - testtime$tic))
    
  )
}


