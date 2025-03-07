




## must run main.R






basemap <- leaflet( #width = "100%", height = "500px",
                   # options = leafletOptions( #zoomControl = FALSE,
                   #                          attributionControl=FALSE)
  ) %>%
  addTiles(attribution = '<a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
  addTiles(attribution = '<a href="https://owrc.github.io/snapshots/md/baseflow-piechart.html" target="_blank" rel="noopener noreferrer"><b>README</b></a>') %>%
  addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  addFullscreenControl() %>%
  # addGeoJSON(ormgp.bound, weight = 4, color = "black", fillOpacity = .1, dashArray = c(10, 5), opacity = .8, group = "ORMGP jurisdiction") %>%
  setView(lng = -78.89, lat = 43.9, zoom = 9)

colors <- c("#ad6d00","#0069f2")

# custom legend, following source of addLegendSize
offset <- 200
denom <- 20
breaks <- c(200,400,600,800)
sizes <- (breaks+offset)/denom
symbols <- Map(makeSymbol, shape = 'circle', width = sizes, 
               height = sizes, color = 'black',  
               opacity = .8, fillOpacity = 0, `stroke-width` = 2)

m <- basemap  %>%
  addLegendImage(images = symbols, labels = breaks, 
                 title = 'Total stream flow = slow+quick (mm/yr)', orientation = 'horizontal', labelStyle = "",
                 width = sizes, height = sizes, position = 'bottomright') %>%
  addMinicharts(
    df$LONG, df$LAT,
    type = "pie",
    chartdata = df[, c("slowflow","quickflow")],
    colorPalette = colors,
    width = (df$normQ+offset)/denom,
    popup = popupArgs(html=df$lab),
    # popup = popupArgs(html=df$html),
    transitionTime = 0,
    legendPosition = "bottomright") %>%
  
  addCircleMarkers(
    df$LONG, df$LAT,
    radius = (df$normQ+offset)/denom/2,
    weight=2,
    color ="black",
    label = paste0(df$LOC_NAME,': ',df$LOC_NAME_ALT1),
    # popup = lapply(df$html,htmltools::HTML),
    opacity = .8, 
    fillOpacity = .0,
    group='pts'
  )

  # addMarkers(
  #   df$LONG, df$LAT,
  #   popup = df$html
  # )


htmlwidgets::saveWidget(m, "baseflow-piechart.html")
