# Load data
libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis", "ggrepel")
lapply(libs, require, character.only = T)
rm(libs)

# Load data
id <- 'Steve_Tufaro'
name <- str_split(id, "_")[[1]][1]
df <- read.csv(paste0("/home/rstudio/data_private/raw/individuals/", id, "/extended/extended_clean.csv"))

# Replace split artists for Herside Story
df[which(df$trackName == "Herside Story"), "artistName"] <- "GoldLink"

plotArtists <- function(input_years){
  # Format for artists
  top.artists <- df %>%
    filter(year %in% input_years) |> 
    group_by(artistName) %>%
    summarise(plays = sum(as.numeric(percent_listened))) %>%
    arrange(desc(plays))%>%
    head(10) |> 
    pull(artistName)
  
  pal <- pals::kelly(10)
  names(pal) <- top.artists
  
  total.artist <- df %>%
    filter(year %in% input_years) |> 
    group_by(artistName) %>%
    summarise(plays = sum(as.numeric(percent_listened))) %>%
    arrange(desc(plays))%>%
    head(10) 
  
  # make custom palette & set plotting order
  df$trackName_wrap = str_wrap(df$trackName, width = 20)
  total.artist$artistName <-  factor(total.artist$artistName, levels=top.artists)
  
  # Get listening time by artist
  total.artist |> 
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
  
}
