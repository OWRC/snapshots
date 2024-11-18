


library(geojsonio)
library(leaflet)
library(leaflet.extras)
library(leafem)
library(dplyr)

mdl.bounds <- geojson_read("https://raw.githubusercontent.com/OWRC/geojson/main/NMCP_model_bounds.geojson", what = "sp")





# set order
neword <- order(-mdl.bounds@data$Area)
mdl.bounds@polygons <- mdl.bounds@polygons[neword]
mdl.bounds@plotOrder <- neword
mdl.bounds@data <- mdl.bounds@data %>% arrange(-Area)

# leaflet(mdl.bounds) %>% addPolygons(weight = 1, highlightOptions = highlightOptions(weight = 5)) #, bringToFront = TRUE))


mdl.bounds$ModelType <- factor(mdl.bounds$ModelType, levels = c("Groundwater", "Hydrologic", "Integrated", "Coupled"))
factpal <- colorFactor(c("#e08924","#6498d2","#8b0000","cyan"), mdl.bounds$ModelType)

m <- leaflet(mdl.bounds) %>% #, width = "100%", height = "500px", options = leafletOptions( #zoomControl = FALSE, attributionControl=FALSE)) %>%
        
  # addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  
  addFullscreenControl() %>%
  addScaleBar(position = "bottomright") %>%
  
  addLogo(
    img="https://raw.githubusercontent.com/OWRC/logos/main/ORMGP_logo_vsmall.png",
    src= "remote",
    position="bottomleft",
    offset.x = 10,
    offset.y = 10,
    width = 294
  ) %>%
  
  addTiles(attribution = '<a href="https://owrc.github.io/snapshots/md/numerical-model-custodianship-program.html" target="_blank" rel="noopener noreferrer"><b>Numerical Model Custodianship Program</b></a> © Oak Ridges Moraine Groundwater Program') %>%
    
  addPolygons(weight = 1, color = ~factpal(ModelType), opacity = 1, group = ~ModelType,
              highlightOptions = highlightOptions(weight = 5),
              label = ~ModelName,
              popup = ~paste0(ModelID,'<br><b>',ModelName,'</b><br>(',Delivery,')',
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


htmlwidgets::saveWidget(m, "numerical-model-custodianship-program.html")

