library('spotifyr')
library('tidyverse')

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
start_index <- as.integer(args[1])
end_index <- as.integer(args[2])
client_id <- args[3]
client_secret <-  args[4]

# Set Spotify credentials
Sys.setenv(SPOTIFY_CLIENT_ID = client_id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = client_secret)

access_token <- get_spotify_access_token()

# Access spotify data by artists
lis.df <- read.csv("data/list_attr/bg_1y_t500.csv")

art.top <- lis.df |> 
  pull(artist_id) |> 
  unique()


# Function to get arist features and return as a dataframe
.getArtistDf <- function(x){data <- spotifyr::get_artist(x)
    data[["followers"]] <- data[["followers"]][["total"]]
    data[["genres"]] <- paste(data[["genres"]] , collapse=', ') # collapse list
    data <- data[c(2:5, 7:length(data))] |> 
      as.data.frame()
    return(data)}


# Fetch data
art.ft <- lapply(art.top, function(x) {
  return(tryCatch(
    .getArtistDf(x) ,
    error = function(e) NULL
  ))
})

# Merge into one df
art.ft.df <- bind_rows(art.ft) 


# Save the output to an RDS file
write.csv(art.ft.df, paste0("data/attributes/batched_slurm/art_genre_", 1, "_", length(art.top), ".csv"), row.names = F)
