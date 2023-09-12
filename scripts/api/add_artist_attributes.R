# Script to check which artists are in a person's top 500 but not in the attributes df

library('spotifyr')
library('tidyverse')

# Get the commandArgs

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
ind <- args[1]
client_id <- args[2]
client_secret <- args[3]
attribute.csv <- args[4]

# Set Spotify credentials
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Load current artist attributes list
art.attr <- read.csv(paste("data/attributes/batched_slurm", attribute.csv, sep = "/"), row.names = 1)

# Individual listening data
# List the individual
ind.list <- read.csv(paste("data/raw/individuals", ind, "listen_history_1year.csv", sep = "/"), row.names = 1)


# Get individual's top 500 artists

art.top <- ind.list |>
  group_by(artistName) |>
  summarise(min_played = sum(as.numeric(msPlayed)/(1000*60))) |> 
  arrange(desc(min_played)) |> 
  top_n(500) |> 
  pull(artistName)

# List artists that aren't found in the existing attributes data
artists.needed <- art.top[!(art.top %in% art.attr$artist_name)]


# Function to get arist features and return as a dataframe
.getArtistDf <- function(x){data <- spotifyr::get_artist_audio_features(x) |> 
  as.data.frame() |> 
  dplyr::select(-album_images, -artists, - available_markets)
print(paste0(which(art.subset == x), ": ", x))
return(data)}

# Fetch data
art.ft <- lapply(artists.needed, function(x) {
  return(tryCatch(
    .getArtistDf(x) ,
    error = function(e) NULL
  ))
})

# Merge into one df
art.ft.df <- bind_rows(art.ft) 

art.ft.all <- rbind(art.ft.df, art.attr)

# Save the output to an RDS file
write.csv(art.ft.df, paste0("data/attributes/batched_slurm/art_ft_", length(unique(art.ft.all$artist_name)), ".csv"), row.names = F)





