# Funktion für CNN mit Embeddinglayer

master$fn_cnn <- function(tvt_data, ModelNr, epochs = 10, batchSize = 32, Threshold = 0, 
                            sequenceLength = 2000, maxNumWords= 25000, globalSeed = 1337 ) {
  require(keras)
  require(tictoc)
  require(readr)
  require(R.utils) 
  require(dplyr)
  require(purrr)
  
  # tvt_data <- TrainValTestSamples[["HighQuality_Data"]]
  # GLOVE_DIR <- '/opt/rlang/benjamin/data/glove/'
  FT_DIR <- '~/benjamin/data/fasttext/'
  MAX_SEQUENCE_LENGTH <- sequenceLength
  MAX_NUM_WORDS <- maxNumWords
  EMBEDDING_DIM <- 300
  VALIDATION_SPLIT <- 0.2
  
  #TODO Übergeben bekommen! Rohdaten müssens sein!
  # TVT_samples <- read_rds('/opt/rlang/benjamin/data/99_MA_complete/TVTSamples_4.rds')
  # TVT_qual <- TVT_samples[[5]]
  # rm(TVT_samples)
  
  # vect <- readRDS('~/benjamin/data/glove/ger_glove_vectors.rds')
  vect <- readRDS('~/benjamin/data/fasttext/ger_fasttext_vectors.rds')
   vect <- vect[-1] #?????
  
  cat('Processing text dataset\n')
  texts <- tvt_data[[1]]$volltext
  labels <- tvt_data[[1]]$category_num
  
  cat(sprintf('Found %s texts.\n', length(texts)))
  
  # finally, vectorize the text samples into a 2D integer tensor
  tokenizer <- text_tokenizer(num_words=MAX_NUM_WORDS)
  tokenizer %>% fit_text_tokenizer(texts)
  
  # save_text_tokenizer(tokenizer, "/opt/rlang/benjamin/data/tokenizer")
  
  sequences_train <- texts_to_sequences(tokenizer, texts)
  sequences_val   <- texts_to_sequences(tokenizer, tvt_data[[2]]$volltext)
  sequences_test  <- texts_to_sequences(tokenizer, tvt_data[[3]]$volltext)
  
  word_index <- tokenizer$word_index
  
  data_train <- pad_sequences(sequences_train, maxlen=MAX_SEQUENCE_LENGTH)
  data_val   <- pad_sequences(sequences_val, maxlen=MAX_SEQUENCE_LENGTH)
  data_test  <- pad_sequences(sequences_test, maxlen=MAX_SEQUENCE_LENGTH)

  x_train <- data_train
  x_val   <- data_val
  x_test  <- data_test
  # One-hot-encoding for Targetlabels
  y_train  <- to_categorical(tvt_data[[1]]$category_num)
  y_val    <- to_categorical(tvt_data[[2]]$category_num)
  y_test   <- to_categorical(tvt_data[[3]]$category_num)
  
  cat('Preparing embedding matrix.\n')
  num_words <- min(MAX_NUM_WORDS, length(word_index) + 1)
  
  vocab <- word_index [word_index <= MAX_NUM_WORDS]
  relevant_vect <- purrr::keep(vect, names(vect) %in% names(vocab))
  
  prepare_embedding_matrix <- function() {
    embedding_matrix <- matrix(0L, nrow = num_words, ncol = EMBEDDING_DIM)
    for (word in names(vocab)) {
      index <- vocab[[word]]
      # embedding_vector <- vect[[word]]
      embedding_vector <- relevant_vect[[word]]
      if (!is.null(embedding_vector)) {
        # words not found in embedding index will be all-zeros.
        embedding_matrix[index,] <- embedding_vector
      }
    }
    embedding_matrix
  }
  
  embedding_matrix <- prepare_embedding_matrix()
  
  # load pre-trained word embeddings into an Embedding layer
  embedding_layer <- layer_embedding(
    input_dim = num_words,
    output_dim = EMBEDDING_DIM,
    weights = list(embedding_matrix),
    input_length = MAX_SEQUENCE_LENGTH,
    trainable = FALSE
  )
  
  cat('Training model\n')
  tic()
  # train a 1D convnet with global maxpooling
  sequence_input <- layer_input(shape = list(MAX_SEQUENCE_LENGTH), dtype='int32')
  
  model <- master$get_keras_cnn(ModelNr, embedding_layer, sequence_input )
  summary(model)
  
  model %>% keras::compile(
    loss = 'categorical_crossentropy',
    # optimizer = 'rmsprop',
    optimizer = 'adam',
    metrics = c('acc')  
  )
  
  model %>% keras::fit(
    x_train, y_train,
    batch_size = batchSize,
    epochs = epochs,
    validation_data = list(x_val, y_val)
  )
  
  traintime <- toc()
  ################### auswertung
  tic()
  Prediction_Val  <- as.data.frame(predict(model, x_val))
  colnames(Prediction_Val) <- c(0,1,2,3)
  Eval_Val <- as.factor(colnames(Prediction_Val)[apply(Prediction_Val,1,which.max)])
  colnames(Prediction_Val) <- c('V1','V2','V3','V4')
  valtime <- toc()

  val_DF <- cbind(Prediction_Val, Eval_Val, label =  as.factor(tvt_data[[2]]$category_num)) %>% 
    mutate(threshold = pmax(V1,V2,V3,V4))
  val_DF <- val_DF %>% filter(threshold >= Threshold)
  colnames(val_DF) <- c(0,1,2,3, 'Eval_Val', 'label')
  
  tic()
  Prediction_Test <- as.data.frame(predict(model, x_test))
  colnames(Prediction_Test) <- c(0,1,2,3)
  Eval_Test <- as.factor(colnames(Prediction_Test)[apply(Prediction_Test,1,which.max)])
  colnames(Prediction_Test) <- c('V1','V2','V3','V4')
  testtime <- toc()
  
  test_DF <- cbind(Prediction_Test, Eval_Test, label =  as.factor(tvt_data[[3]]$category_num)) %>% 
    mutate(threshold = pmax(V1,V2,V3,V4)) 
  test_DF <- test_DF %>% filter(threshold >= Threshold)
  colnames(test_DF) <- c(0,1,2,3, 'Eval_Test', 'label')
  
  # Metriken aus caret Package:
  cfm_val  <- caret::confusionMatrix(as.factor(val_DF$Eval_Val  ) ,as.factor(val_DF$label ))
  cfm_test <- caret::confusionMatrix(as.factor(test_DF$Eval_Test) ,as.factor(test_DF$label))
  cfm_val_plot  <- bs$ggplotConfusionMatrix(cfm_val)
  cfm_test_plot <- bs$ggplotConfusionMatrix(cfm_test)
  
  
  return(
    list(cfm_val, cfm_test, cfm_val_plot, cfm_test_plot, 
         unname(traintime$toc - traintime$tic), 
         unname(valtime$toc - valtime$tic), 
         unname(testtime$toc - testtime$tic))
  )
  
  
}


