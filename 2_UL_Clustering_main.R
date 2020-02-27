# Clusteringverfahren für Trainingsdaten
source('UL_config.R')

#####  Load preselecte sample
sample_clust <- readRDS("data/Clustering/mysample_PNC_for_Clustering.RDS")
sample_clust <- readRDS("data/Train_PNC_full_20191008.rds")
sample_clustF <- sample_clust %>% filter(handchecked == 1)

#Create dtm (Train & Test are the same here):
cl_TrainVal <- bs$text2dtmwPrep(sample_clustF, sample_clustF, TermCountMin = 30, docProportionMax = 0.5, 
                                docProportionMin=0.02, nGram = 1, dotestset = F, vocabTermMax = 500 )

########################
# k-means
####### Determine nr of clusters

silhouette_score <- function(k){
  km <- kmeans(cl_TrainVal[[1]], centers = k, nstart=25)
  ss <- silhouette(km$cluster, dist(cl_TrainVal[[1]]))
  mean(ss[, 3])
}
k <- 2:10
avg_sil <- sapply(k, silhouette_score)
plot(k, type='b', avg_sil, xlab='Number of clusters', ylab='Average Silhouette Scores', frame=FALSE)

set.seed(1337)
clustering.kmeans <- kmeans(cl_TrainVal[[1]], 4  )

########################
#hierarchical: DIANA
set.seed(1337)
dianaclust <- diana(as.matrix(cl_TrainVal[[1]]))
clustering.diana6 <- cutree(dianaclust, k = 6)


########################
# t-SNE
set.seed(13)
tsne2D <- Rtsne(as.matrix(cl_TrainVal[[1]]), dims = 2, perplexity=20, verbose=TRUE, pca = T, max_iter = 2500, check_duplicates = FALSE)
tsne_plot2D <- data.frame(x = tsne2D$Y[,1], y = tsne2D$Y[,2], domain = rownames(as.matrix(cl_TrainVal[[1]]), do.NULL = TRUE)) %>%
  left_join(sample_clust, by="domain") %>% select(x,y,domain,category,catkey)


# t-SNE-Plot with class-label
plot_ly(x=tsne_plot2D$x, y=tsne_plot2D$y, text =tsne_plot2D$domain , type="scatter", mode="markers", 
        color=tsne_plot2D$category, colors = brewer.pal(4,"Set1"), hoverinfo = 'text')


# t-SNE-Plot with k-Means
plot_ly(x=tsne_plot2D$x, y=tsne_plot2D$y, text =tsne_plot2D$domain , type="scatter", mode="markers", 
        color=as.factor(unname(clustering.kmeans$cluster)), colors = colorkmeans, hoverinfo = 'text')


# t-SNE-Plot with DIANA
plot_ly(x=tsne_plot2D$x, y=tsne_plot2D$y, text =tsne_plot2D$domain , type="scatter", mode="markers", 
        color=as.factor(unname(clustering.diana6)), colors = colorchange, hoverinfo = 'text')




######## Confusionmatrix Cluster DIANA ##########
Diana_mapped <- data.frame(cluster = clustering.diana6) %>% 
  mutate(category = if_else(cluster == 1, 'K', if_else(cluster == 2, 'N', if_else(cluster == 3,'P', if_else(cluster == 5,'S','Rest' )))))
labels_prepared <- as.factor(sample_clust$category)
levels(labels_prepared) <- c('K', 'N', 'P', 'S', 'Rest')

x= as.factor(Diana_mapped$category)
x = factor(x,levels(x)[c(1:3,5,4)])

confMdiana <- caret::confusionMatrix(x, labels_prepared)
confMdiana
#Macro-F1:
(confMdiana$byClass[1,7] + confMdiana$byClass[2,7] + confMdiana$byClass[3,7] + confMdiana$byClass[4,7])/4

######## Confusionmatrix Cluster kmeans ##########
Kmeans_mapped <- data.frame(cluster = clustering.kmeans$cluster ) %>% 
  mutate(category = if_else(cluster == 2, 'P', if_else(cluster == 4, 'K', if_else(cluster == 3,'S', 'N'))))

confMkmeans <- caret::confusionMatrix(as.factor(Kmeans_mapped$category), as.factor(sample_clust$category))
confMkmeans
