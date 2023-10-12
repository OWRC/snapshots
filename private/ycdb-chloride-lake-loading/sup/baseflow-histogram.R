



df.bf <- read.csv("E:/OneDrive - Central Lake Ontario Conservation/inout/YPDTH-ORMGP/220215 Groundwater Geoscience Open House/dat/gauge-summary.csv") %>%
  mutate(slowflow=meanQ*BFI,
         quickflow=meanQ*(1-BFI),
         normQ=meanQ/DA*86400*365.24/1000,
         normSlow=normQ*BFI
  )

fit.bf <- fitdistr(df.bf$normSlow, "lognormal")
# fit.bf

# ggplot(df.bf) + geom_histogram(aes(normSlow))



pp <- df.bf %>% ggplot() + theme_linedraw()



p1 <- pp + geom_histogram(aes(normSlow, after_stat(density)), fill="#0153a4", color="#e9ecef", alpha=0.9) +
  stat_function(fun = dlnorm, 
                args = list(mean = fit.bf$estimate[[1]], sd = fit.bf$estimate[[2]]),
                col="darkred",
                linewidth = I(1.2),
                linetype = 1) +
  geom_vline(xintercept = median(df.bf$normSlow), linetype='dashed', size=1) +
  # xlim(c(NA,400)) +
  labs(x='Annual "indirect" discharge (mm/yr)')



p2 <- pp + geom_histogram(aes(BFI), fill="#0153a4", color="#e9ecef", alpha=0.9) +
  geom_vline(xintercept = median(df.bf$BFI), linetype='dashed', size=1) +
  labs(x='BFI (-)', y=NULL)


grid.arrange(p1, p2, ncol=2)
