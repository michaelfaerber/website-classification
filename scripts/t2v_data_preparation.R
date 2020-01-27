# Datenaufbereitung mit text2vec
if (exists("bs") == F) {
  bs <- new.env()
}
library(text2vec)

bs$text2dtm <- function(trainset, validationset, testset = NA, TermCountMin = 5, docProportionMax = 1, 
                        docProportionMin = 0, nGram =1,  dotestset = F, vocabTermMax = Inf) {
  if(dotestset){n=4} else {n=3}
# unnesting / tokenization of Trainingdata
  tok_fun = word_tokenizer
  prep_fun = tolower
  
  it = itoken(trainset$volltext,
              #preprocessor = prep_fun,
              tokenizer = tok_fun, 
              ids = trainset$domain, 
              progressbar = T)
  writeLines(paste("(1/",n,")Creating Vocabulary:", sep=""))
  
  vocab = create_vocabulary(it, ngram = c(1, nGram))
  
  vocab = prune_vocabulary(vocab, term_count_min = TermCountMin, doc_proportion_max = docProportionMax, 
                           doc_proportion_min = docProportionMin,  vocab_term_max = vocabTermMax)
  vectorizer = vocab_vectorizer(vocab)
  writeLines(paste("(2/",n,")Creating Training dtm:", sep=""))
  dtm_train <- create_dtm(it,vectorizer)

  # Create tfidf Model
  tfidf = TfIdf$new(sublinear_tf = T)
  dtm_train_tfidf = fit_transform(dtm_train, tfidf)
  
  # unnesting / tokenization & feature creation on validationset
  writeLines(paste("\n(3/",n,")Creating Validation dtm:", sep=""))
  it_val = itoken(validationset$volltext, 
              #preprocessor = prep_fun,
              tokenizer = tok_fun, 
              ids = validationset$domain, 
              progressbar = T)
  dtm_val <- create_dtm(it_val,vectorizer)
  dtm_val_tfidf <- transform(dtm_val, tfidf)
  
  
  if(dotestset) {
    # unnesting / tokenization & feature creation on testset
    writeLines(paste("(",n,"/",n,")Creating Test dtm:", sep=""))
    it_test = itoken(testset$volltext, 
                    #preprocessor = prep_fun,
                    tokenizer = tok_fun, 
                    ids = testset$domain, 
                    progressbar = T)
    dtm_test <- create_dtm(it_test,vectorizer)
    dtm_test_tfidf <- transform(dtm_test, tfidf)
    #return
    list(dtm_train_tfidf, dtm_val_tfidf, dtm_test_tfidf)
  }
  #Return if no testset required
  else {
    list(dtm_train_tfidf, dtm_val_tfidf)
  }
}


##################
# My Prepfunction
##################
bs$myprepfun <- function(textdata){
  
}


##################
# with Prepfunctions and stopwords
##################

bs$text2dtmwPrep <- function(trainset, validationset, testset = NA, TermCountMin = 5, docProportionMax = 1, 
                        docProportionMin = 0, nGram =1,  dotestset = F, vocabTermMax = Inf) {
  if(dotestset){n=4} else {n=3}
  # unnesting / tokenization of Trainingdata
  tok_fun = word_tokenizer
  prep_fun = tolower
  
  it = itoken(trainset$volltext,
              #preprocessor = prep_fun,
              tokenizer = tok_fun, 
              ids = trainset$domain, 
              progressbar = T)
  writeLines(paste("(1/",n,")Creating Vocabulary:", sep=""))
  
  vocab = create_vocabulary(it, ngram = c(1, nGram))#, stopwords = ger_stopwords$word)
  
  vocab = prune_vocabulary(vocab, term_count_min = TermCountMin, doc_proportion_max = docProportionMax, 
                           doc_proportion_min = docProportionMin, vocab_term_max = vocabTermMax)
  vectorizer = vocab_vectorizer(vocab)
  writeLines(paste("(2/",n,")Creating Training dtm:", sep=""))
  dtm_train <- create_dtm(it,vectorizer)
  
  # Create tfidf Model
  tfidf = TfIdf$new(sublinear_tf = T, norm = "l2")#l2 performs significantly better & sublinear_tf = T gives slight boost in Accuracy
  dtm_train_tfidf = fit_transform(dtm_train, tfidf)
  
  # unnesting / tokenization & feature creation on validationset
  writeLines(paste("\n(3/",n,")Creating Validation dtm:", sep=""))
  it_val = itoken(validationset$volltext, 
                  #preprocessor = prep_fun,
                  tokenizer = tok_fun, 
                  ids = validationset$domain, 
                  progressbar = T)
  dtm_val <- create_dtm(it_val,vectorizer)
  dtm_val_tfidf <- transform(dtm_val, tfidf)
  
  
  if(dotestset) {
    # unnesting / tokenization & feature creation on testset
    writeLines(paste("(",n,"/",n,")Creating Test dtm:", sep=""))
    it_test = itoken(testset$volltext, 
                     #preprocessor = prep_fun,
                     tokenizer = tok_fun, 
                     ids = testset$domain, 
                     progressbar = T)
    dtm_test <- create_dtm(it_test,vectorizer)
    dtm_test_tfidf <- transform(dtm_test, tfidf)
    #return
    list(dtm_train_tfidf, dtm_val_tfidf, dtm_test_tfidf)
  }
  #Return if no testset required
  else {
    list(dtm_train_tfidf, dtm_val_tfidf)
  }
}



