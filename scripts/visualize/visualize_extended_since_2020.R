# Make visuals for top artists/tracks

# load libraries
libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis")
lapply(libs, require, character.only = T)
rm(libs)

# Load data
id <- 'Sarah_Lester'
name <- str_split(id, "_")[[1]][1]
df <- read.csv(paste0("/home/rstudio/data_private/raw/individuals/", id, "/extended_clean.csv")) 
# Format for artists
top.artists <- df %>%
  group_by(artistName) %>%
  summarise(plays = sum(as.numeric(percent_listened))) %>%
  arrange(desc(plays))%>%
  head(10) |> 
  pull(artistName)

pal <- pals::kelly(10)
names(pal) <- top.artists

total.artist <- df %>%
  group_by(artistName) %>%
  summarise(plays = sum(as.numeric(percent_listened))) %>%
  arrange(desc(plays))%>%
  head(10) 

# make custom palette 

df$trackName_wrap = str_wrap(df$trackName, width = 20)


#Turn your 'treatment' column into an ordered factor 
total.artist$artistName <-  factor(total.artist$artistName, levels=top.artists)


# Get listening time by artist
p.total.artist <- total.artist |> 
  ggplot(aes(x = artistName, y = plays, fill = artistName)) +
  geom_col(colour="black") +
  coord_flip() +
  scale_fill_manual(values = pal) +
  scale_x_discrete(limits = rev(levels(total.artist$artistName))) + 
  xlab("Artist") +
  ylab("Total Plays") +
  ggtitle("Total Plays Per Artist") +
  theme_minimal() +
  theme(
    legend.position = "none"
  )

# summarise by date
yearly.artists <-  df |> 
  subset(artistName %in% top.artists) |> 
  mutate(date_only = as.Date(endTime))

#Turn artist into an ordered factor 
yearly.artists$artistName <-  factor(yearly.artists$artistName, levels=top.artists)


p.yearly.artists <- yearly.artists |> 
  ggplot(aes(x = date_only, y = artistName, group = artistName)) +
  geom_density_ridges(aes(fill = artistName), 
                      inherit.aes = T,
                      scale = 1.2,
                      color = "black") +
  scale_fill_manual(values=as.vector(kelly(10))) +
  scale_y_discrete(limits = rev(levels(yearly.artists$artistName))) +
  labs(title = "When artists were played overall",
       x = "Date") +
  theme_minimal() +
  theme(
    strip.background = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    axis.text.y = element_blank(),
    axis.title.y = element_blank()
  )

# Plot and save

design <- "DGG" 
w.artist <- wrap_plots( 
  D = p.total.artist,  
  G = p.yearly.artists, design = design)

png_path_1 <- (paste0("/home/rstudio/results/individuals/", id, "/artist_all.png"))
if(file.exists(png_path_1) == F) {
png(png_path_1, width = 14, height = 8, units = "in", res = 300)}
w.artist + plot_annotation(title = paste0(name, "'s Top Artists of all time"),
                           theme = theme(plot.title = element_text(size = 25)))

dev.off()


#### Top tracks and temporal trends ####

df <- df %>%
  mutate(endTime = ymd_hms(endTime))
df$time_of_day <- lubridate::hour(df$endTime) + lubridate::minute(df$endTime) / 60
df$day_of_week <- weekdays(df$endTime)

# Reorder so that they don't plot alphabetically
df$day_of_week <- factor(df$day_of_week, 
                             levels = c("Sunday", "Monday", "Tuesday", 
                                        "Wednesday", "Thursday", "Friday", 
                                        "Saturday"))

p.daily <- df |> 
  filter(!is.na(day_of_week)) |> 
  ggplot( aes(x = time_of_day, fill = day_of_week)) +
  geom_density(alpha = 0.5) +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks = c(0,6,12,18,24),
                     limits = c(0,24)) +
  scale_y_continuous(breaks = c(0,0.06,0.12),
                     limits = c(0,0.22)) +
  facet_wrap(~ day_of_week, ncol = 1,
             strip.position = "right") +
  labs(title = "Daily listening density",
       x = NULL, 
       y = NULL) +
  theme_minimal() +
  theme(
    strip.background = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    axis.text.y = element_blank()
  )
# make custom palette 
df$trackName_wrap = str_wrap(df$trackName, width = 20)


# Plot top tracks     
p.top.tracks <- df |>
  group_by(trackName_wrap, artistName) |> 
  summarise(plays = sum(as.numeric(percent_listened))) |> 
  ungroup() |> 
  slice_max(n = 20, order_by = plays) %>%
  ggplot(aes(x = reorder(trackName_wrap, plays), y = plays, fill = artistName)) +
  geom_col(colour="black") +
  coord_flip() +
  scale_fill_manual(values=as.vector(kelly(20)))  +
  ylab("Total Plays") +
  ggtitle("Top 20 Most Listened Tracks") +
  labs(fill="Artist") +
  theme_minimal() + 
  theme(
    legend.position = c(0.9, 0.4),
    legend.background = element_rect(fill="white",
                                     size=0.5, linetype="solid", 
                                     colour ="black"),
    axis.title.y = element_blank()
  )


# Save plot
design <- "AB
           AB" 
w.person <- wrap_plots(A = p.top.tracks,  B = p.daily, 
                       design = design)

png_path_2 <- png_path_1 <- (paste0("/home/rstudio/results/individuals/", id, "/tracks_daily_all.png"))
if(file.exists(png_path_2) == F) {
png(png_path_2, width = 14, height = 8, units = "in", res = 300)}


w.person + plot_annotation(title = paste0(name, "'s favorite music and listening times of all time"),
                           theme = theme(plot.title = element_text(size = 25)))

dev.off()
