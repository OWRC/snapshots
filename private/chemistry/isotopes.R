
library(leaflet)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)


q <- "SELECT L.LOC_ID, L.INT_ID, SAM_ID, X AS EASTING, Y AS NORTHING, Z AS ELEVATION, X.LONG, X.LAT, [NAME], 
        INTERVAL_NAME, ALTERNATE_INTERVAL_NAME, READING_GROUP_NAME, 
        INT_TYPE, PARAMETER, RD_NAME_CODE, [VALUE], UNIT, QUALIFIER, SAMPLE_DATE, SCREEN_TOP_DEPTH_M, 
        MDL, UNCERTAINTY, SCREEN_GEOL_UNIT
        FROM V_GEN_LAB AS L
            LEFT JOIN R_READING_GROUP_CODE AS G ON G.READING_GROUP_CODE = L.GROUP_CODE
            LEFT JOIN (SELECT * FROM D_INTERVAL_FORM_ASSIGN_FINAL
                JOIN V_SYS_GEOL_UNIT_SHALLOW ON ASSIGNED_UNIT = GEOL_UNIT_CODE) AS Z ON L.INT_ID = Z.INT_ID
            LEFT JOIN V_SYS_LOC_COORDS AS C ON C.LOC_ID = L.LOC_ID
            LEFT JOIN (SELECT LOC_ID, INT_ID, FORMATION, SCREEN_TOP_DEPTH_M, WL_AVG_TOTAL_NUM FROM W_GENERAL_SCREEN) AS S ON L.INT_ID = S.INT_ID
            LEFT JOIN (SELECT LOC_ID, LONG, LAT FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL) AS X ON L.LOC_ID = X.LOC_ID
            WHERE (PARAMETER LIKE '3H%'
            OR PARAMETER LIKE '2H (D%'
            OR PARAMETER LIKE 'O18 (del%')
            AND [VALUE] IS NOT NULL
            AND X.LONG IS NOT NULL"
            # AND SCREEN_TOP_DEPTH_M<20
            # AND [VALUE] IS NOT NULL"
            # # WHERE [NAME] LIKE '%PGMN%'
            # # AND (PARAMETER LIKE 'Chloride' OR PARAMETER LIKE 'Bromide' OR PARAMETER LIKE 'sodium')"


df <- dbGetQuery(con,q) 
df$PARAMETER <- as.factor(df$PARAMETER)
print(levels(df$PARAMETER))


df <- filter(df, !(PARAMETER == "3H (Tritium)" & UNIT=='o/oo'))  





# df.mdl <- df[!is.na(df$QUALIFIER),]
df.val <- df %>% #df[is.na(df$QUALIFIER),] %>% 
  mutate(VALUE = ifelse(UNIT=='Bq/l',VALUE/0.118,VALUE),
         Depth = case_when(SCREEN_TOP_DEPTH_M < 20 ~ "shallow", TRUE ~ "deep")) %>%
  mutate(VALUE = ifelse(!is.na(df$QUALIFIER),NA,VALUE)) %>%
  group_by(INT_ID, PARAMETER) %>%
  mutate(n1=n(), n2=sum(is.na(VALUE))) %>%
  ungroup() %>%
  group_by(LOC_ID) %>%
  mutate(n=as.integer(mean(n1)), pmdl=mean(n2)/mean(n1)) %>%
  ungroup() %>%
  group_by(LOC_ID,INT_ID, NAME, LONG, LAT, EASTING, NORTHING, ELEVATION, SCREEN_TOP_DEPTH_M, SCREEN_GEOL_UNIT, PARAMETER, n, pmdl, Depth) %>%
  summarise(mean=mean(VALUE, na.rm=TRUE)) %>%
  spread(PARAMETER,mean) %>% 
  mutate(tooltip=paste0(NAME,"<br><sup>18</sup>0 ",round(`O18 (del O18)`,2),"<br>Deuterium ",round(`2H (Deuterium)`,2)))











