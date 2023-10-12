


# rnaturalearth
lakes_sf <- ne_download(scale = 'large',
                        type = 'lakes',
                        category = 'physical') %>%
  sf::st_as_sf(lakes110, crs = 4269) %>%
  filter(name %in% c("Lake Ontario",
                     "Lake Erie",
                     "Lake Huron",
                     "Lake Simcoe",
                     "Lake Nipissing"))

lakes_sf$area <- as.numeric(st_area(lakes_sf))/1000000




# local files
print('here')
lontario.da <- readOGR("shp/lake-ontario-da.geojson",verbose = FALSE) 
ormgp.bound <- readOGR("https://www.dropbox.com/s/ligvb36c8xtzksx/ORMGP_Area_20210205-simpl.geojson?dl=1",verbose = FALSE)
# capture.area <- readOGR("shp/ORMGP-region.geojson",verbose = FALSE) # ycdb-chloride-lake-loading/
capture.area <- readOGR("shp/northshore-capture.geojson",verbose = FALSE) # buffer of drainage.area 
# drainage.area <- readOGR("shp/northshore-da.geojson",verbose = FALSE)
drainage.area <- read_sf("shp/northshore-da.geojson")
drainage.area.roads <- read_sf("shp/northshore-roads-select.geojson")
drainage.area.builtup <- read_sf("shp/northshore-built-up-areas.geojson")
drainage.area.grnblt <- read_sf("shp/greenbelt.geojson")
print('here')



# basemap (Great Lakes)
basemapGL <- ggplot() +
  theme_bw() +
  theme(axis.text = element_blank()) +  
  geom_sf(data = lakes_sf,
          mapping = aes(geometry = geometry),
          color = "black",
          fill = "lightblue")
# geom_sf_label(data = lakes_sf, aes(label = name))

