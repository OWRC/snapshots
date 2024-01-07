

library(ggplot2)
library(scales)
library(dplyr)


SPEC_CAP_M2S <- df.full %>% filter(!is.na(SPEC_CAP_LPMM)) %>% mutate(SPEC_CAP_M2S = SPEC_CAP_LPMM/1000/60 ) %>% pull(SPEC_CAP_M2S)
TSC_M2S <- df.full %>% filter(!is.na(TSC_M2S)) %>% pull(TSC_M2S)
TSC_SCR_M2S <- df.full %>% filter(!is.na(TSC_SCR_M2S)) %>% pull(TSC_SCR_M2S)



pct.breaks <- c(.5,1,2,5,10,20,30,40,50,60,70,80,90,95,98,99)/100
ddf <- function(list) {
  data.frame(y=list) %>% arrange(y) %>% mutate(x=row_number()/n())
}


dist.label <- function(dat) {
  gm <- exp(mean(log(dat)))
  sd <- exp(sd(log(dat),na.rm = TRUE))
  
  lgmm1 <- as.integer(log10(gm))-1
  gm <- gm/10^lgmm1
  
  c( paste0("mu[ln~SC]~`=`~", format(gm,digits=2), "%*%10^",lgmm1), #," ~ m^2/s"),
     paste0("sigma[ln~SC]~`=`~", round(sd,1)) )
}
x <- c(.8,.2,.7)
y <- c(.0002, .003, .002)
# y <- c( exp(mean(log(SPEC_CAP_M2S))),  exp(mean(log(TSC_M2S))),  exp(mean(log(TSC_SCR_M2S))))
lab <- c(dist.label(SPEC_CAP_M2S),dist.label(TSC_M2S),dist.label(TSC_SCR_M2S))
mu <- lab[seq(to=length(lab), by = 2)]
sigma <- lab[seq(2,length(lab), by = 2)]
df.dist.label <- data.frame(x,y,mu,sigma)


ggplot() + 
  theme_bw() +
  theme(legend.position = c(0.25, 0.85), 
        legend.title = element_blank(),
        legend.margin=margin(c(1,5,5,5)),
        legend.background = element_rect(colour='black', linewidth=0.1)) +
   
  geom_point(data = ddf(TSC_M2S),
             aes(x,y, colour=paste0("TSC_M2S (n=",format(length(TSC_M2S),big.mark=",",scientific=FALSE),")")),
             alpha=.1) +
  geom_point(data = ddf(TSC_SCR_M2S),
             aes(x,y, colour=paste0("TSC_SCR_M2S (n=",format(length(TSC_SCR_M2S),big.mark=",",scientific=FALSE),")")),
             alpha=.1) +
  geom_point(data = ddf(SPEC_CAP_M2S),
             aes(x,y, colour=paste0("SPEC_CAP_M2S (n=",format(length(SPEC_CAP_M2S),big.mark=",",scientific=FALSE),")")),
             alpha=.1) +
  
  geom_smooth(data = ddf(TSC_M2S), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +
  geom_smooth(data = ddf(TSC_SCR_M2S), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +
  geom_smooth(data = ddf(SPEC_CAP_M2S), aes(x,y), method="lm", colour='black', linetype='dotted',se = FALSE) +

  geom_text(data = df.dist.label, aes(x,y,label=mu), parse=T, hjust=0, size=3.5) +
  geom_text(data = df.dist.label, aes(x,y-.5*y,label=sigma), parse=T, hjust=0, size=3.5) +
    
  scale_y_log10(name="Specific capacity or transmissivity (m²/s)",
                breaks = trans_breaks("log10", function(x) 10^x),
                labels = trans_format("log10", math_format(10^.x)),
                limits = c(1e-7,1)) +
  scale_x_continuous(trans=probability_trans(distribution="norm"),
                     breaks=pct.breaks,
                     labels=signif(pct.breaks*100, digits=3),
                     name="Cumulative probability (%)",
                     limits = c(.4,99)/100,
                     expand = c(0,0)) +
  scale_color_discrete(name="estimate") +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))


ggsave("md/hydraulicProperties-ggplot-sc.png", height=6, width=6, units = "in", dpi="retina")
