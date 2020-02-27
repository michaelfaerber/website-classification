# Funktion zum Daten Laden und initial Splits erstellen
if (exists("master") == F) {
  master <- new.env()
}
# IN  : TextLengthFilter, balancedSize, vector_real
# OUT : List of samples

# verctor_real hat aus Excel berechnete Default-Werte
master$loadAndSplit <- function(RohdatenPfad, TextLengthFilter = 500, balancedSize = 950, vector_real = c(1306,2283,239,10450)) {
  
  # 2. Sample / vollständige Trainingsdaten laden & filtern.
  pnc_roh <- readRDS(eval(RohdatenPfad))
  pnc <- pnc_roh %>% filter(nchar(volltext) > TextLengthFilter) %>% 
    filter (quelle != 'sample_1') %>%     # Testset wegfiltern
    mutate(category_num = case_when(category == "K" ~ 0, category == "N" ~ 1, category == "P" ~ 2, category == "S" ~ 3))
  
  pnc_Testdatensatz <- pnc_roh %>% filter(nchar(volltext) > TextLengthFilter) %>% 
    filter (quelle == 'sample_1') %>%     # Testset behalten
    # mutate(category_num = case_when(category == "K" ~ 0, category == "N" ~ 1, category == "P" ~ 2, category == "S" ~ 3))
    mutate(category_num = if_else(category == 'K', 0, if_else(category == 'N', 1, if_else(category == 'P', 2, 3))))
  
  
 
  #   2.2 Balancierten Datensatz
  pnc_sample_bal <- rbind(sample_n( base::as.data.frame(pnc %>% filter(category == "N")), balancedSize),
                          sample_n( base::as.data.frame(pnc %>% filter(category == "P")), balancedSize),
                          sample_n( base::as.data.frame(pnc %>% filter(category == "S")), balancedSize),
                          sample_n( base::as.data.frame(pnc %>% filter(category == "K")), balancedSize))
  pnc_sample_bal_train <- sample_n(pnc_sample_bal, nrow(pnc_sample_bal)*validationSplit)
  pnc_sample_bal_val   <- pnc_sample_bal %>% anti_join(pnc_sample_bal_train)
  
  
  #   2.3 Datensatz mit realistischer Verteilung (Zahlen aus Excel)
  pnc_sample_real <- rbind(sample_n( base::as.data.frame(pnc %>% filter(category == "N")),  vector_real[1]),
                           sample_n( base::as.data.frame(pnc %>% filter(category == "P")),  vector_real[2]),
                           sample_n( base::as.data.frame(pnc %>% filter(category == "S")),  vector_real[3]),
                           sample_n( base::as.data.frame(pnc %>% filter(category == "K")),  vector_real[4]))
  pnc_sample_real_train <- sample_n(pnc_sample_real, nrow(pnc_sample_real)*validationSplit)
  pnc_sample_real_val   <- pnc_sample_real %>% anti_join(pnc_sample_real_train)
  

  
  # Finale Liste bauen
  TrainValSamples <- list(
                          list( pnc_sample_bal_train,  pnc_sample_bal_val,  pnc_sample_bal_val),
                          list( pnc_sample_real_train, pnc_sample_real_val, pnc_sample_real_val),
                         )
  names(TrainValSamples) <- c("Balanced_Data","RealDistributed_Data")
  
  return(TrainValSamples)
}






