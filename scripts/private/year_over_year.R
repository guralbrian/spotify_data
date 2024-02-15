
libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis", "ggrepel")
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

pal <- brewer.pal(length(unique(df$year)), "Set3")
names(pal) <- unique(df$year)

# Create the plot
p.cum.time <- ggplot(df, aes(x = day_of_year, y = cumulative_time, color = as.factor(year))) +
  geom_line(size = 2)  +
  labs(title = "Total listening time",
       subtitle = "Running sum of time spent listening to Spotify, by year",
       x = "Day in year",
       y = "Cumulative Listening Time (days)") +
  theme_minimal() +
  scale_color_manual(values=as.vector(watlington(length(unique(df$year))))) +
  theme(text = element_text(size = 15),
        axis.title = element_text(size = 18),
        title = element_text(size = 18, hjust = 0.5),
        legend.position = 'none',
        plot.margin = unit(c(1,3,0,0), "cm")) +
  coord_cartesian(clip = 'off') +
  ggrepel::geom_label_repel(aes(label = label), 
                            family = "Spline Sans Mono",
                            xlim = c(420, 420),
                            hjust = "right",
                            # style segment
                            segment.curvature = .001,
                            segment.inflect = TRUE, 
                            direction = 'y',
                            force_pull = 0.4,
                            force = 2,
                            size = 6,
                            fill = "white") 
# Create the plot
p.cum.plays <- ggplot(df, aes(x = day_of_year, y = cumulative_plays, color = as.factor(year))) +
  geom_line(size = 2)  +
  labs(title = "Total Plays",
       subtitle = "Running sum of tracks played in Spotify, by year",
       x = "Day in year",
       y = "Cumulative Plays") +
  theme_minimal() +
  scale_color_manual(values=as.vector(watlington(length(unique(df$year))))) +
  theme(text = element_text(size = 15),
        axis.title = element_text(size = 18),
        title = element_text(size = 18, hjust = 0.5),
        legend.position = 'none',
        plot.margin = unit(c(1,3,0,0), "cm")) +
  coord_cartesian(clip = 'off') +
  ggrepel::geom_label_repel(aes(label = label), 
                            family = "Spline Sans Mono",
                            xlim = c(420, 420),
                            hjust = "right",
                            # style segment
                            segment.curvature = .001,
                            segment.inflect = TRUE, 
                            direction = 'y',
                            force_pull = 0.4,
                            force = 2,
                            size = 6,
                            fill = "white") 

# plot unique artists 

# Create the plot
p.cum.art <- ggplot(df, aes(x = day_of_year, y = unique_artists, color = as.factor(year))) +
  geom_line(size = 2)  +
  labs(title = "Total artists played",
       subtitle = "Running tally of how many unique artists\nover each year",
       x = "Day in the year",
       y = "Number of artists") +
  theme_minimal() +
  scale_color_manual(values=as.vector(watlington(length(unique(df$year))))) +
  theme(text = element_text(size = 15),
        axis.title = element_text(size = 18),
        title = element_text(size = 18, hjust = 0.5),
        legend.position = 'none',
        plot.margin = unit(c(1,3,0,0), "cm"),
        plot.subtitle = element_text(size = 16)) +
  coord_cartesian(clip = 'off') +
  ggrepel::geom_label_repel(aes(label = label), 
                            family = "Spline Sans Mono",
                            xlim = c(420, 420),
                            hjust = "right",
                            # style segment
                            segment.curvature = .001,
                            segment.inflect = TRUE, 
                            direction = 'y',
                            force_pull = 0.4,
                            force = 2,
                            size = 6,
                            fill = "white") 



png_path <- paste0("/home/rstudio/results/individuals/", person,"/year_over_year.png") 

png(png_path, width = 14, height = 10, units = "in", res = 300)

wrap_plots(p.cum.plays, p.cum.time, ncol = 2) + 
  plot_annotation(theme = theme(plot.title = element_text(size = 25, hjust = 0.5)))

dev.off()

