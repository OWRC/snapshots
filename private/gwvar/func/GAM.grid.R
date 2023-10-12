


GAM.grid <- function(df, cdf, preds, title="") {
  
  # summary(cdf$gam)
  # intervals(cdf$lme,which = "var-cov")
  # cdf$gam$sig2/cdf$gam$sp
  
  # # layout(matrix(1:2, nrow = 1))
  # plot(cdf$gam, scale=0, shade = TRUE)
  # gam.check(cdf$gam)
  
  p0 <- source("func/gwGAM-sampler-0model.R", local = TRUE)$value  

  df$trnd.fit <- as.vector(preds$fit[,2])
  df$trnd.fit.up95 <- as.vector(df$trnd.fit-mult*preds$se.fit[,2])
  df$trnd.fit.low95 <- as.vector(df$trnd.fit+mult*preds$se.fit[,2])

  p1 <- source("func/gwGAM-sampler-1longterm.R", local = TRUE)$value
  
  df$seas.fit <- as.vector(preds$fit[,1])
  df$seas.fit.up95 <- as.vector(df$seas.fit-mult*preds$se.fit[,1])
  df$seas.fit.low95 <- as.vector(df$seas.fit+mult*preds$se.fit[,1])
  
  p2 <- source("func/gwGAM-sampler-2seasonal.R", local = TRUE)$value
  
  df$detrend <- df$Val-as.vector(cdf$gam$fitted.values)+as.vector(df$seas.fit)
  df$detrnd.up95 <- df$seas.fit + as.vector(mult*preds$se.fit[,1]) + as.vector(mult*preds$se.fit[,2])
  df$detrnd.low95 <- df$seas.fit - as.vector(mult*preds$se.fit[,1]) - as.vector(mult*preds$se.fit[,2])
  
  p3 <- source("func/gwGAM-sampler-3noise.R", local = TRUE)$value
  
  grid.arrange(p0, p3, p1, p2, nrow = 2, top = title)
    
}