#######################
master$get_keras_cnn <- function(modelNr, embedding_layer, sequence_input ){
  if(modelNr == 1){

    preds <- sequence_input %>%
      embedding_layer %>% 
      layer_conv_1d(filters = 128, kernel_size = 3, activation = 'relu') %>% 
      layer_max_pooling_1d(pool_size = 3) %>%   
      layer_conv_1d(filters = 128, kernel_size = 2, activation = 'relu') %>% 
      layer_max_pooling_1d(pool_size = 5) %>%
      layer_conv_1d(filters = 128, kernel_size = 3, activation = 'relu') %>% 
      layer_max_pooling_1d(pool_size = 5) %>% 
      layer_flatten() %>% 
      layer_dense(units = 100, activation = 'sigmoid') %>% 
      layer_dense(units = 4, activation = 'softmax')
    
    cnn_model <- keras_model(sequence_input, preds)


  } else if(modelNr == 2) {
    preds <- sequence_input %>%
      embedding_layer %>%
      layer_conv_1d(filters = 128, kernel_size = 9, activation = 'relu') %>%
      layer_max_pooling_1d(pool_size = 12) %>%
      layer_conv_1d(filters = 128, kernel_size = 9, activation = 'relu') %>%
      layer_max_pooling_1d(pool_size = 24) %>%
      layer_flatten() %>%
      layer_dense(units = 100, activation = 'sigmoid') %>%
      layer_dense(units = 4, activation = 'softmax')

  
    cnn_model <- keras_model(sequence_input, preds)
    summary(cnn_model)
    
  }else if(modelNr == 3) {
    preds <- sequence_input %>%
      embedding_layer %>%
      layer_conv_1d(filters = 128, kernel_size = 5, activation = 'relu') %>%
      layer_max_pooling_1d(pool_size = 5) %>%
      layer_conv_1d(filters = 128, kernel_size = 5, activation = 'relu') %>%
      layer_max_pooling_1d(pool_size = 5) %>%
      layer_conv_1d(filters = 128, kernel_size = 5, activation = 'relu') %>%
      layer_max_pooling_1d(pool_size = 35) %>%
      layer_flatten() %>%
      layer_dense(units = 128, activation = 'relu') %>%
      layer_dense(units = 4, activation = 'softmax')
  
    cnn_model <- keras_model(sequence_input, preds)
    summary(cnn_model)
    
  } else {
    cat('Model-Nr not found')
  }
  
  return(cnn_model)
}
