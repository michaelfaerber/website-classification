# generiere Stopwords
# Erstellung einer deutscher Stopwordliste
library(stopwords)
library(readr)
library(tidytext)

if (exists("bs") == F) {
  bs <- new.env()
}


bs$stopwords.DeNpoTec <- function(){
  aaa <- readRDS('data/stopwords/ger_stopwords_oeff.rds')
  aaa
}

bs$stopwords.full <- function(){
  aaa <- readRDS('data/stopwords/ger_stopwords_oeff.rds')
  aaa
}


