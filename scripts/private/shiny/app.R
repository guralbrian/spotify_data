library("shiny")

#### UI section ####
ui <- fluidPage(
  
  titlePanel("Malaria facility visualisation app"),
  
  sidebarLayout(
    
    sidebarPanel(
      # selector for district
      selectInput(
        inputId = "year", # what the server will call it
        label = "Year", # What the user sees
        choices = c(
          "2016",
          "2017",
          "2018",
          "2019",
          "2020",
          "2021",
          "2022",
          "2023",
          "2024"
        ),
        selected = "All",
        multiple = T
      )
    ),
    
    mainPanel(
      # epicurve goes here
      plotOutput("top_artists")
    )
    
  )
)
