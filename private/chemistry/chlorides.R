
library(leaflet)
library(dplyr)


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
            WHERE PARAMETER LIKE 'Chloride'
            AND SCREEN_TOP_DEPTH_M<20
            AND [VALUE] IS NOT NULL"
            # WHERE [NAME] LIKE '%PGMN%'
            # AND (PARAMETER LIKE 'Chloride' OR PARAMETER LIKE 'Bromide' OR PARAMETER LIKE 'sodium')"


df <- dbGetQuery(con,q)


# > unique(df$PARAMETER)
# [1] "Bromide"  "Chloride" "Sodium"
df <- df %>% #filter(PARAMETER=="Chloride", SCREEN_TOP_DEPTH_M<20) %>%
  group_by(INT_ID) %>%
  mutate(n=n()) %>%
  filter(n>4) %>%
  
  group_by(LOC_ID,INT_ID, NAME, LONG, LAT, EASTING, NORTHING, ELEVATION, SCREEN_TOP_DEPTH_M, SCREEN_GEOL_UNIT) %>%
  summarise(mean=mean(VALUE),n=n())




ormgp.bound <- readLines("https://www.dropbox.com/s/lrdycz5eomw09hr/ORMGP_Area_20210205-Drawing-simplWGS.geojson?dl=1") %>% paste(collapse = "\n")
orm.bound <- readLines("https://www.dropbox.com/s/5f1iia0lnmwgcdo/oakRidgesMoraine.geojson?dl=1") %>% paste(collapse = "\n")

pal <- colorNumeric(
  palette = 'Reds',
  domain = df$mean
)

m <- df %>% leaflet(options = leafletOptions( #zoomControl = FALSE,
                      attributionControl=FALSE)) %>%
  addTiles(group='OSM') %>% # addProviderTiles(providers$OpenTopoMap) %>% #
  leaflet.extras::addFullscreenControl() %>%
  # leafem::addMouseCoordinates() %>%
  addGeoJSON(orm.bound, weight = 3, color = "#e08924", stroke = FALSE, fillOpacity = 0.5) %>%
  addGeoJSON(ormgp.bound, weight = 4, fillOpacity = 0, dashArray = c(10, 5), opacity = .5, group = "ORMGP jurisdiction") %>%
  addCircleMarkers(layerId = ~INT_ID,
                   radius = ~sqrt(mean),
                   weight = 1,
                   fillColor = ~pal(mean),
                   opacity = 1,
                   fillOpacity = 1,
                   # group = ~FORMATION,
                   lng = ~LONG, lat = ~LAT,
                   label = ~paste0(NAME,': ',round(mean,1),"mg/l"),
                   popup = ~paste0('<b>',NAME,'</b><br><a href="https://owrc.shinyapps.io/shychemo/?l=',LOC_ID,'">see chemograph</a>')
                   ) %>%
  addLegend("topright", pal = pal, values = ~mean,
            title = "Mean measured<br>Chloride (mg/L)",
            bins = 5,
            opacity = 1
  ) %>%
  setView(lng = -79, lat = 44.45, zoom = 8)


htmlwidgets::saveWidget(m, file="chemistry/chem-chloride-map.html")
  