
library(leaflet)
library(leaflet.extras)
library(leafem)
library(geojsonio)

strm.ntwrk <- geojson_read("https://www.dropbox.com/s/nielu61qkb6j3zc/OHN_WATERCOURSE-export-segments-simplWGS.geojson?dl=1", what = "sp") %>% subset(order>1)
orm.bound <- readLines("https://www.dropbox.com/s/5f1iia0lnmwgcdo/oakRidgesMoraine.geojson?dl=1") %>% paste(collapse = "\n")

strm.lab <- paste('<b>Segment ID: ', strm.ntwrk$segmentID,'</b>',
                  '<br>  Strahler number: ', strm.ntwrk$order,
                  '<br>         Basin ID: ', strm.ntwrk$treeID,
                  '<br> Basin segment ID: ', strm.ntwrk$treesegID,
                  '<br>     connectivity: ', strm.ntwrk$topol)

m <- leaflet(strm.ntwrk) %>%
  addTiles(group='OSM') %>%
  addTiles(attribution = '<a href="https://owrc.github.io/interpolants/interpolation/watercourses.html">ORMGP README</a>') %>%
  addMouseCoordinates() %>%
  addFullscreenControl() %>%
  addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
  addPolylines(weight = ~(order+1)/2, color = "#6498d2", opacity = 1,
               label = lapply(strm.lab,htmltools::HTML),
               highlightOptions = highlightOptions(color = "yellow", weight = 10, bringToFront = TRUE)
  ) %>%
  setView(lng = -78.7, lat = 44.2, zoom = 12)


htmlwidgets::saveWidget(m, file="channel-topo/channel-topo.html")
