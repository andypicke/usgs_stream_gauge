#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This is a Shiny web application to view USGS stream gauge data
#
# andypicke@gmail.com
# 2024-10-15
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~
# Libraries
#~~~~~~~~~~~

library(shiny)
library(bslib)
library(dataRetrieval)
library(DT)
library(leaflet)
#library(ggplot2)
library(plotly)




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define UI
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ui <- page_sidebar(
  theme = bs_theme(bootswatch = "simplex"),
  title = "USGS Stream Gauge Viewer",
  
  sidebar = sidebar(
    # Date range input
    dateRangeInput(inputId = "date_range", 
                   label = "Date range To View:", 
                   start = Sys.Date() - 20 , 
                   end = Sys.Date() - 1,
                   max = Sys.Date()),
    # select state
    selectInput(inputId = "wh_state", 
                label = "State", 
                choices = state.name),
    # select station to get data for and plot
    selectInput(inputId = "station_id", 
                label = "Choose Station", 
                choices = "", 
                selected = NULL, 
                selectize = FALSE  )
  ), # sidebar
  
  # tabs in main panel
  navset_card_underline(
    
    # Leaflet map
    nav_panel(title = "Site Map",
              leafletOutput("site_map")
    ),
    
    # timeseries plot from one station
    # nav_panel(title = "Timeseries Plot", 
    #           plotOutput("ts_plot")
    # ),
    
    # Plotly plot
    nav_panel(title = "Timeseries Plot",
              plotlyOutput("ts_plot")
              ),
    
    # Data table
    nav_panel(title = "Site Info Table", 
              DTOutput("station_table")
    ),
    
    nav_panel(title = "Station Data Table", 
              DTOutput("site_table")
    ),
    
    
    # 
    # nav_panel("Both Plots",
    #           layout_column_wrap(
    #             width = 1,
    #             card(
    #               card_header("Plot 1"),
    #               leafletOutput("site_map2")
    #             ),
    #             card(
    #               card_header("Plot 2"),
    #               plotOutput("ts_plot")
    #             )
    #           )
    # ),
    
    # About tab
    nav_panel("About", 
              h3("A Shiny App to View stream gauge data",),
              h5(a("https://github.com/andypicke/usgs_stream_gauge_viewer")),
              h5(a("https://andypicke.shinyapps.io/usgs_stream_gauge_viewer/"))
    ),
    full_screen = TRUE
  ) # navset_card_underline
) # page_fluid






#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Define server 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
server <- function(input, output) {
  
  # get list of the stations for chosen state and start date
  station_info <- reactive({
    dataRetrieval::whatNWISsites(stateCd = input$wh_state, 
                                 startDt = input$date_range[1],
                                 parameterCd = "00060" ) # discharge parameter code
  })  
  
  # update selectInput choices for station numbers based on state selection
  observe({
    updateSelectInput(
      inputId = "station_id",
      choices = sort(unique(station_info()$station_nm))
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
  
  # make leaflet map of sites for chosen state
  output$site_map2 <- renderLeaflet({
    leaflet(data = station_info() ) |>
      addProviderTiles(provider = providers$CartoDB.Voyager) |>
      addMarkers(lat = ~dec_lat_va, lng = ~dec_long_va,
                 popup = paste0(station_info()$station_nm, "<br>", station_info()$site_no ) ,
                 clusterOptions = markerClusterOptions())
  })
  
  
  # get data for a selected site
  site_data <- reactive({
    readNWISuv(siteNumbers = station_info()$site_no[which(station_info()$station_nm == input$station_id)],
               parameterCd = "00060",
               startDate = input$date_range[1],#"2024-09-20",
               endDate = input$date_range[2] ) |>
      renameNWISColumns()
  })
  
  
  # make datatable of site data for selected site
  output$site_table <- renderDT({
    DT::datatable(site_data() )
  },server = FALSE)
  
  
  # make plot of timeseries for one stations : ggplot
  # output$ts_plot <- renderPlot({
  #   
  #   parameterInfo <- attr(site_data(), "variableInfo")
  #   siteInfo <- attr(site_data(), "siteInfo")
  #   
  #   site_data() |>
  #     ggplot(aes(x = dateTime, y = Flow_Inst)) +
  #     geom_line() +
  #     ylab(parameterInfo$variableDescription) +
  #     ggtitle(siteInfo$station_nm)
  # })
  
  
  # make plot of timeseries for one stations : plotly
  output$ts_plot <- plotly::renderPlotly({
    parameterInfo <- attr(site_data(), "variableInfo")
    siteInfo <- attr(site_data(), "siteInfo")
    
    site_data() |>
      plot_ly(x = ~dateTime, y = ~Flow_Inst, type = "scatter", name = "Discharge") |>
#      add_lines(x = lubridate::ymd("2024-09-26"), y = range(site_data()$Flow_Inst, na.rm = TRUE),
#                line = list(color = "red", dash = "dash"), name = "Landfall") |>
      layout(
        title = siteInfo$station_nm,
        yaxis = list(title = parameterInfo$variableDescription)
      )
  })
  
} # SERVER




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run the application 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shinyApp(ui = ui, server = server)
