#Funktion für Naive Bayes Klassifikator

# INPUT: Data for Train / Val / test, no Parameters

master$fn_naivebayes <- function(tvt_data, globalSeed = 1337) {
  require(tictoc)
  require(caret)
  require(e1071)
  
  # Train Model
  tic()
  set.seed(globalSeed)
  Naive_Bayes_Model=naiveBayes(x= as.data.frame(as.matrix(tvt_data[[1]])) , y = as.factor(tvt_data[[4]]))
  traintime <- toc()
  
  # Model validation
  tic()
  Prediction_Val  <- predict(Naive_Bayes_Model, as.data.frame(as.matrix(tvt_data[[2]])))
  valtime <- toc()
  
  tic()
  Prediction_Test <- predict(Naive_Bayes_Model, as.data.frame(as.matrix(tvt_data[[3]])))
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
