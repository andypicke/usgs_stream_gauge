#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This is a Shiny web application to view USGS stream gauge data
#
#
#
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(shiny)
library(bslib)
library(dataRetrieval)

# Define UI for application that draws a histogram
ui <- page_sidebar(
  theme = bs_theme(bootswatch = "simplex"),
  title = "USGS Stream Gauge Viewer",
  
  sidebar = sidebar(
    # Date input ; Default value is the date in client's time zone
    dateRangeInput(inputId = "date_range", 
              label = "Date range To View:", 
              start = Sys.Date() - 10 , 
              end = Sys.Date() - 1,
              max = Sys.Date()),
    # select variable to plot map of
    selectInput(inputId = "wh_state", 
                label = "State", 
                choices = state.name)
  ),
  
  navset_card_underline(
    
    # Leaflet map
    nav_panel("Plot" ),
    
    # Data table
    nav_panel("Data Table" ),
    
    # About
    nav_panel("About", 
              h3("A Shiny App to View stream gauge data",),
              h5("text")
    ),
    full_screen = TRUE
  ) #navset_card_underline
  
  
) # page_fluid

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