makeMap <- function(df, name, palnam, strunit) {
  pal <- colorNumeric(
    palette = palnam,
    domain = df$value
  )
  df[!is.na(df$value) & !is.nan(df$value) & df$pmdl<1,] %>% leaflet(options = leafletOptions( #zoomControl = FALSE,
    attributionControl=FALSE)) %>%
    addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
    leaflet.extras::addFullscreenControl() %>%
    # leafem::addMouseCoordinates() %>%
    addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
    addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>% 
    addCircles(data=df[is.nan(df$value) & df$pmdl==1,],
               color = ~ifelse(Depth=="deep", "black", "darkred"),
               opacity = 1,
               label = ~paste0(NAME," ",Depth,': all ',n,' readings <MDL'),
               lng = ~LONG, lat = ~LAT,
               group = "&ltMDL") %>%
    addCircleMarkers(layerId = ~INT_ID,
                     group = ~Depth,
                     radius = ~rad,
                     weight = 2, #~ifelse(Depth=="deep", 1, 2),
                     color = ~ifelse(Depth=="deep", "#03F", "darkred"),
                     fillColor = ~pal(value),
                     opacity = 1,
                     fillOpacity = 1,
                     # group = ~FORMATION,
                     lng = ~LONG, lat = ~LAT,
                     label = ~paste0(NAME," ",Depth,': ',round(value,1),strunit,", n=",n),
                     popup = ~paste0('<b>',NAME,'</b><br>',Depth,' well',
                                     '<br><sup>18</sup>0: ',round(`O18 (del O18)`,1),
                                     '<br>Deuterium: ',round(`2H (Deuterium)`,1),
                                     '<br>Tritium: ',round(`3H (Tritium)`,1),
                                     '<br>',n,' readings, ',floor(pmdl*n*100),'% &ltMDL',
                                     '<br><a href="https://owrc.shinyapps.io/shychemo/?l=',LOC_ID,'">see chemograph</a>')
    ) %>% 
    addLegend("topright", pal = pal, values = ~value,
              title = name,
              bins = 5,
              opacity = 1
    ) %>% 
    addLayersControl(overlayGroups = c("deep","shallow", "&ltMDL"),
                     options = layersControlOptions(collapsed = FALSE)
    ) %>% 
    setView(lng = -79, lat = 44.45, zoom = 8) 
}








m <- makeMap(df.val %>% mutate(value=`3H (Tritium)`, rad = sqrt(`3H (Tritium)`)), "Mean measured tritium (TU)", "Greens", " TU")
htmlwidgets::saveWidget(m, file="chemistry/chem-tritium-map.html")


m <- makeMap(df.val %>% mutate(value=`O18 (del O18)`, rad = -`O18 (del O18)`-5), "Mean \u03B4<sup>18</sup>0(\u2030)", "Reds", "\u2030")
htmlwidgets::saveWidget(m, file="chemistry/chem-dO18-map.html")


m <- makeMap(df.val %>% mutate(value=`2H (Deuterium)`, rad = sqrt(-`2H (Deuterium)`)), "Mean \u03B4\u00B2H(\u2030)", "Blues", "\u2030")
htmlwidgets::saveWidget(m, file="chemistry/chem-deuterium-map.html")









