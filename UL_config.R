# Config Datei für Projekt 04_Clustering
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(caret)
library(Rtsne)
library(text2vec)
library(cluster)
library(plotly)

source("scripts/create_dtm_from_text.R")
source("scripts/t2v_data_preparation.R")

ger_stopwords <- readRDS('data/stopwords/ger_stopwords_oeff.rds')
colorchange <- c("#E41A1C" ,"#377EB8" ,"#4DAF4A", "#FF7F00" , "#984EA3" , "#FFFF33")
colorkmeans <- c("#377EB8", "#4DAF4A", "#984EA3", "#E41A1C")
