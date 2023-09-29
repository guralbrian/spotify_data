libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis", "jsonlite")
lapply(libs, require, character.only = T)
rm(libs)


person <- "rsharp"

# List files for the first type of naming, e.g., "Streaming_History_Audio_2018_3.json"
first_type_files <- list.files(paste0("data/raw/individuals/", person, "/extended/MyData"), 
                               pattern = ".json$", 
                               full.names = TRUE)

# Load and merge them into a single tibble for the first type
first_type_df <- first_type_files |> 
  lapply(jsonlite::fromJSON) |> 
  bind_rows() |> 
  as_tibble()

# Save the data for the first type
write.csv(first_type_df, paste0("data/raw/individuals/", person, "/extended/MyData/listen_history_a.csv"))

# Add annotation data
df <- first_type_df %>%
  mutate(endTime = lubridate::ymd_hms(ts),
         endTime = lubridate::with_tz(endTime, tzone = "America/New_York"),
         minute  = lubridate::minute(endTime),
         hour    = lubridate::hour(endTime),
         month   = lubridate::month(endTime, label = T),
         year    = lubridate::year(endTime),
         hoursPlayed = ms_played / 3600000,
         artistName = master_metadata_album_artist_name,
         trackName = master_metadata_track_name,
         msPlayed = ms_played) %>% 
  subset(!is.na(artistName))

# Subset to relevant columns
df <- df |> 
  select(endTime, trackName, artistName, msPlayed, reason_start, reason_end, shuffle, skipped, platform, spotify_track_uri, minute, hour, month, year)

# Estimate the duration of each track
trackLibrary <- df |>
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

# Merging the two dataframes
df <- df |> 
  left_join(trackLibrary, by = "spotify_track_uri") |> 
  mutate(percent_listened = msPlayed / trackLength) |> 
  subset(percent_listened <= 1)

write.csv(df, paste0("~/data/raw/individuals/", person, "/extended/MyData/cleaned_hist.csv"), row.names = F)
