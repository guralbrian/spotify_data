library("shiny")
source('global.R', local = T)
#### UI section ####
ui <- fluidPage(
  
  titlePanel("Malaria facility visualisation app"),
  
  sidebarLayout(
    sidebarPanel(
      dateRangeInput('dateRange',
                     label = 'Date range input: yyyy-mm-dd',
                     start = "2017-01-01", end = Sys.Date()
      ),
      
    ),
    
    mainPanel(
      # epicurve goes here
      plotOutput("top_artists")
    )
    
  )
)

#### Server section ####
server <- function(input, output, session) {
  
 output$top_artists <- renderPlot(
    plotArtists(data = df, date.range.1 = input$dateRange[1], date.range.2 = input$dateRange[2])
  )
}

shinyApp(ui = ui, server = server)
