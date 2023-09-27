library("jsonlite")
library("tidyverse")

person <- "rsharp"

# List files for the first type of naming, e.g., "Streaming_History_Audio_2018_3.json"
first_type_files <- list.files(paste0("data/raw/individuals/", person, "/extended/MyData"), 
                               pattern = "Streaming_History_Audio_\\d{4}_\\d+\\.json$", 
                               full.names = TRUE)

# Load and merge them into a single tibble for the first type
first_type_df <- first_type_files %>%
  lapply(jsonlite::fromJSON) %>%
  bind_rows() %>%
  as_tibble()

# Save the data for the first type
write.csv(first_type_df, paste0("data/raw/individuals/", person, "/extended/MyData/listen_history_a.csv"))

# Get the json files not in the first list
second_type_files <- list.files(paste0("data/raw/individuals/", person, "/extended/MyData"), 
           pattern = "(StreamingHistory.*\\.json$)|(\\d{4}_\\d+\\.json$)|(Streaming_History_Audio_\\d{4}_\\d+\\.json$)", 
           full.names = TRUE)
second_type_files <- second_type_files[!(second_type_files %in% first_type_files)]

# Load and merge them into a single tibble for the second type
second_type_df <- second_type_files %>%
  lapply(jsonlite::fromJSON) %>%
  bind_rows() %>%
  as_tibble()

# Save the data for the second type
write.csv(second_type_df, paste0("data/raw/individuals/", person, "/extended/MyData/listen_history_b.csv"))
