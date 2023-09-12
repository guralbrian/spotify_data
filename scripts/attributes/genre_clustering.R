# Load required libraries
library(tidyverse)
library(factoextra)
library(ggrepel)
library(GGally)

# Read data
genre.df <- read.csv("data/attributes/batched_slurm/art_genre_1_425.csv")
attr.df <- read.csv("data/merged_datasets/bg_1y_t500.csv")
time.df <- read.csv("data/raw/listen_history_1year.csv", row.names = 1)

# Merge genres and attributes, then separate genres into rows
merged.df <- left_join(attr.df, genre.df, by = c("artist_id" = "id")) |> 
  separate_rows(genres, sep = ", ")

# Scale data and perform hierarchical clustering
scaled.data <- scale(merged.df[, c("danceability", "energy", "key", "loudness", "mode", "speechiness", "acousticness", "instrumentalness", "liveness", "valence", "tempo")])
hclust.result <- hclust(dist(scaled.data), method = "complete")
plot(hclust.result, labels = merged.df$genres, cex = 0.6, hang = -1)


## Picking cluster numbers
# Silhouette method to find optimal cluster number
fviz_nbclust(x = scaled.data, FUNcluster = kmeans, method = 'silhouette')

# Run PCA and plot elbow plot
pca.result <- prcomp(scaled.data, center = TRUE, scale. = TRUE)
var.explained <- cumsum(pca.result$sdev^2 / sum(pca.result$sdev^2))
num.components <- which(var.explained >= 0.9)[1]

# Perform k-means clustering on selected PCs
kmeans.result <- kmeans(pca.result$x[, 1:num.components], centers = 6)  # Adjust centers as needed
merged.df$cluster <- kmeans.result$cluster

# Merge time data with clustering results
merged_time_df <- inner_join(time.df, merged.df, by = c("trackName" = "track_name", "artistName" = "artist_name"))

# Summarize total listening time by cluster and genre, then get top genres
top_genres <- merged_time_df |> 
  group_by(cluster, genres) |> 
  summarise(total_msPlayed = sum(msPlayed), .groups = 'drop') |> 
  arrange(-total_msPlayed) |> 
  group_by(cluster) |> 
  slice_head(n = 5)

##### Revised code ####

# Step 2: Assign Genres to Clusters
# First, create a new data frame that separates the genres for each track
genre_track_df <- merged.df %>%
  select(track_name, artist_name, cluster, genres) %>%
  separate_rows(genres, sep = ", ")

# Now, for each genre, find the most common cluster
genre_cluster_df <- genre_track_df %>%
  group_by(genres, cluster) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  slice_head(n = 1) %>%
  ungroup()


#### Prep to save ###

merged_df <- merged_time_df |> 
  select(endTime, msPlayed, trackName, artistName, cluster, artist_id, followers, popularity, 
         album_release_date, track_id, ) |> 
  distinct(endTime, trackName, artistName, msPlayed, .keep_all = T)

write.csv(merged_df, "data/merged_datasets/bg_1y_time_clustered.csv", row.names = F)



# Visualize the cluster info

library(GGally)
#ggpairs(data.frame(scaled.data, Cluster = as.factor(merged.df$cluster)), 
#        aes(color = Cluster), lower = list(continuous = "points")) +
#  theme_minimal()
  

# Vizualize top genres by playtime within clusters

# Summarize data to get total playtime for each genre within each cluster
summary_df <- merged_time_df %>%
  group_by(cluster, trackName) %>%
  summarise(total_msPlayed = sum(msPlayed)) %>%
  arrange(cluster, desc(total_msPlayed)) %>%
  group_by(cluster) %>%
  slice_head(n = 5) %>%
  ungroup() %>%
  mutate(total_hoursPlayed = total_msPlayed / 3600000)

summary_df$trackName <- stringr::str_wrap(summary_df$trackName , 5)

# Create the dodged bar plot
ggplot(summary_df, aes(x = as.factor(cluster), y = total_hoursPlayed, fill = trackName)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text_repel(aes(label = trackName, y = total_hoursPlayed), 
            position = position_dodge(width = 0.9),
            point.size = NA,
            vjust = -0.5,
            box.padding = 0.5,
            segment.curvature = -0.1,
            segment.ncp = 3,
            segment.angle = 20,
            size = 2) +
  labs(title = "Top 3 Genres by Playtime within Each Cluster",
       x = "Cluster",
       y = "Total Playtime (hours)") +
  theme_minimal() +
  theme(
    legend.position = "none"
  )


# Count the frequency of each genre within each cluster
genre_frequency_df <- merged_time_df %>%
  subset(genres != "") |> 
  group_by(cluster, trackName) %>%
  summarise(freq = n()) %>%
  arrange(desc(freq)) 

# Get the top 3 genres within each cluster by frequency
top_genres_df <- genre_frequency_df %>%
  group_by(cluster) %>%
  arrange(desc(freq)) |> 
  slice_head(n = 5) %>%
  ungroup()

top_genres_df$genres <- stringr::str_wrap(top_genres_df$genres, 3)

# Create the dodged bar plot
ggplot(top_genres_df, aes(x = cluster, 
                          y = freq, 
                          fill = reorder(genres, desc(freq)))) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  geom_text_repel(aes(label = genres, y = freq), 
            position = position_dodge(width = 0.9),
            color = "black",
            point.size = NA,
            vjust = -0.5,
            box.padding = 0.5,
            segment.curvature = -0.1,
            segment.ncp = 3,
            segment.angle = 20,
            size = 2) +
  labs(title = "Top 3 Genres by Frequency within Each Cluster",
       x = "Cluster",
       y = "Frequency") +
  theme_minimal() +
  theme(
    legend.position = 'none'
  )

