MKmap <- function(df) {
  df['mkshp'] <- 1
  df[df$MannKendall10yrTau<0 & df$MannKendall10yrPstat<.05,]['mkshp'] <- 2
  df[df$MannKendall10yrTau>0 & df$MannKendall10yrPstat<.05,]['mkshp'] <- 3
  
  dflab <- paste("<b>", df$SCREEN_NAME, "</b>",
                 "</br>Mann-Kendall Tau: ", round(df$MannKendall10yrTau,3),
                 "(p = ", round(df$MannKendall10yrPstat,3),')',
                 "</br>n observations: ", format(df$WL_AVG_TOTAL_NUM, big.mark=","))
  
  icons <- iconList(
    notrend <- makeIcon(iconUrl = "https://www.dropbox.com/scl/fi/hbnmpit39kef98htjfy10/circle-icon-16073.png?rlkey=z409ooo3nggx7radx7gn8h3ba&dl=1", iconWidth = 15, iconHeight = 15),
    decreasing <- makeIcon(iconUrl = "https://www.dropbox.com/scl/fi/p4zakasqq21avsviqb2zs/down.png?rlkey=fu8cvpz4znzl77kal51r7dw3f&dl=1", iconWidth = 18, iconHeight = 18),
    increasing <- makeIcon(iconUrl = "https://www.dropbox.com/scl/fi/mg7z443aj8glrig6lxjjg/up.png?rlkey=y5kfybsnw4bu6vcevlw9lgtq0&dl=1", iconWidth = 18, iconHeight = 18)
  )
  
  
  
  
  # Build map
  leaflet() %>% addTiles(attribution = home.html) %>%
    
    # addMouseCoordinates() %>%
    # addLayersControl(overlayGroups = nam) %>%
    
    addFullscreenControl() %>%
    addMarkers(data = df, lng = ~LONG, lat = ~LAT, 
               icon = ~icons[mkshp], 
               label = lapply(dflab,htmltools::HTML),
               popup = ~paste0(dflab,
                               '<br>depth to screen: ',round(SCREEN_TOP_DEPTH_M,1),' m',
                               '<br>formation: <em>',FORMATION,'</em>',
                               '<br><a href="https://owrc.shinyapps.io/shydrograph/?i=',INT_ID,'" target="_blank">view timeseries</a>'))
  # addCircleMarkers(data = pnt, lng = ~LONG, lat = ~LAT, 
  #                weight = 1, color = 'black', fillColor = "#FEA62A", opacity = 0.8,
  #                radius = ~MannKendall10yrTau,
  #                label = lapply(pntlab,htmltools::HTML)) %>%
  
}