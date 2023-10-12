library(leaflet)
library(leaflet.extras)
library(dplyr)
library(rgdal)


sws.ntwrk <- readLines("https://www.dropbox.com/s/cmzzownz046djij/owrc20-50a_SWS10_ntwrk.geojson?dl=1") %>% paste(collapse = "\n")
geojson <- readOGR("https://www.dropbox.com/s/ro16gg6zi4kqbc0/owrc20-50a_SWS10-final.geojson?dl=1",verbose = FALSE)
geojson$iperc <- as.numeric(factor(geojson$perm))

m <- leaflet(geojson) %>%
  addProviderTiles( providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE) ) %>%
  addFullscreenControl() %>%
  addPolygons(color="black",
              fillColor = ~colorQuantile("Purples", geojson$perimp)(perimp),
              fillOpacity = 1,
              weight = 2,
              popup = ~paste0('<b>sub-watershed: ',mmID,'</b>',
                              '<br>             area: ',round(Area/1000000,1),'km²',
                              '<br>     permeability: ',perm,
                              '<br> impervious cover: ',round(perimp*100,0),'%',
                              '<br>     canopy cover: ',round(percov*100,0),'%',
                              '<br> open water cover: ',round(perow*100,0),'%',
                              '<br>    wetland cover: ',round(perwl*100,0),'%'
              ),
              highlightOptions = highlightOptions(
                opacity = 1, fillOpacity =1, weight = 5, 
                sendToBack = FALSE),
              group = "Imperviousness"
  ) %>%
  addPolygons(color="black",
              fillColor = ~colorQuantile("YlGn", geojson$percov)(percov),
              fillOpacity = 1,
              weight = 2,
              popup = ~paste0('<b>sub-watershed: ',mmID,'</b>',
                              '<br>             area: ',round(Area/1000000,1),'km²',
                              '<br>     permeability: ',perm,
                              '<br> impervious cover: ',round(perimp*100,0),'%',
                              '<br>     canopy cover: ',round(percov*100,0),'%',
                              '<br> open water cover: ',round(perow*100,0),'%',
                              '<br>    wetland cover: ',round(perwl*100,0),'%'
              ),
              highlightOptions = highlightOptions(
                opacity = 1, fillOpacity =1, weight = 5, 
                sendToBack = FALSE),
              group = "Tree cover"
  ) %>%
  addPolygons(color="black",
              fillColor = ~colorQuantile("Blues", geojson$perow)(perow),
              fillOpacity = 1,
              weight = 2,
              popup = ~paste0('<b>sub-watershed: ',mmID,'</b>',
                              '<br>             area: ',round(Area/1000000,1),'km²',
                              '<br>     permeability: ',perm,
                              '<br> impervious cover: ',round(perimp*100,0),'%',
                              '<br>     canopy cover: ',round(percov*100,0),'%',
                              '<br> open water cover: ',round(perow*100,0),'%',
                              '<br>    wetland cover: ',round(perwl*100,0),'%'
              ),
              highlightOptions = highlightOptions(
                opacity = 1, fillOpacity =1, weight = 5, 
                sendToBack = FALSE),
              group = "Open water cover"
  ) %>%
  addPolygons(color="black",
              fillColor = ~colorQuantile("Oranges", geojson$perwl)(perwl),
              fillOpacity = 1,
              weight = 2,
              popup = ~paste0('<b>sub-watershed: ',mmID,'</b>',
                              '<br>             area: ',round(Area/1000000,1),'km²',
                              '<br>     permeability: ',perm,
                              '<br> impervious cover: ',round(perimp*100,0),'%',
                              '<br>     canopy cover: ',round(percov*100,0),'%',
                              '<br> open water cover: ',round(perow*100,0),'%',
                              '<br>    wetland cover: ',round(perwl*100,0),'%'
              ),
              highlightOptions = highlightOptions(
                opacity = 1, fillOpacity =1, weight = 5, 
                sendToBack = FALSE),
              group = "Wetland cover"
  ) %>%
  addPolygons(color="black",
              fillColor = ~colorFactor("Dark2", geojson$iperc)(iperc),
              fillOpacity = 1,
              weight = 2,
              popup = ~paste0('<b>sub-watershed: ',mmID,'</b>',
                              '<br>             area: ',round(Area/1000000,1),'km²',
                              '<br>     permeability: ',perm,
                              '<br> impervious cover: ',round(perimp*100,0),'%',
                              '<br>     canopy cover: ',round(percov*100,0),'%',
                              '<br> open water cover: ',round(perow*100,0),'%',
                              '<br>    wetland cover: ',round(perwl*100,0),'%'
              ),
              highlightOptions = highlightOptions(
                opacity = 1, fillOpacity =1, weight = 5, 
                sendToBack = FALSE),
              group = "Relative permeability"              
  ) %>%
  addGeoJSON(sws.ntwrk, weight = 3, color = "brown", opacity=1, group = "connectivity") %>%
  addLayersControl(
    overlayGroups = c("connectivity"),
    baseGroups = c("Imperviousness", "Tree cover","Wetland cover","Open water cover","Relative permeability"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>% hideGroup("connectivity") %>%
  setView(lng = -78.7, lat = 44.2, zoom = 8)


htmlwidgets::saveWidget(m, file="subwatersheds/sws-characterization.html")
