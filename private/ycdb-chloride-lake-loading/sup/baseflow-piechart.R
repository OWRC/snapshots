


piech.basemap <- leaflet(width = "100%", height = "500px",
                   options = leafletOptions(zoomControl = FALSE,
                                            attributionControl=FALSE)) %>%
  addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  # addGeoJSON(drainage.area, weight = 4, color = "black", dashArray = c(10, 5), fill = FALSE, opacity = .8) %>%
  addFullscreenControl() %>%
  setView(lng = -78.890, lat = 43.678, zoom = 9)

piech.df <- read.csv("calc/baseflow-piechart-gauge-summary-northshore.csv") %>%
  drop_na(meanQ) %>%
  mutate(slowflow=meanQ*BFI,
         quickflow=meanQ*(1-BFI),
         normQ=meanQ/SW_DRAINAGE_AREA_KM2*86400*365.24/1000,
         lab=paste0("<b>",LOC_NAME_ALT1,"</b>",
                    "<br>Period of record: ",YRb,"-",YRe,
                    "<br>Missing data: ",round((1-QUAL)*100,1),"%",
                    "<br>Drainage area: ",round(SW_DRAINAGE_AREA_KM2,1)," km²",
                    "<br>Mean discharge: ",round(meanQ,2)," m³/s",
                    "<br>Baseflow index: ", round(BFI,3),
                    "<br>Streamflow recession coefficient (k): ", round(k,3),
                    "<br>"
         )
  )


# custom legend, following source of addLegendSize
offset <- 200
denom <- 20
breaks <- c(200,400,600,800)
sizes <- (breaks+offset)/denom
symbols <- Map(makeSymbol, shape = 'circle', width = sizes, 
               height = sizes, color = 'black',  
               opacity = .8, fillOpacity = 0, `stroke-width` = 2)

piech.basemap  %>%
  addLegendImage(images = symbols, labels = breaks,
                 title = 'Total streamflow = slow+quick (mm/yr)', orientation = 'horizontal', labelStyle = "",
                 width = sizes, height = sizes, position = 'bottomright') %>%
  addMinicharts(
    piech.df$LONG, piech.df$LAT,
    type = "pie",
    chartdata = piech.df[, c("slowflow","quickflow")],
    colorPalette = c("#ad6d00","#0069f2"),
    width = (piech.df$normQ+offset)/denom,
    popup = popupArgs(html=piech.df$lab),
    transitionTime = 0,
    legendPosition = "bottomright") %>%
  addCircleMarkers(
    piech.df$LONG, piech.df$LAT,
    radius = (piech.df$normQ+offset)/denom/2,
    fill = FALSE,
    weight=2,
    color ="black",
    opacity = .8
  )
