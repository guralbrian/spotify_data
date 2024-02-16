# Clean/process raw extended data from json_to_df_extended.R

# Load libraries
libs <- c("tidyverse", "lubridate")
lapply(libs, require, character.only = T)
rm(libs)

# List the person of interest
#! could be made into a command arg
person <- "Steve_Tufaro"
df <- read.csv(paste0("data_private/raw/individuals/", person, "/extended/extended_raw.csv"))


# Add annotation data
# Formats to dates, makes more convenient names, removes null artist
df <- df %>%
  mutate(endTime = lubridate::ymd_hms(ts),
         endTime = lubridate::with_tz(endTime, tzone = "America/New_York"),
         minute  = lubridate::minute(endTime),
         hour    = lubridate::hour(endTime),
         month   = lubridate::month(endTime, label = T),
         year    = lubridate::year(endTime),
         date    = lubridate::date(endTime),
         hoursPlayed = ms_played / 3600000,
         artistName = master_metadata_album_artist_name,
         trackName = master_metadata_track_name,
         msPlayed = ms_played) %>% 
  subset(!is.na(artistName))

# Subset to relevant columns
df <- df |> 
  select(endTime, trackName, artistName, msPlayed, reason_start, reason_end, 
         shuffle, skipped, platform, spotify_track_uri, minute, hour, month, year)

# Estimate the duration of each track
track.library <- df |>
  group_by(spotify_track_uri) |> 
  subset((reason_start == "trackdone" | 
            reason_start == "clickrow"  |
            reason_start == "fwdbtn"    |  
            reason_start == "backbtn")  &
           reason_end == "trackdone") |> 
  mutate(trackLength = max(msPlayed)) |> 
  arrange(desc(trackLength), .by_group = T) |> 
  slice_head(n = 1) |> 
  ungroup() |> 
  select(spotify_track_uri, trackLength) |> 
  subset(trackLength != 0)

# Merging the two data frames
df <- df |> 
  left_join(track.library, by = "spotify_track_uri") |> 
  mutate(percent_listened = msPlayed / trackLength) |> 
  subset(percent_listened <= 1)

# Save
write.csv(df, paste0("/home/rstudio/data_private/raw/individuals/", person, "/extended/extended_clean.csv"), row.names = F)
write.csv(df, paste0("/home/rstudio/data_private/raw/individuals/", person, "/shiny/extended_clean.csv"), row.names = F)
