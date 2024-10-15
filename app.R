#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This is a Shiny web application to view USGS stream gauge data
#
# andypicke@gmail.com
# 2024-10-15
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(shiny)
library(bslib)
library(dataRetrieval)
library(DT)
library(leaflet)
library(ggplot2)




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
    selectInput(inputId = "station_id", label = "Station Number", choices = "02479500", selected = NULL, selectize = FALSE  )
  ), # sidebar
  
  navset_card_underline(
    
    # Leaflet map
    nav_panel("Site Map", leafletOutput("site_map")),
    
    # Data table
    nav_panel("Site Info", DTOutput("station_table")),

    nav_panel("Data Table2", DTOutput("site_table")),
    
    nav_panel("Plot", plotOutput("ts_plot")),
    
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
  
  # get list of the stations for chosen state
  station_info <- reactive({
    dataRetrieval::whatNWISsites(stateCd = input$wh_state, 
                                 parameterCd = "00060" ) # discharge parameter code
  })  
  
  # update selectInput choices for station numbers based on state selection
  observe({
    updateSelectInput(
      inputId = "station_id",
      choices = unique(station_info()$site_no)
    )
  })
  
  
  # make datatable of sites for chosen state
  output$station_table <- renderDT({
    DT::datatable(station_info() )
    },server = FALSE)
  
  
  # make leaflet map of sites for chosen state
  output$site_map <- renderLeaflet({
    leaflet(data = station_info() ) |>
      addProviderTiles(provider = providers$CartoDB.Voyager) |>
      addMarkers(lat = ~dec_lat_va, lng = ~dec_long_va,
                 popup = paste0(station_info()$station_nm, "<br>", station_info()$site_no ) ,
                 clusterOptions = markerClusterOptions())
  })
  
  
  
  # get data for a selected site
  site_data <- reactive({
    readNWISuv(siteNumbers = input$station_id,
                        parameterCd = "00060",
                        startDate = input$date_range[1],#"2024-09-20",
                        endDate = input$date_range[2] ) |>
    renameNWISColumns()
  })
  
  
  # make datatable of site data for selected site
  output$site_table <- renderDT({
    DT::datatable(site_data() )
  },server = FALSE)
  
  
  output$ts_plot <- renderPlot({
    site_data() |>
      ggplot(aes(x = dateTime, y = Flow_Inst)) +
      geom_line()
  })
  
} # SERVER




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run the application 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shinyApp(ui = ui, server = server)
