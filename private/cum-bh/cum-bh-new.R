

library(dplyr)
library(ggplot2)
library(scales)












q <- "SELECT L.LOC_ID, INT_ID, LOC_NAME, LOC_NAME_ALT1, FORMATION, FM_THICKNESS_M, SCREEN_TOP_DEPTH_M, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY
FROM D_LOCATION AS L
JOIN (
  SELECT LOC_ID, INT_ID, FORMATION, FM_THICKNESS_M, SCREEN_TOP_DEPTH_M, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY
  FROM W_GENERAL_SCREEN 
) AS S ON L.LOC_ID = S.LOC_ID"

df <- dbGetQuery(con,q)
head(df)



ggplot(df, aes(x=SCREEN_TOP_DEPTH_M, y = after_stat(count / sum(count)))) +
  theme_bw() +
  geom_histogram(bins=100) +
  xlim(c(0,150)) +
  scale_y_continuous(labels = scales::percent) +
  labs(title="Distribution of wells by screened depth",
       x="Screen Depth (mbgs)",
       y="Proportion (%)")



ggplot(df, aes(x=FM_THICKNESS_M, y = after_stat(count / sum(count)))) +
  theme_bw() +
  geom_histogram(bins=100) +
  xlim(c(0,125)) +
  scale_y_continuous(labels = scales::percent) +
  labs(title="Distribution of wells by screened formation thickness",
       x="Formation thickness (m)",
       y="Proportion (%)")



q <- "SELECT * FROM V_SUM_BH_DRILL_GROUP_YEAR"

df <- dbGetQuery(con,q)
head(df)

ggplot(df, aes(y=RCOUNT,x=DATE_Y,fill=BH_DRILL_METHOD_DESCRIPTION)) +
  theme_bw() +
  theme(legend.position = 'bottom',
        legend.title=element_blank()) +
  geom_bar(stat='identity') +
  labs(title="Distribution of Well Drilling methods by reporting date",
       x=NULL, y='count')