##################
# with Models
##################

bs$text2dtmModels <- function(trainset, validationset, testset = NA, TermCountMin = 5, docProportionMax = 1, 
                             docProportionMin = 0, nGram =1,  dotestset = F, vocabTermMax = Inf) {
  if(dotestset){n=4} else {n=3}
  # unnesting / tokenization of Trainingdata
  tok_fun = word_tokenizer
  prep_fun = tolower
  
  it = itoken(trainset$volltext,
              #preprocessor = prep_fun,
              tokenizer = tok_fun, 
              ids = trainset$domain, 
              progressbar = T)
  writeLines(paste("(1/",n,")Creating Vocabulary:", sep=""))
  
  vocab = create_vocabulary(it, ngram = c(1, nGram))#, stopwords = ger_stopwords$word)
  
  vocab = prune_vocabulary(vocab, term_count_min = TermCountMin, doc_proportion_max = docProportionMax, 
                           doc_proportion_min = docProportionMin, vocab_term_max = vocabTermMax)
  vectorizer = vocab_vectorizer(vocab)
  writeLines(paste("(2/",n,")Creating Training dtm:", sep=""))
  dtm_train <- create_dtm(it,vectorizer)
  
  # Create tfidf Model
  tfidf = TfIdf$new(sublinear_tf = T, norm = "l2")#l2 performs significantly better & sublinear_tf = T gives slight boost in Accuracy
  dtm_train_tfidf = fit_transform(dtm_train, tfidf)
  
  # unnesting / tokenization & feature creation on validationset
  writeLines(paste("\n(3/",n,")Creating Validation dtm:", sep=""))
  it_val = itoken(validationset$volltext, 
                  #preprocessor = prep_fun,
                  tokenizer = tok_fun, 
                  ids = validationset$domain, 
                  progressbar = T)
  dtm_val <- create_dtm(it_val,vectorizer)
  dtm_val_tfidf <- transform(dtm_val, tfidf)
  
  
  if(dotestset) {
    # unnesting / tokenization & feature creation on testset
    writeLines(paste("(",n,"/",n,")Creating Test dtm:", sep=""))
    it_test = itoken(testset$volltext, 
                     #preprocessor = prep_fun,
                     tokenizer = tok_fun, 
                     ids = testset$domain, 
                     progressbar = T)
    dtm_test <- create_dtm(it_test,vectorizer)
    dtm_test_tfidf <- transform(dtm_test, tfidf)
    #return
    list(dtm_train_tfidf, dtm_val_tfidf, dtm_test_tfidf, trainset$category_num, validationset$category_num, testset$category_num , vectorizer, tfidf)
  }
  #Return if no testset required
  else {
    list(dtm_train_tfidf, dtm_val_tfidf, trainset$category_num, validationset$category_num, vectorizer, tfidf)
  }
}



###########################################################
# With Models, No weighting tf-idf whatsoever
###########################################################

bs$text2dtmModelsNoWei <- function(trainset, validationset, testset = NA, TermCountMin = 5, docProportionMax = 1, 
                              docProportionMin = 0, nGram =1,  dotestset = F, vocabTermMax = Inf) {
  if(dotestset){n=4} else {n=3}
  stopwords_full <- bs$stopwords.full()
  # unnesting / tokenization of Trainingdata
  tok_fun = word_tokenizer
  prep_fun = tolower
  
  it = itoken(trainset$volltext,
              #preprocessor = prep_fun,
              tokenizer = tok_fun, 
              ids = trainset$domain, 
              progressbar = T)
  writeLines(paste("(1/",n,")Creating Vocabulary:", sep=""))
  
  # vocab = create_vocabulary(it, ngram = c(1, nGram), stopwords = ger_stopwords$word)
  vocab = create_vocabulary(it, ngram = c(1, nGram), stopwords = stopwords_full$word)
  
  vocab = prune_vocabulary(vocab, term_count_min = TermCountMin, doc_proportion_max = docProportionMax, 
                           doc_proportion_min = docProportionMin, vocab_term_max = vocabTermMax)
  vectorizer = vocab_vectorizer(vocab)
  writeLines(paste("(2/",n,")Creating Training dtm:", sep=""))
  dtm_train <- create_dtm(it,vectorizer)
  
  
  # unnesting / tokenization & feature creation on validationset
  writeLines(paste("\n(3/",n,")Creating Validation dtm:", sep=""))
  it_val = itoken(validationset$volltext, 
                  #preprocessor = prep_fun,
                  tokenizer = tok_fun, 
                  ids = validationset$domain, 
                  progressbar = T)
  dtm_val <- create_dtm(it_val,vectorizer)

  
  
  if(dotestset) {
    # unnesting / tokenization & feature creation on testset
    writeLines(paste("(",n,"/",n,")Creating Test dtm:", sep=""))
    it_test = itoken(testset$volltext, 
                     #preprocessor = prep_fun,
                     tokenizer = tok_fun, 
                     ids = testset$domain, 
                     progressbar = T)
    dtm_test <- create_dtm(it_test,vectorizer)
    #return
    list(dtm_train, dtm_val, dtm_test, trainset$category_num, validationset$category_num, testset$category_num , vectorizer)
  }
  #Return if no testset required
  else {
    list(dtm_train, dtm_val, trainset$category_num, validationset$category_num, vectorizer)
  }
}



