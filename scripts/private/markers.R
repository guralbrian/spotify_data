# Markers
libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis", "ggrepel", "gt")
lapply(libs, require, character.only = T)
rm(libs)

id <- "Steve_Tufaro"
name <- str_split(id, "_")[[1]][1]
df <- read.csv(paste0("/home/rstudio/data_private/raw/individuals/", id, "/extended/extended_clean.csv"))

# Replace split artists for Herside Story
df[which(df$trackName == "Herside Story"), "artistName"] <- "GoldLink"

# Prepare the data
df <- df %>% 
  mutate(endTime = as.POSIXct(endTime, format="%Y-%m-%d %H:%M"),
         day_of_year = yday(endTime)) %>% 
  arrange(year, endTime) %>%
  group_by(year) %>%
  mutate(cumulative_time = cumsum(as.numeric(msPlayed)) / (1000 * 60 * 60 * 24),
         unique_artists = cumsum(!duplicated(artistName)),
         cumulative_plays = cumsum(as.numeric(percent_listened)))  # convert ms to minutes


df <- df |> 
  group_by(year) |> 
  arrange(desc(endTime)) |> 
  slice_head(n = 1) |> 
  mutate(label = year) |> 
  right_join(df)
# Define Seasons
df$quarter <- case_when(
  lubridate::month(df$endTime) %in% c(1, 2, 3)  ~ 'Q1',
  lubridate::month(df$endTime) %in% c(4, 5, 6)  ~ 'Q2',
  lubridate::month(df$endTime) %in% c(7, 8, 9) ~ 'Q3',
  lubridate::month(df$endTime) %in% c(10, 11, 12) ~ 'Q4',
  TRUE ~ 'Unknown'
)

# Calculate the total and variance of listening time per artist per individual
artist_stats <- df %>%
  mutate(year_q = paste(year, quarter, sep = " - ")) %>% 
  group_by(year_q, artistName) %>%
  summarise(
    total_plays = sum(percent_listened),
    var_plays = var(percent_listened)
  ) %>%
  subset(total_plays >= 5)  # remove artists played less that 3 times

# Calculate the between-individual variance for each artist
between_var <- artist_stats %>%
  group_by(artistName) %>%
  summarise(between_var = var(total_plays)) 

# Join the within-individual and between-individual stats
artist_stats <- left_join(artist_stats, between_var, by = "artistName")


# Step 1: Identify the top 200 artists for each year
top_100_artists <- artist_stats %>%
  group_by(year_q) %>%
  arrange(desc(total_plays)) %>%
  slice_head(n = 200) %>%
  ungroup()

# Step 2: Identify artists that appear in the top 20 of more than one season
top_20_artists <- artist_stats %>%
  group_by(year_q) %>%
  arrange(desc(total_plays)) %>%
  slice_head(n = 20) %>%
  ungroup() %>%
  count(artistName) %>%
  filter(n > 2) 

# Step 2.5: Identify artists that appear in the top 5 of more than one group
top_5_artists <- artist_stats %>%
  group_by(year_q) %>%
  arrange(desc(total_plays)) %>%
  slice_head(n = 5) %>%
  ungroup() %>%
  count(artistName) %>%
  filter(n > 1) 

# Step 3: Identify artists that are unique after removing top 25 artists from any other year
unique_artists <- top_100_artists %>%
  anti_join(top_20_artists, by = "artistName") %>%
  anti_join(top_5_artists, by = "artistName")

# Step 4: Arrange by between-individual variance (if needed)
unique_top_artists <- unique_artists %>%
  group_by(year_q) |> 
  arrange(desc(between_var)) |> 
  slice_head(n = 50) |> 
  arrange(desc(total_plays)) |> 
  slice_head(n = 15) |> 
  select(year_q, artistName)

markers <- unique_top_artists %>%
  group_by(year_q) %>%
  mutate(marker_rank = row_number()) %>%
  ungroup() %>%
  filter(marker_rank <= 15) %>%  # Selecting top 10 unique markers for each individual
  select(year_q, marker_rank, artistName) %>%
  pivot_wider(names_from = year_q, values_from = artistName) %>%
  arrange(marker_rank)


colnames(markers)[1] <- c("Marker Rank")

write.csv(markers, paste0("~/results/individuals/", id, "/yr_seas_art_markers.csv"), row.names = F)


# Calculate the total and variance of listening time per track per individual
q_totals <- df %>%
  mutate(year_q = paste(year, quarter, sep = " - ")) %>% 
  group_by(year_q, spotify_track_uri) %>%
  summarise(
    plays_quarter = sum(percent_listened))