# pal <- colorNumeric(
#   palette = 'Reds',
#   domain = df.val$`O18 (del O18)`
# )
# m <- df.val[!is.na(df.val$`O18 (del O18)`),] %>% leaflet(options = leafletOptions( #zoomControl = FALSE,
#                       attributionControl=FALSE)) %>%
#   addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
#   leaflet.extras::addFullscreenControl() %>%
#   # leafem::addMouseCoordinates() %>%
#   addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
#   addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%
#   # addCircles(data=df.mdl,
#   #            label = ~paste0(NAME,': < MDL'),
#   #            lng = ~LONG, lat = ~LAT) %>%
#   addCircleMarkers(layerId = ~INT_ID,
#                    group = ~Depth,
#                    radius = ~(-`O18 (del O18)`)-5,
#                    weight = ~ifelse(Depth=="deep", 1, 2),
#                    color = ~ifelse(Depth=="deep", "#03F", "darkred"),
#                    fillColor = ~pal(`O18 (del O18)`),
#                    opacity = 1,
#                    fillOpacity = 1,
#                    # group = ~FORMATION,
#                    lng = ~LONG, lat = ~LAT,
#                    label = ~paste0(NAME," ",Depth,': ',round(`O18 (del O18)`,1),"\u2030, n=",n),
#                    popup = ~paste0('<b>',NAME,'</b><br><sup>18</sup>0: ',round(`O18 (del O18)`,1),
#                                    '<br>Deuterium: ',round(`2H (Deuterium)`,1),
#                                    '<br>Tritium: ',round(`3H (Tritium)`,1),
#                                    '<br><a href="https://owrc.shinyapps.io/shychemo/?l=',LOC_ID,'">see chemograph</a>')
#                    ) %>%
#   addLegend("topright", pal = pal.r, values = ~`O18 (del O18)`,
#             title = "Mean \u03B4<sup>18</sup>0(\u2030)",
#             bins = 5,
#             opacity = 1
#   ) %>%
#   addLayersControl(overlayGroups = c("deep","shallow"),
#                    options = layersControlOptions(collapsed = FALSE)) %>%
#   setView(lng = -79, lat = 44.45, zoom = 8)
# 
# 
# htmlwidgets::saveWidget(m, file="chemistry/chem-dO18-map.html")
# 
# 
# 
# 
# #######################################################################################################################
# 
# 
# 
# 
# pal <- colorNumeric(
#   palette = 'Blues',
#   domain = df.val$`2H (Deuterium)`
# )
# m <- df.val[!is.na(df.val$`2H (Deuterium)`),] %>% leaflet(options = leafletOptions( #zoomControl = FALSE,
#   attributionControl=FALSE)) %>%
#   addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
#   leaflet.extras::addFullscreenControl() %>%
#   # leafem::addMouseCoordinates() %>%
#   addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
#   addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%
#   # addCircles(data=df.mdl,
#   #            label = ~paste0(NAME,': < MDL'),
#   #            lng = ~LONG, lat = ~LAT) %>%
#   addCircleMarkers(layerId = ~INT_ID,
#                    radius = ~sqrt(-`2H (Deuterium)`),
#                    weight = 1,
#                    fillColor = ~pal(`2H (Deuterium)`),
#                    opacity = 1,
#                    fillOpacity = 1,
#                    # group = ~FORMATION,
#                    lng = ~LONG, lat = ~LAT,
#                    label = ~paste0(NAME,': ',round(`2H (Deuterium)`,1)," \u2030, n=",n),
#                    popup = ~paste0('<b>',NAME,'</b><br><sup>18</sup>0: ',round(`O18 (del O18)`,1),
#                                    '<br>Deuterium: ',round(`2H (Deuterium)`,1),
#                                    '<br>Tritium: ',round(`3H (Tritium)`,1),
#                                    '<br><a href="https://owrc.shinyapps.io/shychemo/?l=',LOC_ID,'">see chemograph</a>')
#   ) %>%
#   addLegend("topright", pal = pal, values = ~`2H (Deuterium)`,
#             title = "Measured Deuterium<br>in shallow wells<br>\u03B4\u00B2H(\u2030)",
#             bins = 5,
#             opacity = 1
#   ) %>%
#   setView(lng = -79, lat = 44.45, zoom = 8)
# 
# 
# htmlwidgets::saveWidget(m, file="chemistry/chem-deuterium-map.html")
# 
# 
# 
# 
# #######################################################################################################################
# 
# 
# 
# 
# 
# pal <- colorNumeric(
#   palette = 'Greens',
#   domain = df.val$`3H (Tritium)`
# )
# m <- df.val[!is.na(df.val$`3H (Tritium)`),] %>% leaflet(options = leafletOptions( #zoomControl = FALSE,
#   attributionControl=FALSE)) %>%
#   addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
#   leaflet.extras::addFullscreenControl() %>%
#   # leafem::addMouseCoordinates() %>%
#   addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
#   addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%
#   # addCircles(data=df.mdl,
#   #            label = ~paste0(NAME,': < MDL'),
#   #            lng = ~LONG, lat = ~LAT) %>%
#   addCircleMarkers(layerId = ~INT_ID,
#                    radius = ~sqrt(`3H (Tritium)`),
#                    weight = 1,
#                    fillColor = ~pal(`3H (Tritium)`),
#                    opacity = 1,
#                    fillOpacity = 1,
#                    # group = ~FORMATION,
#                    lng = ~LONG, lat = ~LAT,
#                    label = ~paste0(NAME,': ',round(`3H (Tritium)`,1)," TU, n=",n),
#                    popup = ~paste0('<b>',NAME,'</b><br><sup>18</sup>0: ',round(`O18 (del O18)`,1),
#                                    '<br>Deuterium: ',round(`2H (Deuterium)`,1),
#                                    '<br>Tritium: ',round(`3H (Tritium)`,1),
#                                    '<br><a href="https://owrc.shinyapps.io/shychemo/?l=',LOC_ID,'">see chemograph</a>')
#   ) %>%
#   addLegend("topright", pal = pal, values = ~`3H (Tritium)`,
#             title = "Measured Tritium<br>in shallow wells (TU)",
#             bins = 5,
#             opacity = 1
#   ) %>%
#   setView(lng = -79, lat = 44.45, zoom = 8)
# 
# 
# htmlwidgets::saveWidget(m, file="chemistry/chem-tritium-map.html")


  







