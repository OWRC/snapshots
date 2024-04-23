

############### MUST RUN  ycdb-connect.R  and  main.R  first !!!!!!!!!!!!!!!


############################################################################
############################################################################
############################################################################
# specific capacity
############################################################################

library(leaflet)
library(leaflet.extras)
library(leafem)
library(leaflegend)




df <- df.full %>% filter(!is.na(df.full$SPEC_CAP_LPMM))
df$SC_CAT <- 1
df$SC_CAT[df$SPEC_CAP_LPMM>48] <- 2
df$SC_CAT[df$SPEC_CAP_LPMM>210] <- 3
df$SC_CAT[df$SPEC_CAP_LPMM>910] <- 4
df$SC_CAT[df$SPEC_CAP_LPMM>2500] <- 5
# df$SC_CAT = as.factor(df$SC_CAT)
df$SC_CAT <- df$SC_CAT * 7




# custom legend, following source of addLegendSize
sizes <- sort(df$SC_CAT %>% unique())*2
breaks <- c('<48','48-210','210-920','910-2500','>2500')
symbols <- Map(makeSymbol, shape = 'circle', width = sizes, 
               height = sizes, color = 'black',  
               opacity = .8, fillOpacity = 0, `stroke-width` = 2)


m <- df %>% leaflet()  %>%
  addLegendImage(images = symbols, labels = breaks,
                 title = 'Specific Capacity (L/min/m)', orientation = 'horizontal', labelStyle = "",
                 width = sizes, height = sizes, position = 'bottomleft') %>%
  
  addTiles(attribution = '<a href="https://owrc.github.io/snapshots/md/hydraulicProperties.html" target="_blank" rel="noopener noreferrer"><b>README</b></a> © <a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
  
  addFullscreenControl() %>%
  # addMouseCoordinates() %>%
  addCircleMarkers(layerId = ~INT_ID,
                   lng = ~LONG, lat = ~LAT,
                   radius = ~SC_CAT,
                   weight = 1,
                   color = ~pal(FORMATION),
                   group = ~FORMATION,
                   opacity = .5,
                   label = ~paste0("SC: ",round(SPEC_CAP_LPMM,1)," L/min/m"),
                   popup = ~paste0(LOC_NAME,': ', LOC_NAME_ALT1,'<br>',FORMATION)) %>%
  setView(lng = -79.0, lat = 44.0, zoom = 10) %>%
  addLayersControl(
    # baseGroups = c("Open StreetMap", "Open TopoMap", "Toner Lite"),
    overlayGroups = layers.ordered,
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  hideGroup(layers.ordered[-9]) %>% # all but Thorncliffe
  htmlwidgets::onRender("
        function() {
            $('.leaflet-control-layers-base').prepend('<label style=\"text-align:center\"><b>Formation</b></label>');
        }
    ")


htmlwidgets::saveWidget(m, file="hydraulicproperties-se.html")
