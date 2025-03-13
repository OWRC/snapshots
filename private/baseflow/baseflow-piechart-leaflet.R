




## must run main.R


sf.CAs <- read_sf("E:/Sync/@gis/Boundaries/partner_CA_regions.shp") %>%
  st_transform(4326)
  

basemap <- leaflet(st_zm(sf.CAs),
                   # width = "100%", height = "500px",
                   # options = leafletOptions( #zoomControl = FALSE,
                   #                          attributionControl=FALSE)
  ) %>%
  addTiles(attribution = '<a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
  addTiles(attribution = '<a href="https://owrc.github.io/snapshots/md/baseflow-piechart.html" target="_blank" rel="noopener noreferrer"><b>README</b></a>') %>%
  addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  addFullscreenControl() %>%
  addPolygons(
    fill=FALSE,
    opacity=1.,
    weight=.25,
    color = 'black'
  ) #%>%
  # addGeoJSON(ormgp.bound, weight = 4, color = "black", fillOpacity = .1, dashArray = c(10, 5), opacity = .8, group = "ORMGP jurisdiction") %>%
  # setView(lng = -78.89, lat = 43.9, zoom = 9)

colors <- c("#ad6d00","#0069f2")

# custom legend, following source of addLegendSize
offset <- 200
denom <- 20
breaks <- c(200,400,600,800)
sizes <- (breaks+offset)/denom
symbols <- Map(makeSymbol, shape = 'circle', width = sizes, 
               height = sizes, color = 'black',  
               opacity = .8, fillOpacity = 0, `stroke-width` = 3)

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
    data=df,
    ~LONG, ~LAT,
    radius = ~(normQ+offset)/denom/2,
    weight=3,
    fill = FALSE,
    color ="black",
    label = ~paste0(LOC_NAME,': ',LOC_NAME_ALT1),
    # popup = lapply(~html,htmltools::HTML),
    opacity = .8, 
    fillOpacity = .0,
    group='pts'
  )

  # addMarkers(
  #   df$LONG, df$LAT,
  #   popup = df$html
  # )


htmlwidgets::saveWidget(m, "baseflow-piechart.html")
