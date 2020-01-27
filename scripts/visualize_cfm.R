# Visualisierung einer confusion Matrix in schönem Plot
if (!exists("bs")) {
  bs <- new.env()
}

library(ggplot2)
library(scales)

bs$ggplotConfusionMatrix <- function(m){
  p <-
    ggplot(data = as.data.frame(m$table) ,
           aes(x = Reference, y = factor(factor(Prediction), levels = rev(levels(factor(Prediction)))))) +
    geom_tile(aes(fill = log(Freq)), colour = "white") +
    scale_fill_gradient(low = "white", high = "#3DA2BC", na.value = "white") +          # Helleres blau / Türkis
    geom_text(aes(x = Reference, y = Prediction, label = Freq, size = 20)) +
    theme(legend.position = "none" ) +
    xlab("Referenzklasse") +
    ylab("Klassifizierung") +
    scale_x_discrete(labels = c('K', 'N', 'P', 'S') )+
    scale_y_discrete(labels = c('S', 'P', 'N', 'K') )+
    theme(axis.title=element_text(size=20))+
    theme(axis.text = element_text(size=15, face = "bold"))
  return(p)
}


