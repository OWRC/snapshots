
library(ggplot2)
library(dplyr)
library(sf)
library(rnaturalearth)
library(jsonlite)
library(geojsonio)



# loc.bh <- fromJSON("http://golang.oakridgeswater.ca:8080/locwell/") # too large
loc.met <- fromJSON("http://golang.oakridgeswater.ca:8080/locmet/")
loc.gw <- fromJSON("http://golang.oakridgeswater.ca:8080/locgw/")
loc.sw <- fromJSON("http://golang.oakridgeswater.ca:8080/locsw/")
ormgp.bound <- geojson_read("https://www.dropbox.com/s/lrdycz5eomw09hr/ORMGP_Area_20210205-Drawing-simplWGS.geojson?dl=1",  what = "sp")




lakes10 <- ne_download(scale = 10, type = "lakes", category = "physical")
lakes10_sf <- lakes10 %>%
  st_as_sf() %>%
  filter(name %in% c("Lake Ontario","Lake Erie","Lake Simcoe","Lake Huron","Lake Nipissing","Indiana","Ohio","Pennsylvania","New York"))




# rivers11 <- ne_download(scale = 10, type = "rivers_lake_centerlines", category = "physical")



ggplot() +
  theme_void() +
  theme(legend.position = c(.85,.25),
        legend.title=element_text(size=16),
        legend.text=element_text(size=16)) +
  geom_polygon(data = ormgp.bound, aes( x = long, y = lat, group = group), fill=NA, color="#16557F") +
  geom_sf(data=lakes10_sf, fill = "#a6cee3",colour='#16557F', linewidth=1) +
  geom_point(data=loc.gw, aes(LONG,LAT, colour='groundwater')) +
  geom_point(data=loc.met, aes(LONG,LAT, colour='meteorological')) +
  geom_point(data=loc.sw, aes(LONG,LAT, colour='streamflow')) +
  annotate("text",-78.7,43.6,label='Lake Ontario', colour='#16557F', size=8) +
  scale_color_manual(name="Monitoring locations", values = c('#d95f02','#1b9e77','#16557F')) + 
  coord_sf(xlim = c(-81, -77), ylim = c(43, 45.5), expand = FALSE)


ggsave('./ycdb-general/ycdb-locations-ggplot.png',height=20,width=25,units = 'cm')

