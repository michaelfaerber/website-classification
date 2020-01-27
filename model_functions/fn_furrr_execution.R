#furrrr_execute_fn

if (exists("master") == F) {
  master <- new.env()
}
# FUNKTION 1: Entscheidung über Modell

# !!!! Unbedingt mit TRY aufrufen !!!!

# IN: Eine Zeile des Steuerungs-Dataframes
master$execute_Experiment_furrr <- function(SteuerDfLine, globalSeed = 1337){
  # 1. Entscheidung: Welches Modell wird aufgerufen?
  writeLines(paste("++++++++++ Testing a ",SteuerDfLine$model," Model", sep=""))
  DTMdata <- readRDS('~/benjamin/data/99_MA_complete/dtmdata_4.rds')
  if(SteuerDfLine$model == "NaiveBayes") {
    modelMetrics <- master$fn_naivebayes(master$load_dataStack_furrr(SteuerDfLine$data, DTMdata), 
                                         globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "xgboost"){
    modelMetrics <- master$fn_xgboost(master$load_dataStack_furrr(SteuerDfLine$data, DTMdata), 
                                      maxdepth  = SteuerDfLine$maxdepth, 
                                      gamma     = SteuerDfLine$gamma, 
                                      nround    = SteuerDfLine$nround, 
                                      earlystop = SteuerDfLine$earlystop, 
                                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "randomForest"){
    modelMetrics <- master$fn_rndForest(master$load_dataStack_furrr(SteuerDfLine$data, DTMdata), 
                                        ntree = SteuerDfLine$ntree, 
                                        mtry  = SteuerDfLine$mtry, 
                                        globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "svm_1vr"){
    modelMetrics <- master$fn_svm_1vR(master$load_dataStack_furrr(SteuerDfLine$data, DTMdata),
                                      cost = SteuerDfLine$cost, 
                                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "svm_1v1"){
    modelMetrics <- master$fn_svm_1v1(master$load_dataStack_furrr(SteuerDfLine$data, DTMdata),
                                      cost = SteuerDfLine$cost, 
                                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "mlp"){
    modelMetrics <- master$fn_mlp_1(master$load_dataStack_furrr(SteuerDfLine$data, DTMdata),
                                    ModelNr = SteuerDfLine$modelnr,
                                    epochs = SteuerDfLine$epochs,
                                    batchSize = SteuerDfLine$batchsize,
                                    globalSeed = globalSeed)
    
  }else {
    modelMetrics <- list("Model type unknown")
  }
  
  # 2. Return des Modells zurück an Zeile
  return(modelMetrics)
}



master$load_dataStack_furrr <- function(dataName, DTMdata) {
  writeLines(paste("++++++++++ Using Data from Dataset ",dataName, sep=""))
  Identifier <- paste0("TVT_", dataName)
  DTMdata[[Identifier]]
}


