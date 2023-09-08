

library(leaflet)
library(sf)


subbasins <- st_transform(st_read("O:/MadRiver23/HEC-HMS/MadRiver23/maps/HEC-HMS_subbasins.shp"), 4326)

leaflet(subbasins) %>%
  addTiles() %>%
  
  addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.25,
              fillColor = "lightgreen",
              label = ~paste0("Subbasin ",swsid),
              popup = ~paste0('<b>Subbasin ', swsid,"</b>",
                              '<br>drains to subbasin ', dssws,
                              '<br>(composite) CN: ', round(CN,0),
                              '<br>pecent Imperv: ', round(perimp*100,0),"&#37",
                              '<br>pecent Cover: ', round(percov*100,0),"&#37",
                              '<br>subbasin area: ', round(area,1), "km²",
                              '<br>reach length: ', round(fplen.km,1), "km"
                              ),
              highlightOptions = highlightOptions(
                opacity = 1, fillOpacity =1, weight = 5, sendToBack = FALSE
              )
  )

              