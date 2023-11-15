id <- 'brian_gural'
name <- str_split(id, "_")[[1]][1]
df <- read.csv(paste0("/home/rstudio/data/raw/", id, "/extended_clean.csv"))
attr <- read.csv(paste0("/home/rstudio/data/api/track_attributes/", id, "_top_", 15000, ".csv"))


cum.lis <- df |>
  group_by(spotify_track_uri) |>
  summarise(plays = sum(as.numeric(percent_listened))) |> 
  arrange(desc(plays)) 
colnames(cum.lis)[1] <- "uri"

attr_selected <- attr %>%
  select(danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo, duration_ms, time_signature, uri) %>% 
  na.omit()

full_data <- left_join(attr_selected, cum.lis)

install.packages("lme4")
library(lme4)
install.packages("corrplot")
library(corrplot)


scaled_data <- full_data[,-14] %>%  
  subset(plays > 2) %>% 
    scale() %>% 
    as.data.frame() 

corrplot(corr, order = 'hclust', addrect = 3)

model <- lm(plays ~ ., data = scaled_data)

aov <- aov(model)
summary(aov)

plot(scaled_data$danceability, scaled_data$plays)
