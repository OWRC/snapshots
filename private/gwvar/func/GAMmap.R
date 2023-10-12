
home.html <- ' <a href="https://www.oakridgeswater.ca/" target="_blank" rel="noopener noreferrer">&copy; Oak Ridges Moraine Groundwater Program</a>'

wt.html <- '<a href="https://owrc.github.io/metadata/surfaces/water_table.html" target="_blank" rel="noopener noreferrer"><b>META DATA</b></a>'
  

GAMmap <- function(pnt) {
  
  pnt$grp <- 4
  pnt$grp[pnt$GAMrange<5] <- 3
  pnt$grp[pnt$GAMrange<2] <- 2
  pnt$grp[pnt$GAMrange<.5] <- 1
  
  pntlab <- paste("<b>", pnt$SCREEN_NAME, "</b>",
                  "</br>Range in GW levels: \u00B1", round(pnt$GAMrange,1), "m",
                  "</br>n observations: ", format(pnt$WL_AVG_TOTAL_NUM, big.mark=","))
  
  
  
  # Build map
  nam <- "Depth to GW table (m)"
  labels <- c("<1m", "1-5", "5-10", "10-20", ">20m")
  
  # modified from: https://stackoverflow.com/questions/58505589/circles-in-legend-for-leaflet-map-with-addcirclemarkers-in-r-without-shiny
  addLegendCustom <- function(map, title, colors, labels, sizes, opacity = 0.5){
    colorAdditions <- colorAdditions <- paste0(colors, "; border-radius: 50%; width:", sizes, "px; height:", sizes, "px") #paste0(colors, "; width:", sizes, "px; height:", sizes, "px")
    labelAdditions <- paste0("<div style='display: inline-block;height: ", 
                             sizes, "px;margin-top: 4px;line-height: ", sizes, "px;'>", 
                             labels, "</div>")
    
    return(addLegend(map, title = title, colors = colorAdditions, 
                     labels = labelAdditions, opacity = opacity))
  }
  
  scale = 5
  leaflet() %>% addTiles(attribution = paste0(wt.html,home.html)) %>%
    addTiles("https://tile.oakridgeswater.ca/wtdepth/{z}/{x}/{y}", 
             group = "wtdepth", 
             options = providerTileOptions(attribution=home.html, 
                                           opacity = 0.2,
                                           maxNativeZoom = 16)) %>%
    
    # addMouseCoordinates() %>%
    # addLayersControl(overlayGroups = nam) %>%
    
    addFullscreenControl() %>%
    addCircleMarkers(data = pnt, lng = ~LONG, lat = ~LAT, 
                     weight = 1, color = 'black', fillColor = "#FEA62A", opacity = 0.8,
                     radius = ~(grp*scale),
                     label = lapply(pntlab,htmltools::HTML),
                     popup = ~paste0(pntlab,
                                     '<br>depth to screen: ',round(SCREEN_TOP_DEPTH_M,1),' m',
                                     '<br>formation: <em>',FORMATION,'</em>',
                                     '<br><a href="https://owrc.shinyapps.io/shydrograph/?i=',INT_ID,'" target="_blank">view timeseries</a>')) %>%
    addLegend("topright", 
              colors = c("#08306b",  "#2879b9", "#73b3d8", "#c8ddf0", "#f7fbff"),
              labels = c("<0.5", "<5", "<10", "<20", ">20"),
              title = "water table,<br>depth (m)",
              opacity = 1) %>%
    addControl(html = "<label>water table, opacity:</label><div><input id=\"OpacitySlide\" type=\"range\" min=\"0\" max=\"1\" step=\"0.1\" value=\"0.2\"></div>",
               position = "topright") %>%   # Add Slider
    htmlwidgets::onRender(
      "function(el,x,data){
                         var map = this;
                         var evthandler = function(e){
                            var layers = map.layerManager.getVisibleGroups();
                            console.log('VisibleGroups: ', layers); 
                            console.log('Target value: ', +e.target.value);
                            layers.forEach(function(group) {
                              var layer = map.layerManager._byGroup[group];
                              Object.keys(layer).forEach(function(el){
                                layer[el]._container.style.opacity = +e.target.value;
                              });
                            })
                         };
                  $('#OpacitySlide').mousedown(function () { map.dragging.disable(); });
                  $('#OpacitySlide').mouseup(function () { map.dragging.enable(); });
                  $('#OpacitySlide').on('input', evthandler)}
              ") %>%
    addLegendCustom(title = "GW range (\u00B1m)", colors = "black", labels = c("< 0.5", "0.5-2", "2-5", "> 5"), sizes = c(1,2,3,4)*scale*2)
}


GAMmapDeep <- function(pnt) {
  
  pnt$grp <- 4
  pnt$grp[pnt$GAMrange<5] <- 3
  pnt$grp[pnt$GAMrange<2] <- 2
  pnt$grp[pnt$GAMrange<.5] <- 1
  
  pntlab <- paste("<b>", pnt$SCREEN_NAME, "</b>",
                  "</br>Range in GW levels: \u00B1", round(pnt$GAMrange,1), "m",
                  "</br>n observations: ", format(pnt$WL_AVG_TOTAL_NUM, big.mark=","))
  
  
  
  # Build map
  nam <- "Depth to GW table (m)"
  labels <- c("<1m", "1-5", "5-10", "10-20", ">20m")
  
  # modified from: https://stackoverflow.com/questions/58505589/circles-in-legend-for-leaflet-map-with-addcirclemarkers-in-r-without-shiny
  addLegendCustom <- function(map, title, colors, labels, sizes, opacity = 0.5){
    colorAdditions <- colorAdditions <- paste0(colors, "; border-radius: 50%; width:", sizes, "px; height:", sizes, "px") #paste0(colors, "; width:", sizes, "px; height:", sizes, "px")
    labelAdditions <- paste0("<div style='display: inline-block;height: ", 
                             sizes, "px;margin-top: 4px;line-height: ", sizes, "px;'>", 
                             labels, "</div>")
    
    return(addLegend(map, title = title, colors = colorAdditions, 
                     labels = labelAdditions, opacity = opacity))
  }
  
  scale = 5
  leaflet() %>% addTiles(attribution = home.html) %>%
    
    # addMouseCoordinates() %>%
    # addLayersControl(overlayGroups = nam) %>%
    
    addFullscreenControl() %>%
    addCircleMarkers(data = pnt, lng = ~LONG, lat = ~LAT, 
                     weight = 1, color = 'black', fillColor = "#FEA62A", opacity = 0.8,
                     radius = ~(grp*scale),
                     label = lapply(pntlab,htmltools::HTML),
                     popup = ~paste0(pntlab,
                                     '<br>depth to screen: ',round(SCREEN_TOP_DEPTH_M,1),' m',
                                     '<br>formation: <em>',FORMATION,'</em>',
                                     '<br><a href="https://owrc.shinyapps.io/shydrograph/?i=',INT_ID,'" target="_blank">view timeseries</a>')) %>%
    addLegendCustom(title = "GW range (\u00B1m)", colors = "black", labels = c("< 0.5", "0.5-2", "2-5", "> 5"), sizes = c(1,2,3,4)*scale*2)
}
