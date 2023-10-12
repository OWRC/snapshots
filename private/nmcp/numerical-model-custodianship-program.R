


library(geojsonio)
library(leaflet)
library(leaflet.extras)
library(dplyr)

mdl.bounds <- geojson_read("https://www.dropbox.com/s/3xb0dp1hmlntily/ORMGP_model_bounds.geojson?dl=1", what = "sp")








# set order
neword <- order(-mdl.bounds@data$Area)
mdl.bounds@polygons <- mdl.bounds@polygons[neword]
mdl.bounds@plotOrder <- neword
mdl.bounds@data <- mdl.bounds@data %>% arrange(-Area)

# leaflet(mdl.bounds) %>% addPolygons(weight = 1, highlightOptions = highlightOptions(weight = 5)) #, bringToFront = TRUE))


mdl.bounds$ModelType <- factor(mdl.bounds$ModelType, levels = c("Groundwater", "Hydrologic", "Integrated", "Coupled"))
factpal <- colorFactor(c("#e08924","#6498d2","#8b0000","cyan"), mdl.bounds$ModelType)
m <- leaflet(mdl.bounds, #width = "100%", height = "500px",
        options = leafletOptions( #zoomControl = FALSE,
                                 attributionControl=FALSE)) %>%
  addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  addFullscreenControl() %>%
  addPolygons(weight = 1, color = ~factpal(ModelType), opacity = 1, group = ~ModelType,
              highlightOptions = highlightOptions(weight = 5),
              popup = ~paste0('<b>',ModelName,'</b> (',Delivery,')',
                              '<br>       Area: ',round(AreaKM2,1),'km²',
                              '<br> Model code: ',ModelCode,
                              '<br>    n cells: ',nCE,
                              '<br>   n layers: ',nLayers,
                              '<br> <a href="https://partners.oakridgeswater.ca/FolderView?folderId=', ReportID, '"><em>', Report, '</em></a>')
  ) %>%
  setView(lng = -78.7, lat = 44.2, zoom = 8) %>%
  addLayersControl(
    overlayGroups = c("Groundwater", "Hydrologic", "Integrated", "Coupled"),
    options = layersControlOptions(collapsed = FALSE)
  )


htmlwidgets::saveWidget(m, "external/nmcp/numerical-model-custodianship-program.html")
