# Config für den Run der vollständigen Masterarbeit

if (exists("master") == F) {
  master <- new.env()
}

source("scripts/generate_stopwords.R")
source("scripts/t2v_data_preparation.R")
source("scripts/visualize_cfm.R")
source("scripts/svm_1vsRest_Num.R")
source("scripts/function_load_and_split.R")
source("scripts/function_prepare_dtm.R")

#Scripts fuer die Durchfuehrung:
source("functions/function_prepare_dtm.R")
source("functions/function_load_and_split.R")
source("functions/fn_execution_coordinator.R")
# source("functions/fn_calc_metrics.R")
#source("functions/fn_Evaluationplots.R")
source("model_functions/fn_naiveBayes.R")
source("model_functions/fn_xgboost.R")
source("model_functions/fn_randomForest.R")
source("model_functions/fn_svm_1v1.R")
source("model_functions/fn_svm_1vRest.R")
source("model_functions/fn_mlp.R")
source("model_functions/fn_cnn.R")

library(e1071)
library(dplyr)
library(caret)
library(randomForest)
library(xgboost)
library(tictoc)
library(stopwords)
library(openxlsx)
library(furrr)
library(tidyr)
library(openxlsx)
library(SparseM)
validationSplit   <- 0.75
globalSeed        <- 1337
RohdatenPfad <- 'data/Train_PNC_full_20191008.rds'

