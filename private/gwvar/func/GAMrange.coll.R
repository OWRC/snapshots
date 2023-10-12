
GAMrange.coll <- function(df, preds) {
  
  df$seas.fit <- as.vector(preds$fit[,1])
  df$detrnd.up95 <- df$seas.fit + as.vector(mult*preds$se.fit[,1]) + as.vector(mult*preds$se.fit[,2])
  df$detrnd.low95 <- df$seas.fit - as.vector(mult*preds$se.fit[,1]) - as.vector(mult*preds$se.fit[,2])  
  
  df2 <- df %>% 
    group_by(doy) %>%
    summarize(seas.fit=unique(seas.fit), detrnd.up95=mean(detrnd.up95), detrnd.low95=mean(detrnd.low95))
  
  mn <- min(df2$detrnd.low95)
  mx <- max(df2$detrnd.up95)
  
  return( (mx-mn)/2 )
}
