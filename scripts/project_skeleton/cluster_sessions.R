# Cluster sessions

# Make smaller, demo matrix
sess_small <- expression_matrix[,as.numeric(colnames(expression_matrix))%%10 == 0] |>
              t() 
install.packages("kernlab")

# Spectral clustering 
pca.r <- prcomp(sess_small, center = T)$x |> 
  as_tibble()


library(kernlab)

# Perform spectral clustering
spectral_clustering <- specc(as.matrix(sess_small), centers = 5)

cluster_assignments <- spectral_clustering@.Data

library(umap)
umap_result <- umap(as.matrix(sess_small), n_neighbors = 30, n_components = 2)
plot(umap_result$layout, col = cluster_assignments, pch = 19)
