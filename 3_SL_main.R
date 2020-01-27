# Gesamtprogramm Masterarbeit

# 1. Bibliotheken / Config
source('SL_config.R')
Steuer_DF <- read.xlsx('Steuertabellen/Steuertabelle_Final.xlsx', sheet = 1, startRow = 1, colNames = TRUE)

############################
# Load & filter Data
# Behind "Rohdatenpfad" a path to an rds object with a dataframe is expected.
# The DF must have at least the following columns: domain, volltext, category, catkey
# volltext means the full text without html tags etc. of the page / document to be classified. 

#TrainValTestSamples <- master$loadAndSplit(RohdatenPfad)


##Prepare
# DEFAULTS: TermCountMin = 30, docProportionMax = 0.5, docProportionMin = 0.02, nGram = 1, vocabTermMax = 5000
#dtmData <- master$prepDTMs(TrainValTestSamples, docProportionMin = 0.01, vocabTermMax = 5000)


############################
# Option 2: Load old split / prepared data
# The TVTSample Data is expected to be a list of lists, containing the different Training data sets. 
# Each treining data set is a list of 3 data frames, each containing at least the columns domain, volltext, category, catkey
# 


TrainValTestSamples <- readRDS('data/TVTSamples_5.rds')
dtmData <- readRDS('data/dtmdata_5.rds')


# 4. Train Models
# separated models from Steuertabelle 
Steuer_DF_NB <- Steuer_DF %>% filter(model == 'NaiveBayes')   # medium runtime
Steuer_DF_xg <- Steuer_DF %>% filter(model == 'xgboost')      # short runtime
Steuer_DF_rf <- Steuer_DF %>% filter(model == 'randomForest') # huge runtime
Steuer_DF_svmR <- Steuer_DF %>% filter(model == 'svm_1vr')    # huge runtime
Steuer_DF_svm1 <- Steuer_DF %>% filter(model == 'svm_1v1')    # medium-huge runtime
Steuer_DF_mlp <- Steuer_DF %>% filter(model == 'mlp')         # short runtime
Steuer_DF_mlp_threshold <- Steuer_DF %>% filter(model == 'mlp_threshold') # short runtime
Steuer_DF_cnn <- Steuer_DF %>% filter(model == 'cnn')         # medium-huge runtime


Ergebnis_xg <- master$execute_steuerDF(Steuer_DF_xg)
saveRDS(Ergebnis_xg, 'data/results/Ergebnis_xg_v2.rds')

Ergebnis_mlp <- master$execute_steuerDF(Steuer_DF_mlp)
saveRDS(Ergebnis_mlp, 'data/results/Ergebnis_mlp_v2.rds')

Ergebnis_mlp_threshold <- master$execute_steuerDF(Steuer_DF_mlp_threshold)
saveRDS(Ergebnis_mlp_threshold, 'data/results/Ergebnis_mlp_threshold_v2.rds')

Ergebnis_NB <- master$execute_steuerDF(Steuer_DF_NB)
saveRDS(Ergebnis_NB, 'data/results/Ergebnis_NB_v2.rds')

Ergebnis_svm1 <- master$execute_steuerDF(Steuer_DF_svm1)
saveRDS(Ergebnis_svm1, 'data/results/Ergebnis_svm1_v2.rds')

Ergebnis_rf <- master$execute_steuerDF(Steuer_DF_rf)
saveRDS(Ergebnis_rf, 'data/results/Ergebnis_rf_v2.rds')

Ergebnis_svmR <-  master$execute_steuerDF(Steuer_DF_svmR)
saveRDS(Ergebnis_svmR, 'data/results/Ergebnis_svmR_v2.rds')

Ergebnis_cnn <- master$execute_steuerDF(Steuer_DF_cnn)
saveRDS(Ergebnis_cnn, 'data/results/Ergebnis_cnn_v4_model2.rds')

# The results contain evaluations, e.g. a confusion matrix.
# It can be accessed by a command like this:
# Ergebnis_xg[5,]$cfm_val

