# A USGS Stream Gauge Viewer

## About

A Shiny app to view USGS stream gauge stations and streamflow data. The app uses the {dataRetrieval} package to find and retrieve stream gauge data. The app was inspired by a [blog post](https://andypicke.quarto.pub/portfolio/posts/helene_stream_gauges/helene_stream_gauge.html) I wrote looking at some stream gauge data in North Carolina during Hurricane Helene. The default settings are for North Carolina during this period, but the app can be used to view data for any state and time period.

You can try out the app at: <https://andypicke.shinyapps.io/usgs_stream_gauge_viewer/>

Feel free to submit any issues here on the github repo.

## Using the app:

-   Select a date range and state on the left sidebar menu. The choices for Station will update to reflect available stations with those parameters.
-   The *Site Map* tab will show a map of all the stations with discharge data for the chosen state and date range. Clicking on a marker will display the station name and id.
-   Select a station to look at from the drop-down menu.
-   The *Timeseries Plot* tab will display a timeseries of streamflow from the selected station. The plot is interactive so you can zoom/pan/hover etc..
-   Datatables are also available for the sites and station data in the other tabs.
