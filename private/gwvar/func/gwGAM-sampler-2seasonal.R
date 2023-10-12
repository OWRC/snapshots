

#########################################################
# seasonal trend

df %>% 
  group_by(doy) %>%
  summarize(seas.fit=unique(seas.fit), seas.fit.up95=unique(seas.fit.up95), seas.fit.low95=unique(seas.fit.low95)) %>%
  ggplot(aes(as.Date(doy, origin = as.Date("2018-01-01")))) +
    theme_bw() + # default.theme +
    geom_ribbon(aes(ymin=seas.fit.low95, ymax=seas.fit.up95), fill=colSimObs[1], alpha=.2) +
    geom_line(aes(y=seas.fit), color=colSimObs[1], linewidth=1.5) +
    scale_x_date(date_labels = "%b") +
    labs(title='seasonal cycle', x=NULL, y=paste0("s(day.of.year,", round(sum(cdf$gam$edf[2:11]),2), ") (m)"))


# seas.fit <- as.vector(preds$fit[,1])
# seas.fit.up95 <- as.vector(seas.fit-mult*preds$se.fit[,1])
# seas.fit.low95 <- as.vector(seas.fit+mult*preds$se.fit[,1])
# seas.fit.df <- data.frame(seq(to=length(seas.fit)),seas.fit,seas.fit.low95,seas.fit.up95)
# names(seas.fit.df) <- c('doy',"fit","low95","up95")
# t0 <- as.numeric(rownames(df[which(df$doy==1, arr.ind=TRUE)[1],])[1])
# 
# ggplot(  slice(seas.fit.df, (t0:(t0+366))) , aes(as.Date(mmid-t0, origin = as.Date("2018-01-01"))) ) +
#   theme_bw() + # default.theme +
#   # geom_line(data=df, aes(doy,detrend,group=year,colour=year), alpha=.5) +
#   geom_ribbon(aes(ymin=low95, ymax=up95), fill=colSimObs[1], alpha=.2) +
#   # geom_line(aes(y=low95), color='#1f78b4', linewidth=.25, alpha=.5) +
#   # geom_line(aes(y=up95), color='#1f78b4', linewidth=.25, alpha=.5) +
#   geom_line(aes(y=fit), color=colSimObs[1], linewidth=1.5) +
#   scale_x_date(date_labels = "%b") +
#   labs(title='seasonal cycle', x=NULL, y=paste0("s(day of year,", round(sum(cdf$gam$edf[2:11]),2), ")"))


# ggsave('./gwvar/img/f-doy.png',height=6,width=6,units = 'cm')


