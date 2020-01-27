# Funktion für SVM 1vsRest

master$fn_svm_1vR <- function(tvt_data, cost = 200, globalSeed = 1337) {
  require(tictoc)
  require(caret)
  require(e1071)
  
  tic()
    set.seed(globalSeed)
    model_svm_num <- bsmodel$svm_ovr_num(traindata = tvt_data[[1]], 
                                 target = tvt_data[[4]], 
                                 costVal = cost)
  traintime <- toc()
  
  # Model validation
  tic()
    Prediction_Val  <- bsmodel$svm_eval_num(model_svm_num, tvt_data[[2]])
  valtime <- toc()
  
  tic()
    Prediction_Test  <- bsmodel$svm_eval_num(model_svm_num, tvt_data[[3]])
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
