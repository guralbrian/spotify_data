# This script is meant to collect the audio features of spotify tracks
# It accesses the spotify API in 100-track batches

install.packages('spotifyr')
library('spotifyr')
library('tidyverse')

# Get command line arguments
args <- c("1",
          "200",
          "1821397780d04338a38341f6df655bbd",
          "bfe25a91f9234fbe8c3d47e1a79a6b4d")

start_index <- as.integer(args[1])
end_index <- as.integer(args[2])
client_id <- args[3]
client_secret <- args[4]

# Set Spotify credentials
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()


# Access spotify data by artists
id <- 'brian_gural'
name <- str_split(id, "_")[[1]][1]
df <- read.csv(paste0("/home/rstudio/data/raw/", id, "/extended_clean.csv"))

# Get track URIs, ordered by total plays
track.top <- df |>
  group_by(spotify_track_uri) |>
  summarise(plays = sum(as.numeric(percent_listened))) |> 
  arrange(desc(plays)) |> 
  pull(spotify_track_uri)

# Extract IDs from URIs
track.ids <- lapply(str_split(track.top, ":"),"[[", 3) 

# Get first instance 
audio.ft <- spotifyr::get_track_audio_features(track.ids[1]) %>% 
            as.data.frame()
# Decide # of tracks, in hundreds, & inititalize dataframe
tracks <- 250
audio.ft[2:tracks*100,] <- NA

# Make the API requests in 100 track batches
for(i in 1:tracks){
  audio.ft[(1+100*(i-1)):(100*i),] <- spotifyr::get_track_audio_features(track.ids[(1+100*(i-1)):(100*i)])
  print(i)
}

# Add back in track name + artist
ft.clean <- df %>% select(artistName, trackName, spotify_track_uri) %>% 
        group_by(spotify_track_uri) %>% 
        slice_head(n=1)
colnames(ft.clean)[3] <- "uri"

ft.clean <- left_join(audio.ft, ft.clean)

# Save the output to an RDS file
write.csv(ft.clean, paste0("/home/rstudio/data/api/track_attributes/", id, "_top_", tracks*100, ".csv"), row.names = F)
