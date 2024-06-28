
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)


df <- read.csv("O:/MSC/msc.0stationlist.csv") %>% 
  replace(.=="", NA) %>%
  select(-c(dly_begin,dly_end,mly_begin,mly_end)) %>% 
  drop_na() %>%
  arrange(hly_begin,station_name) %>%
  mutate(group_id = row_number())
head(df)



# cnts <- df %>%
#   count(RD_DATE,LOC_STUDY) %>%
#   mutate(year=year(RD_DATE)) %>%
#   group_by(year,LOC_STUDY) %>%
#   summarize(n=sum(n)/365.24)
# head(cnts)






p <- ggplot(df,aes(y=-group_id)) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
        axis.text.y = element_blank(),
        panel.grid.minor.x = element_line(),
        legend.title = element_blank()) +
  geom_linerange(aes(xmin = year(hly_begin), xmax = year(hly_end), group=station_name), alpha=.5) +
  geom_point(aes(year(hly_begin), group=station_name),size=.5) +
  geom_point(aes(year(hly_end), group=station_name),size=.5) +
  # geom_line(data=cnts,aes(x=year,y=n), colour="red",size=2,alpha=0.5) +
  # geom_line(data=cnts,aes(x=year,y=n, colour=LOC_STUDY),size=1,alpha=0.85) +
  # scale_x_continuous(breaks=seq(min(year(df$hly_begin)),max(year(df$hly_end)),by=10),
  #                    minor_breaks = seq(min(year(df$hly_begin)),max(year(df$hly_end)),by=1)) +
  labs(x='year',y=NULL)

ttxt <- rep("",max(year(df$hly_end))-min(year(df$hly_begin))+1)
ttxt[seq(8,max(year(df$hly_end))-min(year(df$hly_begin))+1,10)] <- as.character(seq(min(year(df$hly_begin)),max(year(df$hly_end)),by=1))[seq(8,max(year(df$hly_end))-min(year(df$hly_begin))+1,10)] # every 9th tick is labelled
l <- ggplotly(p, tooltip = "station_name", height = 800) %>%
  layout(xaxis = list(showline=T, 
                      tickvals=seq(min(year(df$hly_begin)),max(year(df$hly_end)),by=1),
                      ticktext=ttxt
                      )
         )
htmlwidgets::saveWidget(l, "external/gantt-msc/gantt-msc-hourly.html")

