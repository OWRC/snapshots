

library(odbc)
library(ggplot2)
library(dplyr)


con <- dbConnect(odbc(), Driver = "SQL Server", Server = "sqlserver2k16", 
                 Database = "OAK_20160831_MASTER", UID = "sql-webmm", PWD = "fv62Aq31", 
                 Port = 1433)


q <- "SELECT * FROM D_BOREHOLE"

df <- dbGetQuery(con,q)
head(df)



print(length(df[!is.nan(df$BH_DRILL_END_DATE),]$BH_DRILL_END_DATE))



df %>% ggplot(aes())








library(plotly)
library(lubridate)















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





cnts <- df %>%
  count(RD_DATE) %>%
  mutate(year=year(RD_DATE)) %>%
  group_by(year) %>%
  summarize(n=sum(n)/365.24)
# cnts <- df %>%
#   count(RD_DATE,LOC_STUDY) %>%
#   mutate(year=year(RD_DATE)) %>%
#   group_by(year,LOC_STUDY) %>%
#   summarize(n=sum(n)/365.24)
head(cnts)







p <- ggplot(gdf,aes(y=group_id*max(cnts$n)/max(group_id))) + 
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.title = element_blank()) +
  geom_linerange(aes(xmin = year(startdate), xmax = year(enddate), group=name), alpha=.5) +
  geom_point(aes(year(startdate), group=name),size=.5) +
  geom_point(aes(year(enddate), group=name),size=.5) +
  geom_line(data=cnts,aes(x=year,y=n), colour="red",size=2,alpha=0.5) +
  # geom_line(data=cnts,aes(x=year,y=n, colour=LOC_STUDY),size=1,alpha=0.85) + 
  scale_x_continuous(breaks=seq(min(year(gdf$startdate)),max(year(gdf$enddate)),by=10)) +
  labs(x='year',y='average annual number of concurrent stations reporting')

l <- ggplotly(p, tooltip = "name", height = 800) %>% 
  plotly::layout(legend=list(x=0, 
                             y=-.15,
                             title='Data Source',
                             orientation='h')) 
htmlwidgets::saveWidget(l, "external/gantt-gw/gantt-gw.html") 

