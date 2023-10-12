

library(leaflet)



df <- read.csv('met-annuals/ranges.csv')
ormgp.bound <- readLines("https://www.dropbox.com/s/lrdycz5eomw09hr/ORMGP_Area_20210205-Drawing-simplWGS.geojson?dl=1") %>% paste(collapse = "\n")
orm.bound <- readLines("https://www.dropbox.com/s/5f1iia0lnmwgcdo/oakRidgesMoraine.geojson?dl=1") %>% paste(collapse = "\n")



pal <- colorNumeric(
  palette = 'Reds',
  domain = df$Tmean
)

m <- df %>% leaflet(options = leafletOptions( #zoomControl = FALSE,
                      attributionControl=FALSE)) %>%
  addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  leaflet.extras::addFullscreenControl() %>%
  # leafem::addMouseCoordinates() %>%
  addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
  addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%  
  addCircleMarkers(layerId = ~station_id,
                   radius = ~Tmean,
                   weight = 1,
                   fillColor = ~pal(Tmean),
                   opacity = 1,
                   fillOpacity = 1,
                   # group = ~FORMATION,
                   lng = ~Longitude, lat = ~Latitude,
                   label = ~paste0(round(Tmean,1),"°C; ",round(Pmean,0)," (",round(Pmin,0),"-",round(Pmax,0),") mm/year"),
                   popup = ~paste0('<b>',station_name,'</b><br><i>min; mean; max</i>',
                                   "<br>Precipitation (mm/yr): ",round(Pmin,0),"; ",round(Pmean,0),"; ",round(Pmax,0),
                                   "<br>Air Temperature (°C): ",round(Tmin,1),"; ",round(Tmean,1),"; ",round(Tmax,1)
                                   )
                   ) %>%
  addLegend("topright", pal = pal, values = ~Tmean,
            title = "Annual average<br>Air Temperature (°C)",
            # labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE)),
            bins = 5,
            opacity = 1
  ) %>%
  setView(lng = -79, lat = 44.45, zoom = 8)


htmlwidgets::saveWidget(m, file="met-annuals/met-annuals-temperature.html")
  