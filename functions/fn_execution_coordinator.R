# Die Intelligenz des Programms - der Ausführer.
# Entscheidet anhand der Inputtabelle, welche Modelle mit welchen Daten aufgerufen werden.
if (exists("master") == F) {
  master <- new.env()
}
# FUNKTION 1: Entscheidung über Modell

# !!!! Unbedingt mit TRY aufrufen !!!!

# IN: Eine Zeile des Steuerungs-Dataframes
master$execute_Experiment <- function(SteuerDfLine, globalSeed = 1337){
# 1. Entscheidung: Welches Modell wird aufgerufen?
  writeLines(paste(Sys.time()," ++++++++++ Testing a ",SteuerDfLine$model," Model", sep=""))
  if(SteuerDfLine$model == "NaiveBayes") {
    modelMetrics <- master$fn_naivebayes(master$load_dataStack(SteuerDfLine$data), 
                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "xgboost"){
    modelMetrics <- master$fn_xgboost(master$load_dataStack(SteuerDfLine$data), 
                      maxdepth   = SteuerDfLine$maxdepth, 
                      gamma      = SteuerDfLine$gamma, 
                      nround     = SteuerDfLine$nround, 
                      earlystop  = SteuerDfLine$earlystop, 
                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "randomForest"){
    modelMetrics <- master$fn_rndForest(master$load_dataStack(SteuerDfLine$data), 
                      ntree      = SteuerDfLine$ntree, 
                      mtry       = SteuerDfLine$mtry, 
                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "svm_1vr"){
    modelMetrics <- master$fn_svm_1vR(master$load_dataStack(SteuerDfLine$data),
                      cost       = SteuerDfLine$cost, 
                      globalSeed = globalSeed)
    
  } else if (SteuerDfLine$model == "svm_1v1"){
    modelMetrics <- master$fn_svm_1v1(master$load_dataStack(SteuerDfLine$data),
                      cost       = SteuerDfLine$cost, 
                      globalSeed = globalSeed)
    
  # } else if (SteuerDfLine$model == "mlp"){
  } else if (SteuerDfLine$model %in% c("mlp", "mlp_threshold")){
    modelMetrics <- master$fn_mlp_1(master$load_dataStack(SteuerDfLine$data),
                      ModelNr    = SteuerDfLine$modelnr,
                      epochs     = SteuerDfLine$epochs,
                      batchSize  = SteuerDfLine$batchsize,
                      Threshold  = SteuerDfLine$threshold,
                      globalSeed = globalSeed)
    
    } else if (SteuerDfLine$model == "cnn"){
    modelMetrics <- master$fn_cnn(master$load_rawDataStack(SteuerDfLine$data),
                      ModelNr        = SteuerDfLine$modelnr,
                      epochs         = SteuerDfLine$epochs,
                      Threshold      = SteuerDfLine$threshold,
                      batchSize      = SteuerDfLine$batchsize,
                      sequenceLength = SteuerDfLine$sequenceLength,
                      maxNumWords    = SteuerDfLine$MaxNumWords,
                      globalSeed     = globalSeed)
    
  }else {
    modelMetrics <- list("Model type unknown")
  }
  
  # 2. Return des Modells zurück an Zeile
  return(modelMetrics)
}


master$load_dataStack <- function(dataName) {
  writeLines(paste("++++++++++ Using Data from Dataset ",dataName, sep=""))
  Identifier <- paste0("TVT_", dataName)
  dtmData[[Identifier]]
}


master$load_rawDataStack <- function(dataName) {
  writeLines(paste("++++++++++ Using Data from Dataset ",dataName, sep=""))
  TrainValTestSamples[[dataName]]
}

  
  
master$execute_steuerDF <- function(steuerDF) {
  Resultlist <- list()
  for(i in 1:nrow(steuerDF)) {
    my_row <- steuerDF[i,]
    my_return <- master$execute_Experiment(my_row)
    my_row$cfm_val       <- my_return[1]
    my_row$cfm_test      <- my_return[2]
    my_row$cfm_val_plot  <- my_return[3]
    my_row$cfm_test_plot <- my_return[4]
    my_row$Traintime     <- my_return[5]
    my_row$Valtime       <- my_return[6]
    my_row$Testtime      <- my_return[7]
    
    if(length(my_return)>7) {
      my_row$Val_DF        <- my_return[8]
      my_row$Test_DF       <- my_return[9]
    } else {
      my_row$Val_DF        <- NA
      my_row$Test_DF       <- NA
    }
    Resultlist[[i]]      <- my_row
    cat(sprintf('\nCompleted Model %i of %i in current executionlist\n\n', i, nrow(steuerDF)))
  }
  
  Result_DF <- do.call("rbind", Resultlist)
  return(Result_DF)
}

