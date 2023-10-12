

library(dplyr)
library(lubridate)
library(mgcv)
library(ggplot2)

# builds separate PDFs by interval

source("gwvar/func/gwGAM-sampler-ALL.R", local = TRUE)$value


df.loc <- read.csv("gwvar/gwvar-summary.py.csv") %>%
  filter(!is.na(nValues)) %>%
  # mutate(mktitle = MannKendall10yrPstat<0.05) %>%
  mutate(MannKendall10yrText = case_when(MannKendall10yrPstat <= 0.05 & MannKendall10yrTau<0 ~ "MK decreasing trend",
                        MannKendall10yrPstat <= 0.05 & MannKendall10yrTau>0 ~ "MK increasing trend",
                        MannKendall10yrPstat > 0.05  ~ "MK no trend"))

lnames <- df.loc %>% pull(LOC_NAME, INT_ID)
snames <- df.loc %>% pull(SCREEN_NAME, INT_ID)
depths <- df.loc %>% pull(SCREEN_TOP_DEPTH_M, INT_ID)
frmatn <- df.loc %>% pull(FORMATION, INT_ID)
mk.10yr <- df.loc %>% pull(MannKendall10yrText, INT_ID)


nams <- list()
rngs <- list()
for (fn in list.files("./gwvar/pkl", ".csv")) {
  nm <- substr(fn, 1, nchar(fn)-4)
  print(nm)
  
  df <- read.csv(paste0("./gwvar/pkl/", fn)) %>%
    mutate(date=as.Date(Date)) %>%
    mutate(doy=yday(date), 
           year=year(date), 
           dcnt=as.numeric(date-min(date))
    )
  if (nrow(df)<365) next
  
  # GAMM
  # grouping by year to speed up corAR1
  cdf <- gamm(data=df, Val~s(doy,bs="cc",k=12)+s(year,bs="cr",k=length(unique(df$year))), correlation=corAR1(form=~1|year))
  preds <- predict(cdf$gam, type="terms", se.fit=TRUE)
  
  gr <- GAMrange.coll(df, preds)
  nams <- c(nams, nm)
  rngs <- c(rngs, gr)
  
  mkl <- MK(fn)
  if ( is.null(mkl) ) mkl = mk.10yr[nm]
    
  g <- GAM.grid(df, cdf, preds, 
                paste0(snames[nm], " | screen depth=", round(depths[nm],1), " m | ", mkl, "\n", frmatn[nm]))
  ggsave(paste0("gwvar/pkl/",nm,".pdf"), g, height = 8.5, width=11) # need to specify what to save explicitly
}
names(rngs) <- nams
df.loc2 <- merge(df.loc, do.call(rbind, rngs), by.x = "INT_ID", by.y=0) %>% rename(GAMrange=V1)
df.loc2 %>% ggplot(aes(pyRange,GAMrange)) + geom_point() + geom_abline(slope=1,intercept = 0)
write.csv(df.loc2 %>% subset(select = -c(pyRange)),"gwvar/gwGAM-summary.R.csv", row.names=FALSE)

