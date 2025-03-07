


## must run main.R






binwidth <- 30

p1 <- ggplot(df) +
  geom_histogram(aes(x=normSlow), colour = 1, fill = "white", binwidth=binwidth) +
  # stat_function(fun = function(x) dnorm(x, mean = mean, sd = sd) * n * binwidth,
  #               color = "darkred", size = 1) +
  geom_vline(xintercept = med, linetype='dashed', size=1) +
  geom_label(aes(x=med,y=1,label=paste0(round(med,1)," mm/yr")), fill = "white") +
  # geom_label(aes(x=350,y=17,label=paste0("mean = ", round(mean,0)," mm/yr\nst.dev = ",round(sd,0)," mm/yr")), fill = "white") +
  labs(tag="A)",x='Separated slowflow (mm/yr)',y='count') + # title = "Distribution of mean separated slow flow", 
  xlim(c(NA,500))

# ggsave("hist-slowflow.png", width = 12, height = 10, units = "cm")


med2 <- median(df$BFI, na.rm = T)
p2 <- ggplot(df) +
  geom_histogram(aes(x=BFI), colour = 1, fill = "white") +
  geom_vline(xintercept = med2, linetype='dashed', size=1) +
  geom_label(aes(x=med2,y=.5,label=paste0('median = ',round(med2,2))), fill = "white") +
  labs(tag="B)",x='BFI (-)', y=NULL) # title = "Distribution of the Baseflow Index (BFI = slowflow:total flow)",


grid.arrange(p1, p2, ncol=2)

g <- arrangeGrob(p1, p2, ncol=2)
ggsave("baseflow-histogram.png", g, width = 18, height = 10, units = "cm")

