library("jsonlite")
library("tidyverse")

person <- "malhaddad"

# List files for the first type of naming, e.g., "Streaming_History_Audio_2018_3.json"
first_type_files <- list.files(paste0("data/raw/individuals/", person, "/extended/MyData"), 
                               pattern = ".json$", 
                               full.names = TRUE)

# Load and merge them into a single tibble for the first type
first_type_df <- first_type_files %>%
  lapply(jsonlite::fromJSON) %>%
  bind_rows() %>%
  as_tibble()

# Save the data for the first type
write.csv(first_type_df, paste0("data/raw/individuals/", person, "/extended/MyData/listen_history_a.csv"))
