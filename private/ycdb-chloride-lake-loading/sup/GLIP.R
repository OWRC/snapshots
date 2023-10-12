


# df.GLIP <- read.csv("supp/GLIP/All_Lakes_GLIP.csv")
df.GLIP.coord <- read.csv("dat/GLIP-coords.csv")
df.GLIP <- read.csv("dat/All_Lakes_GLIP.csv") %>%
  merge(df.GLIP.coord, by.x='FACILITY_NAME', by.y='name')

df.GLIP.coord$name <- reorder(df.GLIP.coord$name, df.GLIP.coord$long)
df.GLIP$FACILITY_NAME <- reorder(df.GLIP$FACILITY_NAME, df.GLIP$long)

# df.GLIP$YEAR = as.factor(df.GLIP$YEAR)
df.GLIP$DATE_YYYYMMDD = as.Date(df.GLIP$DATE_YYYYMMDD)
df.GLIP$FACILITY_NAME = as.factor(df.GLIP$FACILITY_NAME)
# levels(df.GLIP$FACILITY_NAME)
df.GLIP$PARAMETER = as.factor(df.GLIP$PARAMETER)
# levels(df.GLIP$PARAMETER)



# p.LO <- 
p.GLIP <- df.GLIP %>% 
  filter(PARAMETER  == "Chloride", LAKE == c("Lake Ontario","Lake Erie"), FACILITY_NAME != "BELLEVILLE - GERRY O'CONNOR WATER TREATMENT PLANT") %>%
  group_by(FACILITY_NAME,YEAR,LAKE,long,lat) %>%
  summarise(val=mean(VALUE, na.rm = TRUE)) %>%
  ggplot(aes(YEAR,val, group=FACILITY_NAME, color=FACILITY_NAME)) +
    theme_bw() + 
    theme(legend.position = 'none') + #, legend.direction="vertical") + #c(.5,.9)) +
    
    stat_smooth() +
    geom_point() + # aes(shape=LAKE)) +
    scale_color_viridis(name=NULL, discrete = TRUE) +
    ylim(c(NA,35)) +
    # scale_color_continuous() +
    # scale_color_manual() +
    facet_grid(cols = vars(LAKE)) +
    labs(x=NULL,y="Chloride (mg/L)")


p.bm <- basemapGL + 
  geom_point(data=df.GLIP.coord %>% filter(name != "BELLEVILLE - GERRY O'CONNOR WATER TREATMENT PLANT"), aes(long,lat,color=name), size=4) +
  coord_sf(ylim = c(41.5, 44.5), xlim = c(-83.5, -74)) +
  scale_color_viridis(name=NULL, discrete = TRUE) +
  labs(x=NULL,y=NULL)



grid.arrange(p.bm, p.GLIP, ncol=1, nrow =2, heights=c(2,3))







# 
# p.LE <- df.GLIP %>% 
#   filter(PARAMETER  == "Chloride", LAKE == "Lake Erie") %>%
#   group_by(FACILITY_NAME,YEAR,long) %>%
#   summarise(val=mean(VALUE, na.rm = TRUE)) %>%
#   ggplot(aes(YEAR,val,group=FACILITY_NAME,color = FACILITY_NAME)) +
#   theme_bw() +
#   theme(legend.position = 'bottom', legend.direction="vertical") + #c(.5,.9)) +
#   geom_point() +
#   stat_smooth() +
#   scale_color_viridis(name=NULL, discrete = TRUE)
# 
# 
# 
# 
# 
# # http://www.sthda.com/english/articles/24-ggpubr-publication-ready-plots/81-ggplot2-easy-way-to-mix-multiple-graphs-on-the-same-page/
# # Arrange plots using arrangeGrob
# # returns a gtable (gt)
# gt <- arrangeGrob(p,                               # bar plot spaning two columns
#                   p.LO, p.LE,                               # box plot and scatter plot
#                   ncol = 2, nrow = 2, 
#                   heights = c(8,16),
#                   layout_matrix = rbind(c(1,1), c(2,3)))
# # Add labels to the arranged plots
# as_ggplot(gt) +                                # transform to a ggplot
#   draw_plot_label(label = c("A", "B", "C"), size = 15,
#                   x = c(0, 0, 0.5), y = c(1, 0.5, 0.5)) # Add labels
# 




