library('spotifyr')
library('tidyverse')

Sys.setenv(SPOTIFY_CLIENT_ID = '8c01ce0a82c94358b40b8d7fc6d9abbd')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '5f80c0f3c6264cdfa1150e3b303db6bf')

access_token <- get_spotify_access_token()

# Access spotify data by artists
lis.his <- read.csv("data/raw/listen_history_1year.csv", row.names = 1)

art.top <- lis.his |>
  group_by(artistName) |>
  summarise(min_played = sum(as.numeric(msPlayed)/(1000*60))) |> 
  arrange(desc(min_played)) |> 
  top_n(3600) |> 
  pull(artistName)

# Get command line arguments for the range of artists to process
args <- commandArgs(trailingOnly = TRUE)
start_index <- as.integer(args[1])
end_index <- as.integer(args[2])

# Subset the artists based on the range
art.subset <- art.top[start_index:end_index]

# Function to get arist features and return as a dataframe
.getArtistDf <- function(x){spotifyr::get_artist_audio_features(x) |> 
                            as.data.frame() |> 
                            dplyr::select(-album_images)}
# Fetch data
art.ft <- lapply(art.subset, function(x) {
  return(tryCatch(
    .getArtistDf(x) ,
    error = function(e) NULL
  ))
})

# Merge into one df
art.ft <- bind_rows(art.ft)

# Save the output to an RDS file
write.csv(art.ft, paste0("data/attributes/batched_slurm/art_ft_", start_index, "_", end_index, ".csv"), row.names = F)

