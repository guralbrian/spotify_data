# Clean/process raw extended data from json_to_df.R

# Load libraries
libs <- c("tidyverse", "lubridate")
lapply(libs, require, character.only = T)
rm(libs)

getwd()
# List the person of interest
#! could be made into a command arg
person <- "Anthony_Czarnik"
df <- read.csv(paste0("/home/rstudio/data_private/raw/individuals/", person, "/short/MyData/listen_history_1year.csv"))


# Add annotation data
# Formats to dates, makes more convenient names, removes null artist
df <- df %>%
  mutate(endTime = lubridate::ymd_hm(endTime),
         endTime = lubridate::with_tz(endTime, tzone = "America/New_York"),
         minute  = lubridate::minute(endTime),
         hour    = lubridate::hour(endTime),
         month   = lubridate::month(endTime, label = T),
         year    = lubridate::year(endTime),
         date    = lubridate::date(endTime),
         hoursPlayed = msPlayed / 3600000,
         artistTrack = paste0(artistName, "_", trackName)) %>% 
  subset(!is.na(artistName))


# Estimate the duration of each track
track.library <- df |>
  group_by(artistTrack) |> 
  mutate(trackLength = max(msPlayed)) |> 
  arrange(desc(trackLength), .by_group = T) |> 
  slice_head(n = 1) |> 
  ungroup() |> 
  select(artistTrack, trackLength)

# Merging the two data frames
df <- df |> 
  left_join(track.library, by = "artistTrack") |> 
  mutate(percent_listened = msPlayed / trackLength) |> 
  subset(percent_listened <= 1)

# Save
write.csv(df, paste0("/home/rstudio/data_private/raw/individuals/", person, "/short/MyData/extended_clean.csv"), row.names = F)
