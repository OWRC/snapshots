


#########################################################

# preds <- predict(cdf$gam, type="terms", se.fit=TRUE)

#########################################################
# annual trend
ggplot(df, aes(year)) +
  theme_bw() + # default.theme +
  geom_ribbon(aes(ymin=trnd.fit.low95, ymax=trnd.fit.up95), fill=colSimObs[1], alpha=.2) +
  geom_line(aes(y=trnd.fit), color=colSimObs[1], linewidth=1.5) +
  labs(title='long-term trend', x=NULL, y=paste0("s(year,", round(sum(cdf$gam$edf[-(1:11)]),2), ") (m)"))

# trnd.fit <- as.vector(preds$fit[,2])
# trnd.fit.up95 <- as.vector(trnd.fit-mult*preds$se.fit[,2])
# trnd.fit.low95 <- as.vector(trnd.fit+mult*preds$se.fit[,2])
# # trnd.fit.df <- data.frame(seq(to=length(trnd.fit)),trnd.fit,trnd.fit.low95,trnd.fit.up95)
# trnd.fit.df <- data.frame(df$date,df$year,trnd.fit,trnd.fit.low95,trnd.fit.up95)
# names(trnd.fit.df) <- c('date','year',"fit","low95","up95")
# 
# # ggplot(trnd.fit.df %>% group_by(year) %>% summarise(fit=mean(fit), low95=mean(low95), up95=mean(up95)), aes(year) ) +
# ggplot(trnd.fit.df, aes(year) ) +
#   theme_bw() + # default.theme +
#   # geom_line(data=df, aes(doy,detrend,group=year,colour=year), alpha=.5) +
#   geom_ribbon(aes(ymin=low95, ymax=up95), fill=colSimObs[1], alpha=.2) +
#   # geom_line(aes(y=low95), color='#1f78b4', linewidth=1, linetype='dashed') +
#   # geom_line(aes(y=up95), color='#1f78b4', linewidth=1, linetype='dashed') +
#   geom_line(aes(y=fit), color=colSimObs[1], linewidth=1.5) +
#   labs(title='long-term trend', y=paste0("s(year,", round(sum(cdf$gam$edf[-(1:11)]),2), ")"))

# ggsave('./gwvar/img/f-year.png',height=6,width=6,units = 'cm')

