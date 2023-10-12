

library(dplyr)
library(lubridate)
library(mgcv)
library(ggplot2)





# # #6ca647, #fea62a, #39393a, #29abe2, #437c52
# 
# fn <- "875144935.csv" # -1021429775.csv" # "890869235.csv" # 
# mult <- 1.96 # 2.576 # 5 # 1.96
# # default.theme <- theme(legend.background = element_rect(fill = "#a6cee3"),
# #                  legend.key = element_rect(fill = "#a6cee3", color = NA),
# #                  plot.background = element_rect(fill = "#a6cee3"),
# #                  panel.border = element_rect(colour = "#16557F", fill=NA),
# #                  panel.background = element_rect(fill = "#a6cee3",
# #                                                  colour = "#a6cee3",
# #                                                  size = 0.5, 
# #                                                  linetype = "solid"),
# #                  panel.grid.major = element_line(size = 0.35, 
# #                                                  linetype = 'solid',
# #                                                  colour = "#29ABE2"), 
# #                  panel.grid.minor = element_line(size = 0.25, 
# #                                                  linetype = 'solid',
# #                                                  colour = "#29ABE2"),
# #                  plot.title = element_text(colour='#16557F'),
# #                  axis.title = element_text(colour='#16557F'),
# #                  axis.text = element_text(colour='#16557F'),
# #                  axis.ticks = element_line(colour = "#16557F")
# #                  )
# 
# 
# df <- read.csv(paste0("./gwvar/pkl/", fn)) %>%
#   mutate(date=as.Date(Date)) %>%
#   mutate(doy=yday(date), 
#          year=year(date), 
#          dcnt=as.numeric(date-min(date))
#          )





# #########################################################
# # GAMM
# # grouping by year to speed up corAR1
# cdf <- gamm(data=df, Val~s(doy,bs="cc",k=12)+s(year,bs="cr",k=length(unique(df$year))), correlation=corAR1(form=~1|year))
# 
# # summary(cdf$gam)
# # intervals(cdf$lme,which = "var-cov")
# # cdf$gam$sig2/cdf$gam$sp
# 
# # # layout(matrix(1:2, nrow = 1))
# # plot(cdf$gam)
# # plot(cdf$gam, scale=0, shade = TRUE)
# # gam.check(cdf$gam)


df %>% ggplot(aes(date,Val)) +
  theme_bw() + # default.theme +
  # theme(legend.position = c(.7,.2)) +
  theme(legend.position = c(1,0), 
        legend.justification = c(1,0), 
        legend.background = element_blank()) +
  geom_line(aes(colour='observed'), linewidth=1.5, alpha=.85) +
  geom_line(aes(colour='model'), data=data.frame(Val = as.vector(cdf$gam$fitted.values), date = df$date), linewidth=1.5) +
  labs(title=paste0("model fit n=",nrow(df)),x=NULL, y="water level (masl)") +
  scale_colour_manual(name=NULL, values=colSimObs, labels=c('modelled', 'observed')) # c('#fb9a99','#1f78b4')

# ggsave('./gwvar/img/obssim.png',height=6,width=13,units = 'cm')































