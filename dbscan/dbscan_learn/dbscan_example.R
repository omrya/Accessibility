#install.packages("fpc")
#install.packages("dbscan")
library(factoextra)
library(dbscan)
library(fpc)

data("multishapes", package = "factoextra")
df <- multishapes[, 1:2]

set.seed(123)

db <- fpc::dbscan(df, eps = 0.1, MinPts = 5)

fviz_cluster(db, data = df, stand = FALSE,
             ellipse = FALSE, show.clust.cent = FALSE,
             geom = "point",palette = "jco", ggtheme = theme_classic())

dbscan::kNNdistplot(df, k =  5)
abline(h = 0.15, lty = 2)
