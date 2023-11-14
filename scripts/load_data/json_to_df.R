# This script is meant to be the first step in our analysis pipeline
# It serves to load the JSON files of listening history and convert them to a format I'm more comfortable with: dataframes

library("rjson")
library("tidyverse")

person <- "June_White"
# List all files that match the pattern "StreamingHistory*.json" in the folder

files <- list.files(paste0("data_private/raw/individuals/", person, "/short/MyData"), 
                    pattern = "StreamingHistory.*\\.json$", 
                    full.names = TRUE)

# Load and merge them into a single tibble
merged_df <- files %>%
  lapply(jsonlite::fromJSON) %>%  
  bind_rows() %>%
  as_tibble()

# Save the data
write.csv(merged_df, paste0("data_private/raw/individuals/", person, "/short/MyData/listen_history_1year.csv"), row.names = F)



