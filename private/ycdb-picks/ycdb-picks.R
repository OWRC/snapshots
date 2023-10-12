

library(dplyr)
library(leaflet)


# q <- "SELECT L.LOC_ID, [NAME], X.LONG, X.LAT, FORMATION, FORMATION_TOP_ELEV FROM W_GENERAL_PICK AS L
#       LEFT JOIN (SELECT LOC_ID, LONG, LAT FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL) AS X ON L.LOC_ID = X.LOC_ID
#       WHERE X.LONG IS NOT NULL"

q <- "SELECT L.LOC_ID, [NAME], X.LONG, X.LAT, GEOL_UNIT_DESCRIPTION AS FORMATION, FORMATION_TOP_ELEV FROM W_GENERAL_PICK AS L
      LEFT JOIN (SELECT LOC_ID, LONG, LAT FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL) AS X ON L.LOC_ID = X.LOC_ID
      LEFT JOIN (SELECT GEOL_UNIT_CODE, GEOL_UNIT_DESCRIPTION FROM R_GEOL_UNIT_CODE) AS G ON L.GEOL_UNIT_CODE = G.GEOL_UNIT_CODE
      WHERE X.LONG IS NOT NULL"

df <- dbGetQuery(con,q) 


df$FORMATION <- as.factor(df$FORMATION)



# print(levels(df$FORMATION))
# 
# 
# # View(df %>% group_by(FORMATION) %>% summarize(n=n()) %>% arrange(desc(n)))


# df1 <- df %>% 
#   group_by(FORMATION) %>%
#   mutate(n=n()) %>%
#   # filter(n>7500) %>%
#   ungroup() 




layers_ordered <- c(
  "Late Stage Glaciolacustrine-Glaciofluvial (YPDT)",
  "Halton/Kettleby Till (YPDT)",
  "Mackinaw/Oak Ridges (MIS/ORAC) (YPDT)",
  "Channel - Clay (YPDT)",
  "Channel - Sand (YPDT)",
  "Unconformity (ORMGP)",
  "Upper Newmarket (YPDT)",
  "Inter Newmarket SedimentLower (YPDT)",
  "Lower Newmarket (YPDT)",
  "Newmarket Till/Northern Till",
  "Thorncliffe (YPDT)",
  "Sunnybrook (YPDT)",
  "Scarborough (YPDT)",
  "York Till",
  "Bedrock - Undifferentiated (YPDT)"
  )




pal <- colorFactor(
  # palette = topo.colors(5),
  # palette = c('#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#cab2d6','#ff7f00','#6a3d9a','#ffff99','#b15928','#a6cee3'),
  palette = c("#cb4f31", "#52c274", "#c25abc", "#65af3a", "#7a67ca", "#b6b138", "#6b8fce", "#d79139", "#4cbdaf", "#d1416d", "#447f47", "#bc6990", "#a0b26a", "#c77a5c", "#7e7029"),
  # domain = df$FORMATION
  levels = layers_ordered
)


m <- df %>% leaflet() %>%
  
  addTiles(attribution = '<a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
  # addTiles(attribution = '<a href="https://owrc.github.io/interpolants/interpolation/climate-sources.html#introduction" target="_blank" rel="noopener noreferrer"><b>METADATA</b></a>') %>%
  
  addTiles(group='Open StreetMap') %>% # OpenStreetMap by default
  addProviderTiles(providers$OpenTopoMap, group='Open TopoMap', options = providerTileOptions(attribution=" Map data: © OpenStreetMap contributors, SRTM | Map style: © OpenTopoMap (CC-BY-SA)")) %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner Lite", options = providerTileOptions(attribution=" Map tiles by Stamen Design, CC BY 3.0 — Map data © OpenStreetMap contributors")) %>%
  
  leaflet.extras::addFullscreenControl() %>%
  # leafem::addMouseCoordinates() %>%
  addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.35) %>%
  addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%
  addCircles(layerId = ~LOC_ID,
             color = ~pal(FORMATION),
             weight = 3,
             opacity = 1,
             group = ~FORMATION,
             lng = ~LONG, lat = ~LAT,
             label = ~paste0(FORMATION, " (",FORMATION_TOP_ELEV," masl)"),
             # popup = ~paste0('<b>',NAME,'</b><br><a href="https://owrc.shinyapps.io/shychemo/?l=',LOC_ID,'">see chemograph</a>')
  ) %>%
  # addLayersControl(overlayGroups = levels(df$FORMATION),
  addLayersControl(
    baseGroups = c("Open StreetMap", "Open TopoMap", "Toner Lite"),
    overlayGroups = layers_ordered,                 
    options = layersControlOptions(collapsed = FALSE)) %>%
  # hideGroup(levels(df$FORMATION)[-1]) %>%
  hideGroup(layers_ordered[-1]) %>%
  # addLegend("topright", pal = pal, values = ~mean,
  #           title = "Mean measured<br>Chloride (mg/L)",
  #           bins = 5,
  #           opacity = 1
  # ) %>%
  setView(lng = -79, lat = 44.45, zoom = 8)


htmlwidgets::saveWidget(m, file="ycdb-picks/ycdb-picks.html")
