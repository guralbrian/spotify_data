library("shiny")
source('global.R', local = T)
#### UI section ####
ui <- fluidPage(theme="simplex.min.css",
            tags$style(type="text/css",
                       "label {font-size: 12px;}",
                       ".recalculating {opacity: 1.0;}"
            ),
            
  titlePanel("Top Spotify tracks & artists by time period"),
  
  fluidRow(
    column(6,
      dateRangeInput('dateRange.1',
                     label = 'Date range input: yyyy-mm-dd',
                     start = "2017-01-01", end = Sys.Date())),
    column(6,
      dateRangeInput('dateRange.2',
                     label = 'Date range input: yyyy-mm-dd',
                     start = "2017-01-01", end = Sys.Date()))
          ),
  fluidRow(
    column(6, plotOutput("top_artists_1")),
    column(6, plotOutput("top_artists_2"))
    )
)

#### Server section ####
server <- function(input, output, session) {
  
 output$top_artists_1 <- renderPlot(
    plotArtists(data = df, date.range.1 = input$dateRange.1[1], date.range.2 = input$dateRange.1[2]),
    height = 1000, width = 500
  )
 output$top_artists_2 <- renderPlot(
   plotArtists(data = df, date.range.1 = input$dateRange.2[1], date.range.2 = input$dateRange.2[2]),
   height = 1000, width = 500
 )
}

shinyApp(ui = ui, server = server)
