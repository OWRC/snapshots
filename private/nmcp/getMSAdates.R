

library(ggplot2)
library(dplyr)

d <- read.csv('getMSAdates.txt', header=FALSE)

d %>%
  mutate(date=as.Date(as.character(V1), format = "%y%m%d"),
         year=format(date, format = "%Y")) %>% 
  ggplot(aes(year)) + 
    geom_bar(stat = "count") + 
    labs(title = paste0("Annual number of models shared (total=",length(d$V1),")"), x=NULL, y="number per year")
