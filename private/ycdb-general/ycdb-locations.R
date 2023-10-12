
library(leaflet)
library(leaflet.extras)
library(leafem)
library(jsonlite)
library(htmltools)


# loc.bh <- fromJSON("http://golang.oakridgeswater.ca:8080/locwell/") # too large
loc.met <- fromJSON("http://golang.oakridgeswater.ca:8080/locmet/")
loc.gw <- fromJSON("http://golang.oakridgeswater.ca:8080/locgw/")
loc.sw <- fromJSON("http://golang.oakridgeswater.ca:8080/locsw/")
ormgp.bound <- readLines("https://www.dropbox.com/s/lrdycz5eomw09hr/ORMGP_Area_20210205-Drawing-simplWGS.geojson?dl=1") %>% paste(collapse = "\n")

m <- leaflet() %>%
  addTiles(group='OSM', options = providerTileOptions(
    updateWhenZooming = FALSE,      # map won't update tiles until zoom is done
    updateWhenIdle = TRUE           # map won't load new tiles when panning
  )) %>%
  addFullscreenControl() %>%
  # addMouseCoordinates() %>%
  # addCircles(layerId = ~LOC_ID,
  #            lng = ~LONG, lat = ~LAT,
  #            label = ~NAME,
  #            popup = ~paste0(NAME,': ',ALTERNATE_NAME)) %>%
  addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%
  addCircles(data = loc.met,
             color = "darkred",
             layerId = ~LOC_ID,
             lng = ~LONG, lat = ~LAT,
             label = ~LOC_NAME,
             popup = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1),
             # popup = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1,
             #                 '<br><a href="https://owrc.shinyapps.io/shydrograph/?t=3&i=',INT_ID,'">Open Shiny analysis</a'
             # ),
             group = "Weather station") %>%
  addCircles(data = loc.sw,
             layerId = ~LOC_ID,
             lng = ~LONG, lat = ~LAT,
             label = ~LOC_NAME,
             popup = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1),
             # popup = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1,
             #                 '<br><a href="https://owrc.shinyapps.io/shydrograph/?t=5&i=',INT_ID,'">Open Shiny analysis</a'
             # ),
             group = "Stream gauge") %>%
  addCircles(data = loc.gw,
             color = "#e08924",
             layerId = ~LOC_ID,
             lng = ~LONG, lat = ~LAT,
             label = ~LOC_NAME,
             popup = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1),
             # popup = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1,
             #                 '<br><a href="https://owrc.shinyapps.io/shydrograph/?i=',INT_ID,'">Open Shiny analysis</a'
             # ),
             group = "Groundwater monitor") %>%
  setView(lng = -78.7, lat = 44.2, zoom = 8) %>%
  addLayersControl(
    overlayGroups = c("Groundwater monitor", "Stream gauge", "Weather station"),
    options = layersControlOptions(collapsed = FALSE)
  )

htmlwidgets::saveWidget(m, "ycdb-general/ycdb-locations.html")
