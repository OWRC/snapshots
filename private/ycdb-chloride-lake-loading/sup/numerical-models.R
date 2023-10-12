

mdlBound <- geojson_read("shp/existing_model_bounds-WGS.geojson", what = "sp")

# set order
neword <- order(-mdlBound@data$Area)
mdlBound@polygons <- mdlBound@polygons[neword]
mdlBound@plotOrder <- neword
mdlBound@data <- mdlBound@data %>% arrange(-Area)


leaflet(mdlBound, width = "100%", height = "400px") %>%
  addTiles(group='OSM') %>% #addProviderTiles(providers$OpenTopoMap) %>% # 
  # addGeoJSON(mdlBound, weight = 4, color = "red", opacity = .8) %>%
  addPolygons(weight = 1, smoothFactor = 0.3, fillOpacity = .1, label = ~ModelName, 
              highlightOptions = highlightOptions(
                opacity = 1, weight = 5, 
                sendToBack = FALSE, 
                color = "white"),
              popup = ~paste0("<b>",ModelName,
                              "</b><br>Area: ",prettyNum(round(Area/1000000,0), big.mark = ","), " km²",
                              "<br>Resolution: ",round(minCEsize,0)," to ",prettyNum(round(maxCEsize,0), big.mark = ","), " m",
                              "<br>Number of Layers: ",nLayers,
                              "<br>Number of Cells: ",prettyNum(nCE, big.mark = ","),
                              "<br>Model Type: ",ModelType,
                              "<br>Model Code: ",ModelCode,
                              "<br>Developer: ",Consult )
  ) %>%
  addGeoJSON(drainage.area, weight = 4, color = "black", dashArray = c(10, 5), fill = FALSE, opacity = .8) %>%
  addFullscreenControl() %>%
  setView(lng = -83.029, lat = 45.959, zoom = 5)
