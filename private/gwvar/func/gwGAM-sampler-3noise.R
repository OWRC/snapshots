


#########################################################
# anomalies
df2 <- df %>% 
  group_by(doy) %>%
  summarize(seas.fit=unique(seas.fit), detrnd.up95=mean(detrnd.up95), detrnd.low95=mean(detrnd.low95))

mn <- min(df2$detrnd.low95)
mx <- max(df2$detrnd.up95)

df2 %>%
  ggplot(aes(as.Date(doy, origin = as.Date("2018-01-01")))) +
    theme_bw() + # default.theme +
    geom_hline(yintercept = mn, linetype='dotted', linewidth=1) +
    geom_hline(yintercept = mx, linetype="dotted", linewidth=1) +
    geom_point(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), detrend), colour=colSimObs[2], size=1, alpha=.15) +
    geom_ribbon(aes(ymin=detrnd.low95, ymax=detrnd.up95), fill=colSimObs[1], alpha=.2) +
    geom_line(aes(y=seas.fit), color=colSimObs[1], linewidth=1.5) +
    geom_line(aes(y=detrnd.low95), color=colSimObs[1], linewidth=.25, alpha=.5) +
    geom_line(aes(y=detrnd.up95), color=colSimObs[1], linewidth=.25, alpha=.5) +

    # geom_segment(aes(x = as.Date("2018-02-01"), y = mn, xend = as.Date("2018-02-01"), yend = mx)) +
    # # geom_vline(xintercept = as.Date("2018-02-01"), ymin=mn, ymax=mx) +
    # annotate("text", as.Date("2018-03-15"), mx-.1*(mx-mn), label = paste0(round(mx-mn,1)," m")) +
    scale_x_date(date_labels = "%b") +
    labs(title=paste0('water level range= \u00B1',round((mx-mn)/2,2),' m'), x=NULL,y="water level anomaly (m)")


# df$detrend <- df$Val-as.vector(cdf$gam$fitted.values)+as.vector(seas.fit)
# df$trnd.up95 <- seas.fit.df$fit + as.vector(mult*preds$se.fit[,2])
# df$trnd.low95 <- seas.fit.df$fit - as.vector(mult*preds$se.fit[,2])
# df <- df %>% group_by(doy) %>% mutate(trnd.up95=mean(trnd.up95), trnd.low95=mean(trnd.low95)) %>% ungroup()
# 
# mn <- min(df$trnd.low95)
# mx <- max(df$trnd.up95)
# 
# ggplot(  slice(seas.fit.df, (t0:(t0+366))) , aes(as.Date(mmid-t0, origin = as.Date("2018-01-01"))) ) +
#   theme_bw() + # default.theme +
#   
#   geom_hline(yintercept = mn, linetype='dotted', linewidth=1) +
#   geom_hline(yintercept = mx, linetype="dotted", linewidth=1) +
#   
#   # geom_ribbon(aes(ymin=low95, ymax=up95)) +
#   geom_point(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), detrend), colour=colSimObs[2], size=1, alpha=.15) + # 
#   geom_ribbon(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), ymin=trnd.low95, ymax=trnd.up95), fill=colSimObs[1], alpha=.2) +
#   geom_line(aes(y=fit), color=colSimObs[1], linewidth=1.5) +
#   geom_line(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), y=trnd.low95), color=colSimObs[1], linewidth=.25, alpha=.5) +
#   geom_line(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), y=trnd.up95), color=colSimObs[1], linewidth=.25, alpha=.5) +
# 
#   # geom_segment(aes(x = as.Date("2018-02-01"), y = mn, xend = as.Date("2018-02-01"), yend = mx)) +
#   # # geom_vline(xintercept = as.Date("2018-02-01"), ymin=mn, ymax=mx) +
#   # annotate("text", as.Date("2018-03-15"), mx-.1*(mx-mn), label = paste0(round(mx-mn,1)," m")) +
#   scale_x_date(date_labels = "%b") +
#   labs(title=paste0('water level range=',round(mx-mn,1),' m'), x=NULL,y="water level anomaly (m)")
  


# ggsave('./gwvar/img/gwvar.png',height=6,width=13,units = 'cm')


