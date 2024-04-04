

############### MUST RUN  ycdb-connect.R  and  main.R  first !!!!!!!!!!!!!!!


############################################################################
############################################################################
############################################################################
# hydraulic conductivity
############################################################################

library(leaflet)
library(leaflet.extras)
library(leafem)
library(leaflegend)
library(ggplot2)





df <- df.full %>% filter(!is.na(df.full$K_MS))
# df %>% ggplot(aes(x=log10(K_MS))) + geom_histogram()



df$K_CAT <- 1
df$K_CAT[log10(df$K_MS)>-10] <- 2
df$K_CAT[log10(df$K_MS)>-7] <- 3
df$K_CAT[log10(df$K_MS)>-5] <- 4
df$K_CAT[log10(df$K_MS)>-3] <- 5
# df$K_CAT = as.factor(df$K_CAT)
df$K_CAT <- df$K_CAT * 7 # scaling

# custom legend, following source of addLegendSize
sizes <- sort(df$K_CAT %>% unique())*2
breaks <- c('<1e-10','<1e-7','<1e-5','<1e-3','>1e-3')
symbols <- Map(makeSymbol, shape = 'circle', width = sizes, 
               height = sizes, color = 'black',  
               opacity = .8, fillOpacity = 0, `stroke-width` = 2)


m <- df %>% leaflet()  %>%
  addLegendImage(images = symbols, labels = breaks,
                 title = 'Hydraulic Conductivity (m/s)', orientation = 'horizontal', labelStyle = "",
                 width = sizes, height = sizes, position = 'bottomright') %>%
  
  addTiles(attribution = '<a href="https://owrc.github.io/snapshots/md/hydraulicProperties.html" target="_blank" rel="noopener noreferrer"><b>README</b></a> © <a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer"><b>Oak Ridges Moraine Groundwater Program</b></a>') %>%
  
  addFullscreenControl() %>%
  # addMouseCoordinates() %>%
  addCircleMarkers(layerId = ~INT_ID,
                   lng = ~LONG, lat = ~LAT,
                   radius = ~K_CAT,
                   weight = 1,
                   color = ~pal(FORMATION),
                   group = ~FORMATION,
                   opacity = .5,
                   label = ~paste0("K: ",formatC(K_MS, format = "e", digits = 2)," m/s"),
                   popup = ~paste0(LOC_NAME,': ', LOC_NAME_ALT1,'<br>',FORMATION)) %>%
  setView(lng = -79, lat = 44, zoom = 9) %>%
  addLayersControl(
    overlayGroups = layers.ordered,
    # baseGroups = c("Open StreetMap", "Open TopoMap", "Toner Lite"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  # hideGroup(layers.ordered[-2]) %>%
  htmlwidgets::onRender("
        function() {
            $('.leaflet-control-layers-base').prepend('<label style=\"text-align:center\"><b>Formation</b></label>');
        }
    ")


htmlwidgets::saveWidget(m, file="hydraulicproperties-k.html")
