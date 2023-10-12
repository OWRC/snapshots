


q <- "SELECT L.LOC_ID, L.INT_ID, SAM_ID, L.NAME, INTERVAL_NAME,
ALTERNATE_INTERVAL_NAME, READING_GROUP_NAME,
INT_TYPE, PARAMETER, [VALUE], UNIT, QUALIFIER, MDL, UNCERTAINTY,
SCREEN_GEOL_UNIT, SAMPLE_DATE, RD_NAME_CODE, LAT, LONG, SCREEN_TOP_DEPTH_M
FROM V_GEN_LAB AS L
INNER JOIN R_READING_GROUP_CODE AS G ON G.READING_GROUP_CODE = L.GROUP_CODE
INNER JOIN V_SYS_LOC_COORDS AS C ON C.LOC_ID = L.LOC_ID
LEFT JOIN W_GENERAL_SCREEN AS S ON S.INT_ID = L.INT_ID
WHERE PARAMETER LIKE 'Chloride'
AND UNIT LIKE 'mg/L'
AND LAT IS NOT NULL
AND [VALUE] > 0.1
AND [VALUE] < 10000"

qdf <- dbGetQuery(con,q) 
# print(length(unique(qdf$LOC_NAME))==length(qdf$LOC_NAME))
# View(qdf)




## pick by location
df <- qdf
coordinates(df) <- ~ LONG + LAT
proj4string(df) <- proj4string(capture.area)      

dft <- df@data
dft$LNG=df@coords[,1]
dft$LAT=df@coords[,2]

df <- dft[complete.cases(over(df, capture.area)),]

# group by location, summarize by location maximum
dfg <- df %>%
  group_by(LOC_ID,LNG,LAT,SCREEN_GEOL_UNIT,INT_TYPE,SCREEN_TOP_DEPTH_M) %>%
  summarise(VALUE=max(VALUE, na.rm=TRUE)) %>% 
  mutate(Source=case_when(INT_TYPE=='Surface Water - All' ~ 'surface', 
                          SCREEN_TOP_DEPTH_M<=20 ~ 'deep GW', 
                          SCREEN_TOP_DEPTH_M>20 ~ 'shallow GW', 
                          TRUE ~ 'unknown')) %>%
  mutate(SCREEN_GEOL_UNIT = str_remove(SCREEN_GEOL_UNIT, "\\ \\(ORMGP\\)"))

dfg$Source <- factor(dfg$Source, levels = c('shallow GW','deep GW','surface','unknown'))

nr <- function(df) format(nrow(df),big.mark=",",scientific=FALSE)
