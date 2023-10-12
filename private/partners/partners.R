
library(geojsonio)
library(leaflet)
library(leaflet.extras)
library(dplyr)

ormgp.bound <- readLines("https://www.dropbox.com/s/lrdycz5eomw09hr/ORMGP_Area_20210205-Drawing-simplWGS.geojson?dl=1") %>% paste(collapse = "\n")
ypdth.bound <- geojson_read("https://www.dropbox.com/s/dybqvus40he92uz/YPDTH-regions.geojson?dl=1", what = "sp") # 
ca.bound <- geojson_read("https://www.dropbox.com/s/uucwhyi52t1dfm0/partners-regions.geojson?dl=1", what = "sp") # 
swp.bound <- geojson_read("https://www.dropbox.com/s/glonstiz3er5or8/SOURCE_PROT_AREA_GEN-ORMGP-WGS.geojson?dl=1", what = "sp") # 
orm.bound <- readLines("https://www.dropbox.com/s/5f1iia0lnmwgcdo/oakRidgesMoraine.geojson?dl=1") %>% paste(collapse = "\n")



m <- leaflet() %>% #width = "100%", height = "480px") %>%
  addTiles(group='OSM') %>%
  # addMouseCoordinates() %>%
  addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
  addGeoJSON(ormgp.bound, weight = 6, color = "yellow", fillOpacity = .1, dashArray = c(10, 5), opacity = .8, group = "ORMGP jurisdiction") %>%
  # addGeoJSON(ca.bound, weight = 3, opacity = 1, group = "Conservation Authorities") %>%
  # addGeoJSON(ypdth.bound, weight = 3, color = "#8b0000", opacity = 1, group = "Municipalities") %>%
  addPolygons(data=swp.bound, weight = 3, color="#00490B", opacity = 1, label=~Name, group = "Sourcewater Protection Areas") %>%
  addPolygons(data=ca.bound, weight = 3, opacity = 1, label=~Name, group = "Conservation Authorities") %>%
  addPolygons(data=ypdth.bound, weight = 3, color = "#8b0000", opacity = 1, label=~LEGAL_NAME, group = "Municipalities") %>%
  setView(lng = -78.7, lat = 44.2, zoom = 8) %>%
  addLayersControl(
    overlayGroups = c("Municipalities", "Conservation Authorities", "Sourcewater Protection Areas","ORMGP jurisdiction"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addFullscreenControl() #%>%
  # addLegend("bottomright",
  #   colors = c("#8b000080", "#0033FF80", "#00000080"),
  #   labels = c("Municipalities", "Conservation Authorities", "ORMGP jurisdiction"),
  #   opacity = 1)


library(htmlwidgets)
saveWidget(m, file="external/gantt-met/partners.html")