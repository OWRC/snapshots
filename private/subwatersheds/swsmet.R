
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(sf)
# library(rgeos)

sf_use_s2(FALSE)

sws <- st_read("https://raw.githubusercontent.com/OWRC/geojson/main/PDEM-South-D2013-OWRC23-60-HC-sws10-simpl.geojson")
sws.met <- read.csv("M:/FEWS2023/scripts/ncBasinToGob-historic/binToSWSsummary.csv")

sws.cent.sf <- sws %>% 
  st_transform(4236) %>%
  st_centroid() %>%
  select(c(oid,geometry))

sws.cent <- do.call(rbind, st_geometry(sws.cent.sf)) %>% 
  as_tibble() %>% setNames(c("lng","lat"))

sws <- sws %>% 
  full_join(sws.met) %>% 
  dplyr::bind_cols(sws.cent) %>% 
  mutate(pr=rf+sf)

pal <- colorNumeric(
  palette = "Blues",
  domain = sws$pr
  # reverse = TRUE
)

m <- leaflet(sws) %>%
  
  addTiles(attribution = '<a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
  addTiles(attribution = '<a href="https://owrc.github.io/interpolants/sources/climate-data-service.html" target="_blank" rel="noopener noreferrer"><b>METADATA</b></a>') %>%

  addTiles() %>%
  addFullscreenControl() %>%

  addPolygons(
    color = "black",
    fillColor = ~pal(pr),
    fillOpacity = .8,
    weight = 1,
    label = ~paste0(round(pr,0),'mm/yr'),
    popup = ~paste0('<b>sub-watershed: ',oid,'</b>',
                    # '<br>down-slope sws: ',dsid,
                    '<br>area: ',round(area,1),' km²',
                    '<br><b>Annual averages (2002-2023):</b>',
                    # '<br>    precipitation: ',round(precipitation,0),' mm/yr',
                    '<br>             rainfall: ',round(rf,0),' mm/yr',
                    '<br>             snowfall: ',round(sf,0),' mm/yr',
                    '<br>          temperature: ',round(ta,1),'°C',
                    '<br>             pressure: ',round(pa,1),' Pa',
                    '<br>potential evaporation: ',round(pe,0),' mm/yr',
                    '<br>           wind speed: ',round(us,1),' m/s',
                    '<br>    relative humidity: ',round(rh*100,0),' %',
                    '<br><a href="https://owrc.shinyapps.io/shyMetDS/?lat=',lat,'&lng=',lng,'"  target="_blank">open climate data service</a>'
    ),
    highlightOptions = highlightOptions(
      opacity = 1, fillOpacity = .4, color='yellow', weight = 5, bringToFront = TRUE
    ) 
  ) %>%  
  addLegend("topright", pal = pal, values = ~pr, #c(0,1000), #
            title = "Annual average<br>precipitation<br>(mm/yr)",
            bins = 5,
            opacity = 1
            # labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE))
  ) %>%
  setView(lng = -78.7, lat = 44.2, zoom = 8)


htmlwidgets::saveWidget(m, file="../../html/swsmet.html", title="Climate interpolation")
  
  
  
# 
# df.in <- read.csv('subwatersheds/swsmet.csv') %>%
#   mutate(rnum=row_number()) %>%
#   merge(read.csv("M:/OWRC-RDRR/output/sws-results.csv"),by="sws_id") %>%
#   rename(mmid=sws_id) %>%
#   arrange(rnum)
# 
# 
# # geojson.orig <- readOGR("https://www.dropbox.com/s/ro16gg6zi4kqbc0/owrc20-50a_SWS10-final.geojson?dl=1",verbose = FALSE)
# geojson <- geojson.orig
# 
# 
# # View(geojson@data)
# # geojson@data <- plyr::join(geojson@data, df.in, by="mmID")
# 
# 
# geojson@data <- cbind(geojson@data,
#                       gCentroid(geojson,byid=TRUE),
#                       df.in
#                       )
# 
# 
# sws.ntwrk <- readLines("https://www.dropbox.com/s/cmzzownz046djij/owrc20-50a_SWS10_ntwrk.geojson?dl=1") %>% paste(collapse = "\n")
# 
# 
# 
# getLeaflet <- function(palnam, nunit, title) {
#   pal <- colorNumeric(
#     palette = palnam,
#     domain = geojson@data$value #c(0,1000) # 
#   )
#   leaflet(geojson) %>%
#     
#     addTiles(attribution = '<a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
#     addTiles(attribution = '<a href="https://owrc.github.io/interpolants/interpolation/climate-sources.html#introduction" target="_blank" rel="noopener noreferrer"><b>METADATA</b></a>') %>%
#     
#     addTiles(group='OSM') %>%
#     # addProviderTiles( providers$Stamen.TonerLite, options = providerTileOptions(noWrap = TRUE) ) %>%
#     addFullscreenControl() %>%
#     
#     addPolygons(
#       color = "black",
#       fillColor = ~pal(value),
#       fillOpacity = 1,
#       weight = 2,
#       # label = ~paste0(round(air_temperature,0),'°C'),
#       label = ~paste0(round(value,0),nunit),
#       popup = ~paste0('<b>sub-watershed: ',mmID,'</b>',
#                       '<br> Annual Averages (2001-2020)',
#                       '<br>             area: ',round(Area/1000000,1),' km²',
#                       '<br>    precipitation: ',round(precipitation,0),' mm/yr',
#                       '<br>         rainfall: ',round(rainfall,0),' mm/yr',
#                       '<br>         snowfall: ',round(snowfall,0),' mm/yr',
#                       '<br>      Temperature: ',round(air_temperature,1),'°C',
#                       # '<br>      evaporation: ',round(aet,0),' mm/yr',
#                       # '<br>      gw recharge: ',round(rch,0),' mm/yr',
#                       # '<br>       net runoff: ',round(ro,0),' mm/yr',
#                       '<br><a href="https://owrc.shinyapps.io/shydrology/?lat=',y,'&lng=',x,'"  target="_blank">open time series</a>'
#       ),
#       highlightOptions = highlightOptions(
#         opacity = 1, fillOpacity =1, weight = 5, sendToBack = FALSE
#       )
#     ) %>%
#     addGeoJSON(sws.ntwrk, weight = 2, color = "cyan", opacity=1, group = "connectivity") %>%
#     # addLegend("topright", pal = pal, values = ~air_temperature,
#     #           title = "Annual average<br>Air temperature (°C)",
#     #           bins = 5,
#     #           opacity = 1
#     # ) %>%  
#     addLegend("topright", pal = pal, values = ~value, #c(0,1000), #
#               title = paste0("Annual average<br>",title),
#               bins = 5,
#               opacity = 1
#     ) %>%
#     addLayersControl(
#       overlayGroups = c("connectivity"),
#       options = layersControlOptions(collapsed = FALSE)
#     ) %>% hideGroup("connectivity") %>%
#   setView(lng = -78.7, lat = 44.2, zoom = 8)
# }
# 
# 
# 
# geojson@data <- mutate(geojson@data, value=precipitation)
# m <- getLeaflet("Blues",' mm/yr','precipitation (mm/yr)')
# htmlwidgets::saveWidget(m, file="subwatersheds/swsmet-P.html", title="Climate interpolation")
# 
# geojson@data <- mutate(geojson@data, value=aet)
# m <- getLeaflet("YlOrRd",' mm/yr','evaporation (mm/yr)')
# htmlwidgets::saveWidget(m, file="subwatersheds/swsmet-E.html")
# 
# geojson@data <- mutate(geojson@data, value=ro)
# m <- getLeaflet("Reds",' mm/yr','runoff (mm/yr)')
# htmlwidgets::saveWidget(m, file="subwatersheds/swsmet-R.html")
# 
# geojson@data <- mutate(geojson@data, value=rch)
# m <- getLeaflet("Greens",' mm/yr','recharge (mm/yr)')
# htmlwidgets::saveWidget(m, file="subwatersheds/swsmet-G.html")

