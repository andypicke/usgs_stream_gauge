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
library(DT)
library(leaflet)




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define UI
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
                choices = state.name),
    
    textInput(inputId = "wh_station",label = "Station ID")
  ), # sidebar
  
  navset_card_underline(
    
    # Leaflet map
    nav_panel("Plot", leafletOutput("site_map")),
    
    # Data table
    nav_panel("Data Table", DTOutput("station_table")),
    
    # About
    nav_panel("About", 
              h3("A Shiny App to View stream gauge data",),
              h5("text")
    ),
    full_screen = TRUE
  ) #navset_card_underline
  
  
) # page_fluid






#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define server 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
server <- function(input, output) {
  
  # get list of stations for specfified state
  station_info <- reactive({
    dataRetrieval::whatNWISsites(stateCd = input$wh_state, 
                                 parameterCd = "00060" ) # discharge parameter code
  })  
  
  # make datatable of sites
  output$station_table <- renderDT({
    DT::datatable(station_info() )
    },server = FALSE)
  
  
  # make leaflet map of sites
  output$site_map <- renderLeaflet({
    leaflet(data = station_info() ) |>
      addProviderTiles(provider = providers$CartoDB.Voyager) |>
      addMarkers(lat = ~dec_lat_va, lng = ~dec_long_va,
                 popup = paste0(station_info()$station_nm, "<br>", station_info()$site_no ) ,
                 clusterOptions = markerClusterOptions())
  })
  
  
  # get data for one site
  
  
  
} # SERVER




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run the application 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shinyApp(ui = ui, server = server)
