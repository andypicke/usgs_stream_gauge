# A Shiny app to view USGS Stream Gauge Data

## About

Try out the app at: <https://andypicke.shinyapps.io/usgs_stream_gauge_viewer/>

-   User can choose a state and date range
-   Uses {dataRetrieval} to find and retrieve stream gauge data.
-   App displays a map of all stations, and plot of chosen individual station.

## Using the app:

-   Select a state from the sidebar menu on the left
-   Select a date range (default is last 20 days)
-   The *Site Map* tab will show a map of all the stations with discharge data for the chosen state and date range. Clicking on a marker will display the station name.
-   Select a station to look at from the drop-down menu; the options will populate based on the state and date range chosen.
-   The *Plot* tab will display a timeeries of streamflow from the selected station.
-   Datatables are also available for the sites and station data.
