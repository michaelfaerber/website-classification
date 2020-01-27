# Implementierung von SVM "One vs. Rest"

# 3 Modelle aufbauen ==> eines je Zielklasse
# Unterschied der Modelle: Nur der Vektor der Zielvariablen!
if (exists("bsmodel") == F) {
  bsmodel <- new.env()
}

bsmodel$svm_ovr_num <- function(traindata, target,  costVal = 60){
  # Anzahl Klassen bestimmen. Für n > 2 , Anzahl_svm = n
  classes <- target %>% unique()
  nrOfClasses <- length(target %>% unique())
  modellist <- list()
  
  if(nrOfClasses>2){
    # for each class, train model and save to list
    for(i in 1:nrOfClasses) {
      #Modify Target Vector to contain only 2 classes
      targetvector <- target
      targetvector[targetvector!=classes[i]] <- 9
      print(paste('Training model ',i,'/', nrOfClasses, sep=''))
      #Train Models
      modellist[[i]] <- svm(x = traindata, y = as.factor(targetvector), 
                          kernel = "linear", cost=costVal, type = 'C-classification', probability = T)
      
    }
  } 
  else {print('Weniger als 3 Klassen nicht zulässig')}
  
  #Klassenlabels für die Modelle werden mitgegebene
  modellist[[nrOfClasses+1]] <- classes
  #return
  modellist
}


bsmodel$svm_eval_num <- function(models, testset) {
  # for each model: evaluate & get Class-Prob-vector
  problist <- list()
  classes <- models[[length(models)]]
  for (i in 1:(length(models)-1)) {
    problist[[i]] <-  as.numeric(attr(predict(models[[i]], testset, probability = T), 
                                       "probabilities")[,eval(as.character(classes[i]))] )
  }
  
  #return: vector of predicted class labels
  probtable <- data.frame(problist[[1]])
  for (i in 2:length(problist)) {
    probtable <- cbind(probtable, problist[[i]])
  }
  colnames(probtable) <- models[[length(models)]]
  #probtable
   as.factor(colnames(probtable)[apply(probtable,1,which.max)])
  #data.frame(class =  as.factor(colnames(probtable)[apply(probtable,1,which.max)]),
   # certainty = as.factor(colnames(probtable)[apply(probtable,1,max)])
  #)
  
}


bsmodel$svm_eval_num_thres <- function(models, testset) {
  # for each model: evaluate & get Class-Prob-vector
  problist <- list()
  classes <- models[[length(models)]]
  for (i in 1:(length(models)-1)) {
    problist[[i]] <-  as.numeric(attr(predict(models[[i]], testset, probability = T), 
                                      "probabilities")[,eval(as.character(classes[i]))] )
  }
  
  #return: vector of predicted class labels
  probtable <- data.frame(problist[[1]])
  for (i in 2:length(problist)) {
    probtable <- cbind(probtable, problist[[i]])
  }
  colnames(probtable) <- c("a", "b", "c", "d")
  probs <- as.vector(probtable %>% mutate(certainty = pmax(a,b,c,d)) %>% select(certainty))
  colnames(probtable) <- models[[length(models)]]
  # probtable
  # as.factor(colnames(probtable)[apply(probtable,1,which.max)])
  data.frame(class =  as.factor(colnames(probtable)[apply(probtable,1,which.max)]),
             certainty = probs
  )
  
}



