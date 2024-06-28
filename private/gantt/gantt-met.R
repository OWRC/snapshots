

library(dplyr)
library(ggplot2)
library(plotly)
library(lubridate)
library(stringr)




q <- "SELECT L.LOC_ID, LOC_NAME, LOC_NAME_ALT1, LOC_STUDY, RD_DATE
      FROM (
          SELECT INT_ID, RD_DATE, count(RD_NAME_CODE) as nParam
          FROM OAK_20160831_MASTER.dbo.D_INTERVAL_TEMPORAL_3
          WHERE RD_VALUE IS NOT NULL
          AND RD_DATE IS NOT NULL
          GROUP BY INT_ID, RD_DATE    
      ) AS IT
      LEFT JOIN OAK_20160831_MASTER.dbo.D_INTERVAL AS I ON IT.INT_ID = I.INT_ID
      LEFT JOIN OAK_20160831_MASTER.dbo.D_LOCATION AS L ON I.LOC_ID = L.LOC_ID
      ORDER BY L.LOC_ID, RD_DATE"

qdf <- dbGetQuery(con,q)

df <- qdf %>%
  mutate(RD_DATE = as.Date(RD_DATE)) %>%
  filter(!(LOC_STUDY %in% c('PGMN - TRCA; MOE-1974 to 1980 OW Network'))) %>%
  mutate(LOC_STUDY = if_else(str_detect(LOC_STUDY, 'TRCA - SW Gauge Station'), 'TRCA', LOC_STUDY)) %>%
  mutate(LOC_STUDY = factor(LOC_STUDY))

head(df)
print(unique(df$LOC_STUDY))





# see: https://stackoverflow.com/questions/33285302/r-counting-consecutive-days
gdf <- df %>% 
  distinct() %>%
  arrange(RD_DATE) %>%
  mutate(diff = c(0, diff(RD_DATE)),
         periodID = 1 + cumsum(diff > 1),
         name = paste0(LOC_NAME,': ',LOC_NAME_ALT1),
         src = LOC_STUDY) %>%
  select(-c(LOC_NAME, LOC_NAME_ALT1, LOC_STUDY)) %>%
  group_by(src, LOC_ID, name, periodID) %>%
  summarise(days = last(RD_DATE) - first(RD_DATE),
            startdate = first(RD_DATE),
            enddate = last(RD_DATE)) %>%
  ungroup() %>%
  arrange(startdate,name) %>% 
  mutate(group_id = group_indices(., factor(LOC_ID, levels = unique(LOC_ID)))) %>%
  mutate(periodID = as.integer(periodID), days = as.integer(days), src = as.factor(src)) %>%
  mutate(group_id = max(group_id) - group_id) # invert group_id

head(gdf)





allcnts <- df %>%
  count(RD_DATE) %>%
  mutate(year=year(RD_DATE)) %>%
  group_by(year) %>%
  summarize(n=sum(n)/365.24)
head(allcnts)

srccnts <- df %>%
  count(RD_DATE,LOC_STUDY) %>%
  mutate(year=year(RD_DATE)) %>%
  group_by(year,LOC_STUDY) %>%
  summarize(n=sum(n)/365.24)
head(srccnts)




p <- ggplot(gdf,aes(y=group_id*max(srccnts$n)/max(group_id))) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  geom_line(data=allcnts,aes(x=year,y=n), colour="red",linewidth=2,alpha=0.5) +
  geom_line(data=srccnts,aes(x=year,y=n, colour=LOC_STUDY),linewidth=1,alpha=0.85) +    
  geom_linerange(aes(xmin = year(startdate), xmax = year(enddate), group=name, colour=src), alpha=.5) + 
  geom_point(aes(year(startdate), group=name),size=.5) +
  geom_point(aes(year(enddate), group=name),size=.5) +
  scale_x_continuous(breaks=seq(min(year(gdf$startdate)),max(year(gdf$enddate)),by=10)) +
  labs(title='Daily Meteorological Stations', x='year',y='average annual number of concurrent stations reporting')

l <- ggplotly(p, tooltip = "name", height = 800) %>% 
  plotly::layout(legend=list(x=0, 
                             title='Data Source',
                             orientation='h')) 
htmlwidgets::saveWidget(l, "gantt-met.html") 

