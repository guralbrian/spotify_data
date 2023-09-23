# This script is meant to be the first step in our analysis pipeline
# It serves to load the JSON files of listening history and convert them to a format I'm more comfortable with: dataframes

library("rjson")
library("tidyverse")

person <- "garias"
# List all files that match the pattern "StreamingHistory*.json" in the folder
files_to_load <- list.files(paste0("data/raw/individuals/", person), pattern = "StreamingHistory.*\\.json$", full.names = TRUE)

# Load and merge them into a single tibble
merged_df <- files_to_load %>%
  lapply(jsonlite::fromJSON) %>%  
  bind_rows() %>%
  as_tibble()

# Save the data
write.csv(merged_df, paste0("data/raw/individuals/", person, "/listen_history_1year.csv"))



