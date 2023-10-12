
library(dplyr)
library(ggplot2)
library(plotly)
library(scales)
# library(lubridate)






q <- "SELECT BH_ID, B.LOC_ID, L.LOC_NAME, L.LOC_NAME_ALT1, BH_DRILL_END_DATE, B.BH_DRILL_METHOD_CODE, MC.BH_DRILL_METHOD_DESCRIPTION
      FROM D_BOREHOLE AS B
      LEFT JOIN R_BH_DRILL_METHOD_CODE AS MC ON B.BH_DRILL_METHOD_CODE=MC.BH_DRILL_METHOD_CODE
      LEFT JOIN D_LOCATION AS L ON L.LOC_ID=B.LOC_ID"

df <- dbGetQuery(con,q)
head(df)


print(nrow(df[!is.na(df$BH_DRILL_END_DATE),])/nrow(df))
print(nrow(df[!is.na(df$BH_DRILL_METHOD_CODE),])/nrow(df))
print(nrow(df[!is.na(df$BH_DRILL_END_DATE) & !is.na(df$BH_DRILL_METHOD_CODE),])/nrow(df))



df.fixed <- df[!is.na(df$BH_DRILL_END_DATE) & !is.na(df$BH_DRILL_METHOD_CODE),] %>%
  distinct() %>%
  mutate(BH_DRILL_END_DATE=as.Date(BH_DRILL_END_DATE), BH_DRILL_METHOD_DESCRIPTION=as.factor(BH_DRILL_METHOD_DESCRIPTION)) %>%
  dplyr::filter(BH_DRILL_END_DATE > "1800-09-04") %>%
  arrange(BH_DRILL_END_DATE) %>%
  group_by(BH_DRILL_METHOD_CODE) %>%
  mutate(count=row_number()) %>%
  mutate(CDF=count/max(count))
  
  
  
  
# histogram
h <- df.fixed %>% ggplot() + 
  theme(axis.title = element_blank(), axis.text.x = element_blank(), axis.ticks = element_blank()) +
  geom_bar(aes(BH_DRILL_METHOD_DESCRIPTION, fill=BH_DRILL_METHOD_DESCRIPTION)) +
    scale_y_continuous(label=label_comma())




# CDF in html
p <- df.fixed %>% ggplot(aes(x=BH_DRILL_END_DATE, y=CDF)) +
    # theme(legend.position = "bottom") +
    geom_line(aes(color=BH_DRILL_METHOD_DESCRIPTION)) +
    labs(title="Drill Method", x="Date", y="CDF")



l <- subplot(p, style(h, showlegend = F), nrows = 2, margin = 0.04, heights = c(0.6, 0.4))


# ggplotly(p, tooltip = "text", height = 800) %>% 
#   plotly::layout(legend=list(x=0,
#                              y=-.15,
#                              title='Data Source',
#                              orientation='h'))

htmlwidgets::saveWidget(l, "external/cum-bh/cum-bh.html")

