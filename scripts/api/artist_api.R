library('spotifyr')
library('tidyverse')

Sys.setenv(SPOTIFY_CLIENT_ID = 'c754a384dab5409faec10df188bbe142')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'd69521cc39664c59a85ed16f18aeae41')

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
.getArtistDf <- function(x){data <- spotifyr::get_artist_audio_features(x) |> 
                            as.data.frame() |> 
                            dplyr::select(-album_images, -artists, - available_markets)
                            print(paste0(which(art.subset == x), ": ", x))
                            return(data)}
# Fetch data
art.ft <- lapply(art.subset, function(x) {
  return(tryCatch(
    .getArtistDf(x) ,
    error = function(e) NULL
  ))
})

# Merge into one df
art.ft.df <- bind_rows(art.ft) 


# Save the output to an RDS file
write.csv(art.ft.df, paste0("data/attributes/batched_slurm/art_ft_", start_index, "_", end_index, ".csv"), row.names = F)
