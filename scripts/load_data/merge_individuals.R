# Make merged dataset of everyone's listening data
library(dplyr)

# List directories for individuals
dirs <- list.files("data/raw/individuals")


# Load all of the 1 year listening history
merged <- lapply(dirs, function(individual) {
  data <- read.csv(file.path("data/raw/individuals", individual, "listen_history_1year.csv"),
                   row.names = 1)
  data$individual <- individual # Add individual ID
  return(data)
})


# bind them together
merged <- dplyr::bind_rows(merged)

# Save them
write.csv(merged, "data/merged_datasets/many_individuals/queer_cult.csv", row.names = F)
