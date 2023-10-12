

library(ggplot2)
library(scales)
library(dplyr)
library(formatdown)


K_MS_AQF <- df.full %>% filter(!is.na(K_MS)) %>% filter(GEOL_UNIT_CODE %in% aquifer.GEOL_UNIT_CODE) %>% pull(K_MS)
K_MS_AQT <- df.full %>% filter(!is.na(K_MS)) %>% filter(!(GEOL_UNIT_CODE %in% aquifer.GEOL_UNIT_CODE)) %>% pull(K_MS)
KSC_MS <- df.full %>% filter(!is.na(KSC_MS)) %>% pull(KSC_MS)
KSC_SCR_MS <- df.full %>% filter(!is.na(KSC_SCR_MS)) %>% pull(KSC_SCR_MS)

# sd.K_MS_AQF <- exp(sd(log(K_MS_AQF)))
# sd.K_MS_AQT <- exp(sd(log(K_MS_AQT)))
# sd.KSC_MS <- exp(sd(log(KSC_MS)))
# sd.KSC_SCR_MS <- exp(sd(log(KSC_SCR_MS)))

# gm.K_MS_AQF <- exp(mean(log(K_MS_AQF)))
# gm.K_MS_AQT <- exp(mean(log(K_MS_AQT)))
# gm.KSC_MS <- exp(mean(log(KSC_MS)))
# gm.KSC_SCR_MS <- exp(mean(log(KSC_SCR_MS)))




dist.label <- function(dat) {
  gm <- exp(mean(log(dat)))
  sd <- exp(sd(log(dat),na.rm = TRUE))
  
  lgmm1 <- as.integer(log10(gm))-1
  gm <- gm/10^lgmm1
  
  c( paste0("mu[ln~K]~`=`~", format(gm,digits=2), "%*%10^",lgmm1," ~ m/s"),
     paste0("sigma[ln~K]~`=`~", round(sd,1)) )
}
x <- c(.3,.55,.05,.7)
y <- c(1e-06, 1.3e-07, .00005, .01)
lab <- c(dist.label(K_MS_AQF),dist.label(K_MS_AQT),dist.label(KSC_MS),dist.label(KSC_SCR_MS))
mu <- lab[seq(to=length(lab), by = 2)]
sigma <- lab[seq(2,length(lab), by = 2)]
df.dist.label <- data.frame(x,y,mu,sigma)






pct.breaks <- c(.5,1,2,5,10,20,30,40,50,60,70,80,90,95,98,99)/100
ddf <- function(list) {
  data.frame(y=list) %>% arrange(y) %>% mutate(x=row_number()/n())
}



ggplot() + 
  theme_bw() +
  theme(legend.position = c(0.25, 0.85), 
        legend.title = element_blank(),
        legend.margin=margin(c(1,5,5,5)),
        legend.background = element_rect(colour='black', linewidth=0.1)) +
  
  ## slow, comment-out when debugging
  geom_point(data = ddf(KSC_SCR_MS),
             aes(x,y, colour=paste0("KSC_SCR_MS (n=",format(length(KSC_SCR_MS),big.mark=",",scientific=FALSE),")")),
             alpha=.1) +
  geom_point(data = ddf(KSC_MS),
             aes(x,y, colour=paste0("KSC_MS (n=",format(length(KSC_MS),big.mark=",",scientific=FALSE),")")),
             alpha=.1) +
  geom_point(data = ddf(K_MS_AQT),
             aes(x,y, colour=paste0("K_MS (aquitard, n=",format(length(K_MS_AQT),big.mark=",",scientific=FALSE),")"))) +
  geom_point(data = ddf(K_MS_AQF),
             aes(x,y, colour=paste0("K_MS (aquifer, n=",format(length(K_MS_AQF),big.mark=",",scientific=FALSE),")"))) +

  
  geom_smooth(data = ddf(KSC_SCR_MS), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +
  geom_smooth(data = ddf(KSC_MS), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +
  geom_smooth(data = ddf(K_MS_AQT), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +
  geom_smooth(data = ddf(K_MS_AQF), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +
  
  # annotate('text',x=.5,y=gm.KSC_SCR_MS, label=dist.label(KSC_SCR_MS), hjust = 0) +
  # geom_point(data = df.dist.label, aes(x,y,label=lab)) +

  geom_text(data = df.dist.label, aes(x,y,label=mu), parse=T, hjust=0, size=3.5) +
  geom_text(data = df.dist.label, aes(x,y-.6*y,label=sigma), parse=T, hjust=0, size=3.5) +
  
  scale_y_log10(name="Hydraulic conductivity (m/s)",
                breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x))) +
  scale_x_continuous(trans=probability_trans(distribution="norm"),
                     breaks=pct.breaks,
                     labels=signif(pct.breaks*100, digits=3),
                     name="Cumulative probability (%)",
                     limits = c(.4,99)/100,
                     expand = c(0,0)) +
  # scale_color_discrete(name="estimate") +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))


ggsave("E:/Sync/@dev/pages_owrc/snapshots/md/hydraulicProperties-ggplot-k.png", height=6, width=6, units = "in")

