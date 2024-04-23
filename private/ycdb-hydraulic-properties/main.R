
library(dplyr)
library(stringr)


q <- "SELECT L.LOC_ID, INT_ID, LOC_NAME, LOC_NAME_ALT1, LAT, LONG, FORMATION, GEOL_UNIT_CODE, SCREEN_TOP_DEPTH_M, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY, 
              SPEC_CAP_LPMM, TSC_M2S, TSC_SCR_M2S, K_MS, KSC_MS, KSC_SCR_MS
                  			FROM D_LOCATION AS L
                  			INNER JOIN (
                  				SELECT *
                  				FROM W_GENERAL_SCREEN
                  					-- WHERE SPEC_CAP_LPMM IS NOT NULL
                  					-- AND WL_AVG_TOTAL_NUM >34
                  			) AS S ON L.LOC_ID = S.LOC_ID
                  			INNER JOIN (
                  				SELECT LOC_ID, LONG, LAT
                  				FROM V_SYS_LOC_COORDS
                  				WHERE LAT IS NOT NULL
                  			) AS C ON L.LOC_ID = C.LOC_ID"

df.full <- dbGetQuery(con,q) %>%
  mutate(FORMATION = str_replace(FORMATION, ' \\(ORMGP\\)', ''))

# WHERE WL_AVG_TOTAL_NUM>34
# AND WL_START_DATE_MDY != 'NA'

df.full$FORMATION[is.na(df.full$FORMATION)] <- "unknown"
df.full$FORMATION = as.factor(df.full$FORMATION)
df.full$LOC_NAME_ALT1 <- iconv( x = df.full$LOC_NAME_ALT1, from = "UTF-8", to = "UTF-8", sub = "" ) # https://stackoverflow.com/questions/51397728/invalid-utf-8-error-when-saving-leaflet-widget-in-r
levels(df.full$FORMATION)


layers.ordered <- c(
  "Late Stage Glaciolacustrine-Glaciofluvial",
  "Halton Till",
  "Mackinaw/Oak Ridges",
  "Channel - Silt",
  "Channel - Sand",
  "Upper Newmarket",
  "Inter Newmarket Sediment",
  "Lower Newmarket",
  # "Newmarket Till/Northern Till",
  "Thorncliffe",
  "Sunnybrook",
  "Scarborough",
  "Bedrock - Undifferentiated",
  "unknown"
)

aquifer.GEOL_UNIT_CODE <- c(3,5,12,59,65)

pal <- leaflet::colorFactor(
  palette = c("#cb4f31", "#52c274", "#c25abc", "#65af3a", "#7a67ca", "#b6b138", "#6b8fce", "#d79139", "#4cbdaf", "#d1416d", "#447f47", "#bc6990", "#a0b26a", "#c77a5c", "#7e7029"),
  # domain = df$FORMATION
  levels = layers.ordered
)
