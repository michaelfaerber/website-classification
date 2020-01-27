# Funktion für SVM mit 1v1

master$fn_svm_1v1 <- function(tvt_data, cost = 200, globalSeed = 1337) {
  require(tictoc)
  require(caret)
  require(e1071)
  # Train Model
  tic()
  set.seed(globalSeed)
  model_svm <- svm(x = tvt_data[[1]], 
                   y = as.factor(tvt_data[[4]]), 
                   kernel = "linear", 
                   cost=cost,
                  type = 'C-classification')
  traintime <- toc()
  summary(model_svm)
  
  # Model validation
  tic()
    Prediction_Val  <- predict(model_svm, as.matrix(tvt_data[[2]]))
  valtime <- toc()
  
  tic()
    Prediction_Test <- predict(model_svm, as.matrix(tvt_data[[3]]))
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