# #########################################################
# 
# preds <- predict(cdf$gam, type="terms", se.fit=TRUE)
# 
# #########################################################
# # annual trend
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
#   geom_ribbon(aes(ymin=low95, ymax=up95), fill='#1f78b4', alpha=.25) +
#   # geom_line(aes(y=low95), color='#1f78b4', linewidth=1, linetype='dashed') +
#   # geom_line(aes(y=up95), color='#1f78b4', linewidth=1, linetype='dashed') +
#   geom_line(aes(y=fit), color='#1f78b4', linewidth=.5) +
#   labs(title='long-term trend', y=paste0("s(year,", round(sum(cdf$gam$edf[-(1:11)]),2), ")"))
# 
# # ggsave('./gwvar/img/f-year.png',height=6,width=6,units = 'cm')
# 
# 
# 
# #########################################################
# # seasonal trend
# 
# seas.fit <- as.vector(preds$fit[,1])
# seas.fit.up95 <- as.vector(seas.fit-mult*preds$se.fit[,1])
# seas.fit.low95 <- as.vector(seas.fit+mult*preds$se.fit[,1])
# seas.fit.df <- data.frame(seq(to=length(seas.fit)),seas.fit,seas.fit.low95,seas.fit.up95)
# names(seas.fit.df) <- c('mmid',"fit","low95","up95")
# t0 <- as.numeric(rownames(df[which(df$doy==1, arr.ind=TRUE)[1],])[1])
# 
# ggplot(  slice(seas.fit.df, (t0:(t0+366))) , aes(as.Date(mmid-t0, origin = as.Date("2018-01-01"))) ) +
#   theme_bw() + default.theme +
#   # geom_line(data=df, aes(doy,detrend,group=year,colour=year), alpha=.5) +
#   geom_ribbon(aes(ymin=low95, ymax=up95), fill='#1f78b4', alpha=.25) +
#   # geom_line(aes(y=low95), color='#1f78b4', linewidth=.25, alpha=.5) +
#   # geom_line(aes(y=up95), color='#1f78b4', linewidth=.25, alpha=.5) +
#   geom_line(aes(y=fit), color='#1f78b4', linewidth=.5) +
#   scale_x_date(date_labels = "%b") +
#   labs(title='seasonal trend', x=NULL, y=paste0("s(day of year,", round(sum(cdf$gam$edf[2:11]),2), ")"))
# 
# 
# # ggsave('./gwvar/img/f-doy.png',height=6,width=6,units = 'cm')
# 
# 
# 
# 
# #########################################################
# # anomalies
# df$detrend <- df$Val-as.vector(cdf$gam$fitted.values)+as.vector(seas.fit)
# df$trnd.up95 <- seas.fit.df$fit + as.vector(mult*preds$se.fit[,2])
# df$trnd.low95 <- seas.fit.df$fit - as.vector(mult*preds$se.fit[,2])
# df <- df %>% group_by(doy) %>% mutate(trnd.up95=mean(trnd.up95), trnd.low95=mean(trnd.low95)) %>% ungroup()
# 
# mn <- min(df$trnd.low95)
# mx <- max(df$trnd.up95)
# 
# ggplot(  slice(seas.fit.df, (t0:(t0+366))) , aes(as.Date(mmid-t0, origin = as.Date("2018-01-01"))) ) +
#   theme_bw() + default.theme +
#   # geom_ribbon(aes(ymin=low95, ymax=up95)) +
#   geom_point(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), detrend), colour='#FEA62A', size=.1, alpha=.35) + # 
#   geom_ribbon(data=df, aes(as.Date(doy, origin = as.Date("2018-01-01")), ymin=trnd.low95, ymax=trnd.up95), fill='#1f78b4', alpha=.25) +
#   geom_line(aes(y=fit), color='#1f78b4') +
#   # geom_line(aes(y=low95), color='#1f78b4', linewidth=.25, alpha=.5) +
#   # geom_line(aes(y=up95), color='#1f78b4', linewidth=.25, alpha=.5) +
#   geom_hline(yintercept = mn, colour='#16557F', linetype='dotted') +
#   geom_hline(yintercept = mx, colour='#16557F', linetype="dotted") +
#   geom_segment(aes(x = as.Date("2018-01-01"), y = mn, xend = as.Date("2018-01-01"), yend = mx), colour='#16557F') +
#   # geom_vline(xintercept = as.Date("2018-02-01"), ymin=mn, ymax=mx) +
#   annotate("text", as.Date("2018-01-25"), mx-.1*(mx-mn), label = paste0(round(mx-mn,1)," m"), colour='#16557F') +
#   scale_x_date(date_labels = "%b") +
#   labs(title='enveloping a groundwater "variability"', x=NULL,y="water level anomaly (m)")
#   
# 
# 
# # ggsave('./gwvar/img/gwvar.png',height=6,width=13,units = 'cm')
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # ###################################################################
# # ###################################################################
# # ###################################################################
# # # EXTRAS
# # 
# # 
# # 
# # 
# # 
# # all.fit <- preds.all$fit
# # 
# # # all.fit.df <- data.frame(seq(from=-t0+1, to=length(all.fit)-t0),all.fit,all.fit.low95,all.fit.up95)
# # 
# # 
# # 
# # 
# # ggplot(  slice(all.fit.df, (t0:(t0+366))) , aes(mmid) ) +
# #   theme_bw() +
# #   # geom_ribbon(aes(ymin=low95, ymax=up95)) +
# #   # geom_line(data=df, aes(doy,detrend,group=year,colour=year), alpha=.5) +
# #   geom_line(aes(y=fit)) +
# #   geom_line(aes(y=low95)) +
# #   geom_line(aes(y=up95))
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # # de-trend long term signal
# # ctrend <- gamm(data=df, Val~s(year,bs="cr"), correlation=corAR1(form=~1|year))
# # plot(ctrend$gam)
# # 
# # df$detrend <- df$Val-as.vector(ctrend$gam$fitted.values)
# # df %>% ggplot(aes(date,Val)) +
# #   theme_bw() +
# #   geom_line(aes(colour='observed')) +
# #   geom_line(data=data.frame(Val = ctrend$gam$fitted.values, date = df$date), aes(colour='modelled')) +
# #   labs(x=NULL, y="water level (masl)") +
# #   scale_colour_manual(name=NULL, values=c('#1f78b4','#fb9a99'), labels=c('observed','modelled'))
# # 
# # 
# # 
# # cseasonal <- gamm(data=df, detrend~s(doy,bs="cc",k=12), correlation=corAR1(form=~1|year))
# # plot(cseasonal$gam)
# # 
# # df$seasonfit <- as.vector(cseasonal$gam$fitted.values)
# # # cseasonal$gam$linear.predictors
# # 
# # 
# # df %>% 
# #   # mutate(mnyr=as.Date(paste0("2004-,",month(date),"-",day(date)), format="%Y-%m-%d")) %>%
# #   ggplot(aes(as.Date(doy, origin = as.Date("2018-01-01")))) +
# #     theme_bw() +
# #     geom_point(aes(y=detrend), alpha=.35) +
# #     geom_line(aes(y=seasonfit), colour='red', linewidth=1.5) +
# #     # stat_smooth(aes(y=detrend)) +
# #     scale_x_date(date_labels = "%b") +
# #     labs(x=NULL, y="annual water table variability (m)")
# #   
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # # ############################
# # # # test
# # # library(mgcViz) # https://cran.r-project.org/web/packages/mgcViz/vignettes/mgcviz.html
# # # b <- getViz(cdf$gam)
# # # o <- plot( sm(b, 1) )
# # # o + 
# # #   theme_bw() +
# # #   l_fitLine(colour = "red", linewidth=2) + 
# # #   # l_rug(mapping = aes(x=x, y=y), alpha = 0.8) +
# # #   l_ciLine(mul = 5, colour = "blue", linewidth=2, linetype = 2) + 
# # #   l_points(shape = 19, size = 1, alpha = 0.15)
# #   
# # 
# # 
# # 
# # 
# # 
# # # http://zevross.com/blog/2014/09/15/recreate-the-gam-partial-regression-smooth-plots-from-r-package-mgcv-with-a-little-style/
# # 
# # 
# # 
# # val.max <- max(df$detrend)
# # val.min <- min(df$detrend)
# # val.seq <- seq(val.min, val.max, length=366)
# # val.df <- data.frame(Val=seq(val.min, val.max, length=366))
# # 
# # # predict only the temperature term (the sum of the
# # # term predictions and the intercept gives you the overall 
# # # prediction)
# # 
# # preds.sea <- predict(cseasonal$gam, type="terms", se.fit=TRUE)
# # preds.trnd <- predict(ctrend$gam, type="terms", se.fit=TRUE)
# # # set up the temperature, the fit and the upper and lower
# # # confidence interval
# # 
# # fit.sea <- preds.sea$fit
# # max(preds.sea$fit)-min(preds.sea$fit)
# # fit.sea.up95 <- fit.sea-mult*preds.sea$se.fit
# # fit.sea.low95 <- fit.sea+mult*preds.sea$se.fit
# # fit.trnd.up95 <- fit.sea-mult*preds.trnd$se.fit
# # fit.trnd.low95 <- fit.sea+mult*preds.trnd$se.fit
# # fit.df <- data.frame(seq(from=-t0+1, to=length(fit.sea)-t0),fit.sea,fit.sea.low95,fit.sea.up95,fit.trnd.low95,fit.trnd.up95)
# # names(fit.df) <- c('mmid',"fit","low95","up95","trnd.low95","trnd.up95")
# # 
# # 
# # ggplot(  slice(fit.df, (t0:(t0+366))) , aes(mmid) ) +
# #   theme_bw() +
# #   # geom_ribbon(aes(ymin=low95, ymax=up95)) +
# #   geom_line(data=df, aes(doy,detrend,group=year,colour=year), alpha=.5) +
# #   geom_line(aes(y=fit)) +
# #   geom_line(aes(y=low95)) +
# #   geom_line(aes(y=up95)) +
# #   geom_line(aes(y=trnd.low95)) +
# #   geom_line(aes(y=trnd.up95))
# # 
# # # anomalies
# # 
# # 
# # 
# # 
# # 
# # #####################################
# # # https://stackoverflow.com/questions/49471300/gam-plots-with-ggplot
