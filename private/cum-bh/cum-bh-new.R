
library(tidyr)
library(dplyr)
library(ggplot2)
library(scales)
library(stringr)
library(lubridate)



lev <- c('Mackinaw/Oak Ridges','Inter Newmarket Sediment','Channel - Sand','Thorncliffe','Scarborough','Bedrock - Undifferentiated')


q <- "SELECT L.LOC_ID, INT_ID, LOC_NAME, LOC_NAME_ALT1, FORMATION, FM_THICKNESS_M, SCREEN_TOP_DEPTH_M, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY
FROM D_LOCATION AS L
JOIN (
  SELECT LOC_ID, INT_ID, FORMATION, FM_THICKNESS_M, SCREEN_TOP_DEPTH_M, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY
  FROM W_GENERAL_SCREEN 
  WHERE WL_START_DATE_MDY IS NOT NULL
) AS S ON L.LOC_ID = S.LOC_ID
JOIN (
  SELECT LOC_ID
  FROM V_SYS_MOE_LOCATIONS
) AS M ON L.LOC_ID = M.LOC_ID"

df <- dbGetQuery(con,q) %>%
  mutate(across('FORMATION', str_replace, ' \\(ORMGP\\)', '')) %>%
  mutate(FORMATION=factor(FORMATION,levels=lev)) %>%
  mutate(drillyear=year(as.Date(WL_START_DATE_MDY,"%m/%d/%Y"))) %>%
  filter(drillyear>=1930) %>%
  mutate(drillyearrng=cut(drillyear, breaks=seq(1930,2030,20), right = FALSE, dig.lab=4)) %>%
  mutate(year=paste0(sub("\\[(.+),.*", "\\1", drillyearrng),' to ',sub("[^,]*,([^]]*)\\)", "\\1", drillyearrng)))

head(df)



ggplot(df, aes(x=SCREEN_TOP_DEPTH_M, y = after_stat(count / sum(count)), fill=year)) +
  theme_bw() +
  theme(legend.position = c(.8,.8)) +
  geom_histogram(bins=75) +
  xlim(c(0,150)) +
  scale_y_continuous(labels = scales::percent) +
  labs(title="Distribution of wells by screened depth",
       x="Screen Depth (mbgs)",
       y="Proportion (%)") +
  xlim(c(0,125))



ggplot(df, aes(x=FM_THICKNESS_M, y = after_stat(count / sum(count)), fill=FORMATION)) +
  theme_bw() +
  theme(legend.position = c(.8,.8)) +
  geom_histogram(bins=100) +
  xlim(c(0,100)) +
  scale_y_continuous(labels = scales::percent) +
  labs(title="Distribution of wells by screened formation thickness",
       x="Formation thickness (m)",
       y="Proportion (%)")





q <- "SELECT * FROM V_SUM_BH_DRILL_GROUP_YEAR"

df <- dbGetQuery(con,q)
head(df)

ggplot(df, aes(y=rcount,x=ryear,fill=bh_drill_method_alt_code)) +
  theme_bw() +
  theme(legend.position = 'bottom',
        legend.title=element_blank()) +
  geom_bar(stat='identity') +
  labs(title="Distribution of Well Drilling methods by reporting date",
       x=NULL, y='count') +
  xlim(c(1940,NA))

