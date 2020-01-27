# Funktion zum Daten Laden und initial Splits erstellen

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
  
  
  #   2.1 Möglichst großen DS
  ############# Weglassen, zu lange laufzeiten ohne Mehrwert, Willkürlich ###################
  pnc_sample_max <- pnc %>% filter(category %in% c("P", "N", "K", "S"))
  pnc_sample_max_train <- sample_n( base::as.data.frame(pnc_sample_max), nrow(pnc_sample_max)*validationSplit)
  pnc_sample_max_val   <-  base::as.data.frame(pnc_sample_max %>% anti_join(pnc_sample_max_train))
  
 
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
  
 #  2.4 Datensatz nur aus den Real-World Examples
  repr_roh <- pnc_roh %>% filter(nchar(volltext) > TextLengthFilter) %>% 
              filter (quelle %in% c('sample_1' ,'sample_3')) %>% 
              mutate(category_num = case_when(category == "K" ~ 0, category == "N" ~ 1, category == "P" ~ 2, category == "S" ~ 3))
  pnc_sample_repr_train  <- sample_n( base::as.data.frame(repr_roh), nrow(repr_roh)*validationSplit)
  pnc_sample_repr_val  <- base::as.data.frame(repr_roh %>% anti_join(pnc_sample_repr_train))
  pnc_sample_repr_test <- pnc_sample_repr_val # beide gleich, da kein 3. Set vorhanden
  
 #  2.5 Qualitätsset aus wirklich von hand geprüften Daten
  
  pnc_sample_qual_train <- readRDS("data/Train_complete/20191023_Handselected_Trainset.rds")
  pnc_sample_qual_train <- sample_n(base::as.data.frame(pnc_sample_qual_train), nrow(base::as.data.frame(pnc_sample_qual_train)))
  uebrige_Daten <- pnc %>% anti_join(pnc_sample_qual_train) %>% filter(!quelle %in% c("sample_1", "sample_3"))
  pnc_sample_qual_val   <- bind_rows(sample_n( base::as.data.frame(uebrige_Daten %>% filter(category == "N")), 500),
                                     sample_n( base::as.data.frame(uebrige_Daten %>% filter(category == "P")), 500),
                                     sample_n( base::as.data.frame(uebrige_Daten %>% filter(category == "S")), 330),
                                     sample_n( base::as.data.frame(uebrige_Daten %>% filter(category == "K")), 500))
  pnc_sample_qual_val <- sample_n(base::as.data.frame(pnc_sample_qual_val), nrow(base::as.data.frame(pnc_sample_qual_val)))
  
  
  # Finale Liste bauen
  TrainValSamples <- list(list( pnc_sample_max_train,  pnc_sample_max_val,  pnc_Testdatensatz), 
                          list( pnc_sample_bal_train,  pnc_sample_bal_val,  pnc_Testdatensatz),
                          list( pnc_sample_real_train, pnc_sample_real_val, pnc_Testdatensatz),
                          list( pnc_sample_repr_train, pnc_sample_repr_val, pnc_sample_repr_test),
                          list( pnc_sample_qual_train, pnc_sample_qual_val, pnc_Testdatensatz)
                         )
  names(TrainValSamples) <- c("Maximum_Data","Balanced_Data","RealDistributed_Data","ReprSample_Data","HighQuality_Data")
  
  return(TrainValSamples)
}






