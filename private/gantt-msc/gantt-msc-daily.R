
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(lubridate)



# scraped using: msc.0stationlist.py
df <- read.csv("O:/MSC/msc.0stationlist.csv") %>% 
  replace(.=="", NA) %>%
  select(-c(hly_begin,hly_end,mly_begin,mly_end)) %>% 
  drop_na() %>%
  arrange(dly_begin,station_name) %>%
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
  geom_linerange(aes(xmin = year(dly_begin), xmax = year(dly_end), group=station_name), alpha=.5) +
  geom_point(aes(year(dly_begin), group=station_name),size=.5) +
  geom_point(aes(year(dly_end), group=station_name),size=.5) +
  # geom_line(data=cnts,aes(x=year,y=n), colour="red",size=2,alpha=0.5) +
  # geom_line(data=cnts,aes(x=year,y=n, colour=LOC_STUDY),size=1,alpha=0.85) +
  # scale_x_continuous(breaks=seq(min(year(df$dly_begin)),max(year(df$dly_end)),by=10),
  #                    minor_breaks = seq(min(year(df$dly_begin)),max(year(df$dly_end)),by=1)) +
  labs(x='year',y=NULL)

ttxt <- rep("",max(year(df$dly_end))-min(year(df$dly_begin))+1)
seq1 <- seq(1,max(year(df$dly_end))-min(year(df$dly_begin))+1,10)
ttxt[seq1] <- as.character(seq(min(year(df$dly_begin)),max(year(df$dly_end)),by=1))[seq1] # every 9th tick is labelled
l <- ggplotly(p, tooltip = "station_name", height = 800) %>%
  layout(xaxis = list(showline=T, 
                      tickvals=seq(min(year(df$dly_begin)),max(year(df$dly_end)),by=1),
                      ticktext=ttxt
                      )
         )
htmlwidgets::saveWidget(l, "external/gantt-msc/gantt-msc-daily.html")

