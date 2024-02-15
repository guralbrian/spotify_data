# Load libraries
libs <- c("tidyverse", "jsonlite")
lapply(libs, require, character.only = T)
rm(libs)

# List the person of interest
#! could be made into a command arg
person <- "Steve_Tufaro"

# List json files
files <- list.files(paste0("data_private/raw/individuals/", person, "/extended"), 
                    pattern = ".json$", 
                    full.names = TRUE)

# Load and merge them into a single tibble and remove the ip addresses for privacy
df <- files |> 
  lapply(jsonlite::fromJSON) |> 
  bind_rows() |> 
  as_tibble() |> 
  select(-ip_addr_decrypted)

# Save the data for the first type
write.csv(df, paste0("data_private/raw/individuals/", person, "/extended/extended_raw.csv"), row.names = F)

