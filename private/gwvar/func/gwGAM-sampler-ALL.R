
library(gridExtra)
library(grid)

# constants
mult <- 1.96 # 2.576 # 5 # 1.96


# colSimObs <- c('#FEA62A','#1f78b4')
colSimObs <- c("#EE6C4D" ,"#16557F")

source("func/GAMrange.coll.R", local = TRUE)$value
source("func/GAM.grid.R", local = TRUE)$value
source("func/MannKendall.R", local = TRUE)$value











# default.theme <- theme(legend.background = element_rect(fill = "#a6cee3"),
#                  legend.key = element_rect(fill = "#a6cee3", color = NA),
#                  plot.background = element_rect(fill = "#a6cee3"),
#                  panel.border = element_rect(colour = "#16557F", fill=NA),
#                  panel.background = element_rect(fill = "#a6cee3",
#                                                  colour = "#a6cee3",
#                                                  size = 0.5, 
#                                                  linetype = "solid"),
#                  panel.grid.major = element_line(size = 0.35, 
#                                                  linetype = 'solid',
#                                                  colour = "#29ABE2"), 
#                  panel.grid.minor = element_line(size = 0.25, 
#                                                  linetype = 'solid',
#                                                  colour = "#29ABE2"),
#                  plot.title = element_text(colour='#16557F'),
#                  axis.title = element_text(colour='#16557F'),
#                  axis.text = element_text(colour='#16557F'),
#                  axis.ticks = element_line(colour = "#16557F")
#                  )
