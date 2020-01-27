# functions für Multilayer perceptron
# unterscheidliche Konfigurationen werden getestet!


master$fn_mlp_1 <- function(tvt_data, ModelNr, epochs = 10, batchSize = 32, globalSeed = 1337, Threshold = 0) {
  require(keras)
  require(tictoc)
  require(caret)
  globalSeed = globalSeed
  # Prepare Data
  # One-hot-encoding for Targetlabels
  Labels_mlp_train  <- to_categorical(tvt_data[[4]])
  Labels_mlp_val    <- to_categorical(tvt_data[[5]])
  Labels_mlp_test   <- to_categorical(tvt_data[[6]])
  
    #########  Train Model  #########
  tic()
  # Create a Model
  mlp_model <- master$get_keras_model(ModelNr, length(tvt_data[[1]]@p)-1 ) 
  summary(mlp_model)
  
  # Compile Model
  mlp_model %>% keras::compile(loss = 'categorical_crossentropy',
                        optimizer = 'adam',
                        metrics = 'accuracy')

  # Fit model
  history <- mlp_model %>% keras::fit(tvt_data[[1]], 
                                      Labels_mlp_train,
                                      epoch = epochs,
                                      batch_size = batchSize,
                                      validation_split = 0.2)
                                      # validation_data  = list(tvt_data[[2]], Labels_mlp_val)  )
  traintime <- toc()
  
  
  ######### Evaluate #########
  # Model validation
  # tic()
  # Prediction_Val  <- mlp_model %>% predict_classes(tvt_data[[2]])
  # valtime <- toc()
  # 
  # tic()
  # Prediction_Test <- mlp_model %>% predict_classes(tvt_data[[3]])
  # testtime <- toc()
  tic()
  Prediction_Val  <- as.data.frame(predict(mlp_model, tvt_data[[2]]))
  colnames(Prediction_Val) <- c(0,1,2,3)
  Eval_Val <- as.factor(colnames(Prediction_Val)[apply(Prediction_Val,1,which.max)])
  colnames(Prediction_Val) <- c('V1','V2','V3','V4')
  valtime <- toc()
  
  val_DF <- cbind(Prediction_Val, Eval_Val, label =  as.factor(tvt_data[[5]])) %>% 
    mutate(threshold = pmax(V1,V2,V3,V4))
  val_DF_full <- val_DF #Wird für Grafiken zur Abwägung des Thrsholds an Return übergeben
  val_DF <- val_DF %>% filter(threshold >= Threshold)
  colnames(val_DF) <- c(0,1,2,3, 'Eval_Val', 'label')
  colnames(val_DF_full) <- c(0,1,2,3, 'Eval_Val', 'label')
  
  tic()
  Prediction_Test <- as.data.frame(predict(mlp_model, tvt_data[[3]]))
  colnames(Prediction_Test) <- c(0,1,2,3)
  Eval_Test <- as.factor(colnames(Prediction_Test)[apply(Prediction_Test,1,which.max)])
  colnames(Prediction_Test) <- c('V1','V2','V3','V4')
  testtime <- toc()
  
  test_DF <- cbind(Prediction_Test, Eval_Test, label =  as.factor(tvt_data[[6]])) %>% 
    mutate(threshold = pmax(V1,V2,V3,V4)) 
  test_DF_full <- test_DF #Wird für Grafiken zur Abwägung des Thrsholds an Return übergeben
  test_DF <- test_DF %>% filter(threshold >= Threshold)
  colnames(test_DF) <- c(0,1,2,3, 'Eval_Test', 'label')
  colnames(test_DF_full) <- c(0,1,2,3, 'Eval_Test', 'label')
  # Metriken aus caret Package:
  # cfm_val  <- caret::confusionMatrix(as.factor(Prediction_Val)  ,as.factor(tvt_data[[5]]))
  # cfm_test <- caret::confusionMatrix(as.factor(Prediction_Test) ,as.factor(tvt_data[[6]]))
  # cfm_val_plot <- bs$ggplotConfusionMatrix(cfm_val)
  # cfm_test_plot <- bs$ggplotConfusionMatrix(cfm_test)
  cfm_val  <- caret::confusionMatrix(as.factor(val_DF$Eval_Val  ) ,as.factor(val_DF$label ))
  cfm_test <- caret::confusionMatrix(as.factor(test_DF$Eval_Test) ,as.factor(test_DF$label))
  cfm_val_plot  <- bs$ggplotConfusionMatrix(cfm_val)
  cfm_test_plot <- bs$ggplotConfusionMatrix(cfm_test)
  
  #Return: Confusionmatrices, Plots, Executiontimes
  return(
    # list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, traintime, valtime, testtime)
    # list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, unname(traintime$toc - traintime$tic), unname(valtime$toc - valtime$tic), unname(testtime$toc - testtime$tic))
    list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, unname(traintime$toc - traintime$tic), unname(valtime$toc - valtime$tic), unname(testtime$toc - testtime$tic), val_DF_full, test_DF_full )
    
  )
  
}


master$get_keras_model <- function(modelNr, inputshape){
  if(modelNr == 1){
    mlp_model <- keras_model_sequential()
    mlp_model %>% 
      layer_dense(units = 10, activation = 'sigmoid', input_shape = inputshape) %>%
      layer_dense(units = 10, activation = 'sigmoid') %>% 
      layer_dense(units = 4, activation  = 'softmax')
  
  } else if(modelNr == 2) {
    mlp_model <- keras_model_sequential()
    mlp_model %>% 
      layer_dense(units = 30, activation = 'sigmoid', input_shape = inputshape) %>%
      layer_dense(units = 15, activation = 'sigmoid') %>% 
      layer_dense(units = 4, activation  = 'softmax')
    
  } else if(modelNr == 3) {
    mlp_model <- keras_model_sequential()
    mlp_model %>% 
      layer_dense(units = 100, activation = 'sigmoid', input_shape = inputshape) %>%
      layer_dense(units = 100, activation = 'sigmoid') %>% 
      layer_dense(units = 4,  activation  = 'softmax')
    
  } else if(modelNr == 4) {
    mlp_model <- keras_model_sequential()
    mlp_model %>% 
      layer_dense(units = 50, activation = 'sigmoid', input_shape = inputshape) %>%
      layer_dense(units = 50, activation = 'sigmoid') %>% 
      layer_dense(units = 50, activation = 'sigmoid') %>% 
      layer_dense(units = 50, activation = 'sigmoid') %>% 
      layer_dense(units = 50, activation = 'sigmoid') %>% 
      layer_dense(units = 4, activation  = 'softmax')
    
  } else if(modelNr == 5) {
    mlp_model <- keras_model_sequential()
    mlp_model %>% 
      layer_dense(units = 50, activation = 'sigmoid', input_shape = inputshape) %>%
      layer_dense(units = 10, activation = 'sigmoid') %>% 
      layer_dense(units = 50, activation = 'sigmoid') %>% 
      layer_dense(units = 4, activation  = 'softmax')
  }
  
  return(mlp_model)
}









