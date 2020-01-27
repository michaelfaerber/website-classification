# Funktion: 
# - Preparieren der  Trainingsdaten für den Versuchslauf der Modelle der Masterarbeit

#  IN: PNC Rohdaten list of lists, Parameter (TermCountMin, docProportionMax, docProportionMin, nGram, vocabTermMax)
# OUT: 
master$prepDTMs <- function(TrainValTestSamples, TermCountMin = 30, docProportionMax = 0.5, docProportionMin = 0.02, nGram = 1, vocabTermMax = 5000) {
  maxSet  <- TrainValTestSamples [["Maximum_Data"]]
  balSet  <- TrainValTestSamples [["Balanced_Data"]]
  realSet <- TrainValTestSamples [["RealDistributed_Data"]]
  reprSet <- TrainValTestSamples [["ReprSample_Data"]]
  qualSet <- TrainValTestSamples [["HighQuality_Data"]]
  k <- 1      
  m <- 20     # Anzahl Schritte = Daten with 1- and 2-Gramsarianten*DtmVarianten
  
  #   3.1 dtm für alle mit TF-IDF
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs", sep=""))
  TVT_max_tfidf <- bs$text2dtmModels(maxSet[[1]], maxSet[[2]], maxSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                  docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs", sep=""))
  TVT_bal_tfidf <- bs$text2dtmModels(balSet[[1]], balSet[[2]], balSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                  docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs", sep=""))
  TVT_real_tfidf <- bs$text2dtmModels(realSet[[1]], realSet[[2]], realSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                   docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs", sep=""))
  TVT_repr_tfidf <- bs$text2dtmModels(reprSet[[1]], reprSet[[2]], reprSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs", sep=""))
  TVT_qual_tfidf <- bs$text2dtmModels(qualSet[[1]], qualSet[[2]], qualSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  
  #   3.1 dtm für alle ohne TF-IDF
  #   Dafür aber Stopwortliste verwenden!
  writeLines(paste("(",k,"/",m,")Creating DTMs without any weights", sep=""))
  TVT_max_nowei <- bs$text2dtmModelsNoWei(maxSet[[1]], maxSet[[2]], maxSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                     docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating DTMs without any weights", sep=""))
  TVT_bal_nowei <- bs$text2dtmModelsNoWei(balSet[[1]], balSet[[2]], balSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                     docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating DTMs without any weights", sep=""))
  TVT_real_nowei <- bs$text2dtmModelsNoWei(realSet[[1]], realSet[[2]], realSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating DTMs without any weights", sep=""))
  TVT_repr_nowei <- bs$text2dtmModelsNoWei(reprSet[[1]], reprSet[[2]], reprSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating DTMs without any weights", sep=""))
  TVT_qual_nowei <- bs$text2dtmModelsNoWei(qualSet[[1]], qualSet[[2]], qualSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                           docProportionMin=docProportionMin, nGram = nGram, dotestset = T)
  k <- k+1
  
  #   3.3 Spezial dtm zusätzlich für einzelne Modelle, z.B. NB (weniger Parameter)
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with only ",vocabTermMax," Terms", sep=""))
  TVT_max_tiRed <- bs$text2dtmModels(maxSet[[1]], maxSet[[2]], maxSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                  docProportionMin=docProportionMin, nGram = nGram, dotestset = T, vocabTermMax=vocabTermMax)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with only ",vocabTermMax," Terms", sep=""))
  TVT_bal_tiRed <- bs$text2dtmModels(balSet[[1]], balSet[[2]], balSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                  docProportionMin=docProportionMin, nGram = nGram, dotestset = T, vocabTermMax=vocabTermMax)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with only ",vocabTermMax," Terms", sep=""))
  TVT_real_tiRed <- bs$text2dtmModels(realSet[[1]], realSet[[2]], realSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                   docProportionMin=docProportionMin, nGram = nGram, dotestset = T, vocabTermMax=vocabTermMax)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with only ",vocabTermMax," Terms", sep=""))
  TVT_repr_tiRed <- bs$text2dtmModels(reprSet[[1]], reprSet[[2]], reprSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                   docProportionMin=docProportionMin, nGram = nGram, dotestset = T, vocabTermMax=vocabTermMax)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with only ",vocabTermMax," Terms", sep=""))
  TVT_qual_tiRed <- bs$text2dtmModels(qualSet[[1]], qualSet[[2]], qualSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = nGram, dotestset = T, vocabTermMax=vocabTermMax)
  k <- k+1
  
  #   3.4 2-grams
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with 1- and 2-Grams", sep=""))
  TVT_max_2gr <- bs$text2dtmModels(maxSet[[1]], maxSet[[2]], maxSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                     docProportionMin=docProportionMin, nGram = 2, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with 1- and 2-Grams", sep=""))
  TVT_bal_2gr <- bs$text2dtmModels(balSet[[1]], balSet[[2]], balSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                     docProportionMin=docProportionMin, nGram = 2, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with 1- and 2-Grams", sep=""))
  TVT_real_2gr <- bs$text2dtmModels(realSet[[1]], realSet[[2]], realSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = 2, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with 1- and 2-Grams", sep=""))
  TVT_repr_2gr <- bs$text2dtmModels(reprSet[[1]], reprSet[[2]], reprSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = 2, dotestset = T)
  k <- k+1
  writeLines(paste("(",k,"/",m,")Creating TF-IDF weighted DTMs with 1- and 2-Grams", sep=""))
  TVT_qual_2gr <- bs$text2dtmModels(qualSet[[1]], qualSet[[2]], qualSet[[3]], TermCountMin = TermCountMin, docProportionMax = docProportionMax, 
                                      docProportionMin=docProportionMin, nGram = 2, dotestset = T)
  k <- k+1
  
  
  returnlist <- list(
    TVT_max_tfidf, TVT_bal_tfidf, TVT_real_tfidf, TVT_repr_tfidf, TVT_qual_tfidf,
    TVT_max_nowei, TVT_bal_nowei, TVT_real_nowei, TVT_repr_nowei, TVT_qual_nowei,
    TVT_max_tiRed, TVT_bal_tiRed, TVT_real_tiRed, TVT_repr_tiRed, TVT_qual_tiRed,
    TVT_max_2gr  , TVT_bal_2gr  , TVT_real_2gr  , TVT_repr_2gr  , TVT_qual_2gr
  )
  names(returnlist) <- c("TVT_max_tfidf", "TVT_bal_tfidf", "TVT_real_tfidf", "TVT_repr_tfidf", "TVT_qual_tfidf",
                         "TVT_max_nowei", "TVT_bal_nowei", "TVT_real_nowei", "TVT_repr_nowei", "TVT_qual_nowei",
                         "TVT_max_tiRed", "TVT_bal_tiRed", "TVT_real_tiRed", "TVT_repr_tiRed", "TVT_qual_tiRed",
                         "TVT_max_2gr"  , "TVT_bal_2gr"  , "TVT_real_2gr"  , "TVT_repr_2gr"  , "TVT_qual_2gr")
  
  return(returnlist)
}
