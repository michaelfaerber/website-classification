# Function für RandomForests 


master$fn_rndForest <- function(tvt_data, ntree = 750, mtry = 150, globalSeed = 1337) {
  require(tictoc)
  require(caret)
  require(randomForest)

  # Train Model
  tic()
  set.seed(globalSeed)
    rf_model_t2v <- randomForest(x = as.matrix(tvt_data[[1]]), 
                                 y = as.factor(as.factor(tvt_data[[4]])) , 
                                 ntree = ntree, 
                                 mtry = mtry, 
                                 importance = TRUE,
                                 do.trace = TRUE )
    traintime <- toc()
    rf_model_t2v
  
  # Model validation
  tic()
  Prediction_Val  <- predict(rf_model_t2v, as.matrix(tvt_data[[2]]), type = "class")
  valtime <- toc()
  
  tic()
  Prediction_Test <- predict(rf_model_t2v, as.matrix(tvt_data[[3]]), type = "class")
  testtime <- toc()
  
  # Metriken aus caret Package:
  cfm_val  <- caret::confusionMatrix(as.factor(Prediction_Val)  ,as.factor(tvt_data[[5]]))
  cfm_test <- caret::confusionMatrix(as.factor(Prediction_Test) ,as.factor(tvt_data[[6]]))
  cfm_val_plot <- bs$ggplotConfusionMatrix(cfm_val)
  cfm_test_plot <- bs$ggplotConfusionMatrix(cfm_test)
  
  #Return: Confusionmatrices, Plots, Executiontimes
  return(
    # list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, traintime, valtime, testtime)
    list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, unname(traintime$toc - traintime$tic), unname(valtime$toc - valtime$tic), unname(testtime$toc - testtime$tic))
    
  )
}
