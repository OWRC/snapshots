
library(dplyr)
library(ggplot2)
library(plotly)
library(lubridate)
library(stringr)



q <- "SELECT L.LOC_ID, LOC_NAME, LOC_NAME_ALT1, LOC_STUDY, RD_NAME_CODE, RD_DATE
      FROM (
          SELECT INT_ID, RD_NAME_CODE, RD_DATE, count(RD_NAME_CODE) as nParam
          FROM OAK_20160831_MASTER.dbo.D_INTERVAL_TEMPORAL_2
          WHERE RD_VALUE IS NOT NULL
          AND RD_DATE IS NOT NULL
          AND RD_NAME_CODE = 629 OR RD_NAME_CODE = 628
          GROUP BY INT_ID, RD_NAME_CODE, RD_DATE    
      ) AS IT
      LEFT JOIN OAK_20160831_MASTER.dbo.D_INTERVAL AS I ON IT.INT_ID = I.INT_ID
      LEFT JOIN OAK_20160831_MASTER.dbo.D_LOCATION AS L ON I.LOC_ID = L.LOC_ID
      ORDER BY L.LOC_ID, RD_DATE"

qdf <- dbGetQuery(con,q) #%>% save(file="O:/q.Rda")
df <- qdf %>%
  mutate(RD_DATE = as.Date(RD_DATE)) %>%
  filter(year(RD_DATE)<year(Sys.Date())) %>%
  distinct()

head(df)
print(unique(df$LOC_STUDY))





# # load("O:/q.Rda")
# View(
#   
# df %>%
#   mutate(RD_DATE=as.Date(RD_DATE)) %>%  # convert to day-dates
#   group_by(LOC_ID,RD_NAME_CODE) %>%
#   mutate(n=n()) %>%
#   filter(n>=35) %>%  # remove small samples
#   ungroup() %>%
# 
#   arrange(RD_DATE) %>%
#   mutate(diff = c(0, diff(RD_DATE)), periodID = 1 + cumsum(diff > 1)) %>%
#   group_by(LOC_ID,LOC_NAME,LOC_NAME_ALT1,LOC_STUDY,RD_NAME_CODE,periodID) %>%
# 
#   summarise(n = max(n),
#             days = last(RD_DATE) - first(RD_DATE),
#             startdate = first(RD_DATE),
#             enddate = last(RD_DATE)) %>%
#   ungroup() %>%
#   arrange(startdate,LOC_NAME) %>% 
#   mutate(group_id = group_indices(., factor(LOC_ID, levels = unique(LOC_ID)))) %>%
#   mutate(periodID = as.integer(periodID), days = as.integer(days), LOC_STUDY = as.factor(LOC_STUDY), RD_NAME_CODE = as.factor(as.integer(RD_NAME_CODE))) %>%
#   mutate(group_id = max(group_id) - group_id) # invert group_id
# 
# )



# see: https://stackoverflow.com/questions/33285302/r-counting-consecutive-days
gdf <- df %>% 
  arrange(RD_DATE) %>%
  mutate(diff = c(0, diff(RD_DATE)),
         periodID = 1 + cumsum(diff > 1),
         name = paste0(LOC_NAME,': ',LOC_NAME_ALT1),
         src = LOC_STUDY,
         typ = RD_NAME_CODE) %>%
  select(-c(LOC_NAME, LOC_NAME_ALT1, LOC_STUDY, RD_NAME_CODE)) %>%
  group_by(src, typ, LOC_ID, name, periodID) %>%
  summarise(days = last(RD_DATE) - first(RD_DATE),
            startdate = first(RD_DATE),
            enddate = last(RD_DATE)) %>%
  ungroup() %>%
  filter(days>0) %>%
  arrange(startdate,name) %>% 
  mutate(group_id = group_indices(., factor(LOC_ID, levels = unique(LOC_ID)))) %>%
  mutate(periodID = as.integer(periodID), days = as.integer(days), src = as.factor(src), typ = as.factor(typ)) %>%
  mutate(group_id = max(group_id) - group_id) # invert group_id

head(gdf)





cnts <- df %>%
  count(RD_DATE) %>%
  mutate(year=year(RD_DATE)) %>%
  group_by(year) %>%
  filter(year>min(year(gdf$startdate))) %>%
  summarize(n=sum(n)/365.24)
head(cnts)

# srccnts <- df %>%
#   count(RD_DATE,LOC_STUDY) %>%
#   mutate(year=year(RD_DATE)) %>%
#   group_by(year,LOC_STUDY) %>%
#   summarize(n=sum(n)/365.24)
# head(srccnts)





p <- ggplot(gdf,aes(y=group_id*max(cnts$n)/max(group_id))) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  geom_line(data=cnts,aes(x=year,y=n), colour="red",linewidth=2,alpha=0.5) +
  # geom_line(data=srccnts,aes(x=year,y=n, colour=LOC_STUDY),linewidth=1,alpha=0.85) +    
  geom_linerange(aes(xmin = year(startdate), xmax = year(enddate), group=name), alpha=.5) +
  geom_point(aes(year(startdate), group=name),size=.5) +
  geom_point(aes(year(enddate), group=name),size=.5) +
  scale_x_continuous(breaks=seq(min(year(gdf$startdate)),max(year(gdf$enddate)),by=10)) +
  labs(title='Groundwater Monitors',x='year',y='average annual number of concurrent stations reporting')

l <- ggplotly(p, tooltip = "name", height = 800) %>% 
  plotly::layout(legend=list(x=0, 
                             title='Data Source',
                             orientation='h')) 
htmlwidgets::saveWidget(l, "gantt-gw.html") 