year_totals <- df %>%
  group_by(spotify_track_uri) %>%
  summarise(
    plays_total = sum(percent_listened)
  ) 

track_stats <- df %>%
  mutate(year_q = paste(year, quarter, sep = " - ")) |> 
  left_join(q_totals) |> 
  left_join(year_totals) |> 
  mutate(
    q_proportion = plays_quarter / plays_total
  ) |> 
  group_by(spotify_track_uri, year_q) |> 
  slice_head(n=1)

# Calculate the between-individual variance for each track
# New metric, get the proportion of plays within each q
# Q play time / Total play time 


# Step 1: Identify the top 100 tracks for each quarter
top_100_tracks <- track_stats %>%
  group_by(year_q) %>%
  arrange(desc(plays_quarter)) %>%
  slice_head(n = 100) %>%
  ungroup()

# Step 2: Identify tracks that appear in the top 20 of more than three seasons
top_20_tracks <- track_stats %>%
  group_by(year_q) %>%
  arrange(desc(plays_quarter)) %>%
  slice_head(n = 20) %>%
  ungroup() %>%
  count(trackName) %>%
  filter(n > 3) 

# Step 2.5: Identify tracks that appear in the top 5 of more than one group
top_5_tracks <- track_stats %>%
  group_by(year_q) %>%
  arrange(desc(plays_quarter)) %>%
  slice_head(n = 5) %>%
  ungroup() %>%
  count(trackName) %>%
  filter(n > 1) 

# Step 3: Identify tracks that are unique after removing top 25 tracks from any other year
unique_tracks <- top_100_tracks %>%
  anti_join(top_20_tracks, by = "trackName") %>%
  anti_join(top_5_tracks, by = "trackName")

# Step 4: Arrange by between-individual variance
unique_top_tracks <- unique_tracks %>%
  group_by(year_q) |> 
  arrange(q_proportion) |> 
  slice_head(n = 40) |> 
  arrange(desc(plays_quarter)) |> 
  slice_head(n = 15) |> 
  select(year_q, trackName)

markers <- unique_top_tracks %>%
  group_by(year_q) %>%
  mutate(marker_rank = row_number()) %>%
  ungroup() %>%
  filter(marker_rank <= 10) %>%  # Selecting top 10 unique markers for each individual
  select(year_q, marker_rank, trackName) %>%
  pivot_wider(names_from = year_q, values_from = trackName) %>%
  arrange(marker_rank)
markers <- markers[,-c(2,3)]

colnames(markers)[1] <- c("Track Rank")
marker.table <- markers |> 
  gt(rowname_col = "Track Rank") |> 
  tab_spanner(
    label = "2016",
    columns = contains("2016"),
    level = 1,
    id = "year_2016"
  ) |> 
  tab_spanner(
    label = "2017",
    columns = contains("2017"),
    level = 1,
    id = "year_2017"
  ) |> 
  tab_spanner(
    label = "2018",
    columns = contains("2018"),
    level = 1,
    id = "year_2018"
  )|> 
  tab_spanner(
    label = "2019",
    columns = contains("2019"),
    level = 1,
    id = "year_2019"
  )|> 
  tab_spanner(
    label = "2020",
    columns = contains("2020"),
    level = 1,
    id = "year_2020"
  )|> 
  tab_spanner(
    label = "2021",
    columns = contains("2021"),
    level = 1,
    id = "year_2021"
  )|> 
  tab_spanner(
    label = "2022",
    columns = contains("2022"),
    level = 1,
    id = "year_2022"
  )|> 
  tab_spanner(
    label = "2023",
    columns = contains("2023"),
    level = 1,
    id = "year_2023"
  )|> 
  tab_spanner(
    label = "2024",
    columns = contains("2024"),
    level = 1,
    id = "year_2024"
  ) |> 
  cols_label(
    contains("Q1") ~ "Q1",
    contains("Q2") ~ "Q2",
    contains("Q3") ~ "Q3",
    contains("Q4") ~ "Q4",
  ) |> 
  cols_align(
    align = "center") |> 
  data_color(
    columns = ends_with(c("2", "4")),
    palette = "#EDEDFB")

gtsave(marker.table, paste0("~/results/individuals/", id, "/marker_table.html"))
write.csv(markers, paste0("~/results/individuals/", id, "/yr_seas_art_markers.csv"), row.names = F)
