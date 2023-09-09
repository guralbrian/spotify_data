# A properly formatted R script for making a shiny app to visualize spotify song attributes

##### Loading and libraries ####

# Load libraries
libs <- c("tidyverse", "gplots", "viridis", "factoextra", "shiny", "DT", "magrittr", "dplyr")
lapply(libs, require, character.only = T)

# Load data
lis.df <- read.csv("bg_1y_t500.csv")
def.attr <- read.csv("attribute_definitions.csv")

##### Data processing ####

## Subset data
met.df <- lis.df %>% 
  select(
    track_name, min_played, artist_name, album_release_date, danceability, energy, key,
    loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo)


## Heatmap prep
num.df <- met.df |> 
  dplyr::select(-track_name, -artist_name, -album_release_date) 

## PCA prep

pca.df <- met.df |>  
  dplyr::mutate(track_artist = paste(track_name, artist_name, sep = "_")) |> 
  dplyr::group_by(track_artist) |> 
  dplyr::slice_head(n = 1) |> 
  tibble::column_to_rownames("track_artist") |> 
  dplyr::select(-album_release_date, -artist_name, -track_name, -mode)  %>%
  dplyr::ungroup() %>%
  dplyr::mutate(across(everything(), as.numeric))

pca.out <- pca.df |> 
  dplyr::select(-min_played) |> 
  t() |> 
  stats::prcomp() 

pca.out <- pca.out$rotation |>
  merge(pca.df, by = 0)

## Scale for silhouette plot

scaled.df <- pca.df |> 
  dplyr::select(-min_played) |> 
  scale()

## Kmeans prep

scaled.km <- stats::kmeans(x = scaled.df, centers = 2)

pca.df$cluster <- scaled.km$cluster


##### Define Static Plots ####

# UI
ui <- fluidPage(
  titlePanel("Attributes and Listening Correlations"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("x_var", "X-axis:", choices = colnames(num.df)),
      selectInput("y_var", "Y-axis:", choices = colnames(num.df)),
      selectInput("dot_color_by", "Color points by:", choices = colnames(num.df)),
      selectInput("pca_color", "Color points by:", choices = colnames(pca.df)),
      selectInput("hist_var", "Plot Density plot of:", choices = colnames(pca.df))
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Correlation Heatmap", plotOutput("heatmapPlot")),
        tabPanel("Interactive 3D plot", plotOutput("scatterPlot")),
        tabPanel("PCA", plotOutput("pcaPlot")),
        tabPanel("Dimensional Reduction Silhouette", plotOutput("silhouettePlot")),
        tabPanel("K-means Clustering", plotOutput("kmeansPlot")),
        tabPanel("Cluster Details", plotOutput("densityPlot"))
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  output$heatmapPlot <- renderPlot({
    cor(num.df) |> 
      gplots::heatmap.2(col = "viridis", margins = c(10,10), trace = "none")
  })
  
  output$attrScatterPlot <- renderPlot({
    ggplot(num.df, aes_string(x = input$x_var, y = input$y_var, color = input$color_by)) +
      geom_point(alpha = 0.3) +
      scale_color_viridis() +
      labs(title = "Correlation of music attributes") +
      theme(legend.position = "none") +
      theme_minimal()
  })
  
  output$pcaPlot <- renderPlot({
    ggplot(pca.out, aes_string(x = "PC1", y = "PC2", color = input$pca_color)) +
      geom_point(alpha = 0.3) +
      scale_color_viridis() +
      labs(title = "PCA of music attributes") +
      theme(legend.position = "none") +
      theme_minimal()
  })
  
  output$silhouettePlot <- renderPlot({
    fviz_nbclust(x = scaled.df, 
                 FUNcluster = kmeans,
                 method = 'silhouette')
  })
  output$kmeansPlot <- renderPlot({
    factoextra::fviz_cluster(object = scaled.km,
                             data = pca.df, labelsize = 1)
  })
  
  output$densityPlot <- renderPlot({
    ggplot(pca.df, aes(x = get(input$hist_var), fill = as.factor(cluster))) +
      geom_density(alpha = 0.3) +
      theme_minimal() +
      labs(x = as.character(input$hist_var), y = "Frequency", fill = "Cluster")
  })
  
}

# Run the app
shinyApp(ui, server)
