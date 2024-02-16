# Load data
libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis", "ggrepel")
lapply(libs, require, character.only = T)
rm(libs)

# Load data
id <- 'Steve_Tufaro'
name <- str_split(id, "_")[[1]][1]
df <- read.csv(paste0("/home/rstudio/data_private/raw/individuals/", id, "/extended/extended_clean.csv"))
df$endTime <- lubridate::with_tz(df$endTime, tzone = "America/New_York")
# Replace split artists for Herside Story
df[which(df$trackName == "Herside Story"), "artistName"] <- "GoldLink"

plotArtists <- function(data, date.range.1, date.range.2){
  # Format for artists
  top.artists <- data %>%
    filter(endTime >= date.range.1 & endTime <= date.range.2) |> 
    group_by(artistName) %>%
    summarise(plays = sum(as.numeric(percent_listened))) %>%
    arrange(desc(plays))%>%
    head(10) |> 
    pull(artistName)
  
  pal <- pals::kelly(10)
  names(pal) <- top.artists
  
  total.artist <- data %>%
    filter(endTime >= date.range.1 & endTime <= date.range.2) |> 
    group_by(artistName) %>%
    summarise(plays = sum(as.numeric(percent_listened))) %>%
    arrange(desc(plays))%>%
    head(10) 
  
  # make custom palette & set plotting order
  data$trackName_wrap = str_wrap(data$trackName, width = 20)
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
  
  # make custom palette 
  data$trackName_wrap = str_wrap(data$trackName, width = 20)
  
  # Plot top tracks     
  p.top.tracks <- data |>
    filter(endTime >= date.range.1 & endTime <= date.range.2) |> 
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
      legend.position = c(0.8, 0.4),
      legend.background = element_rect(fill="white",
                                       size=0.5, linetype="solid", 
                                       colour ="black"),
      axis.title.y = element_blank()
    )
  design <- "A
             B" 
  w.artist <- wrap_plots( 
    A = p.total.artist,  
    B = p.top.tracks, design = design)
  w.artist
}
