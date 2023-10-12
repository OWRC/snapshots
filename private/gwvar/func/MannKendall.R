
library(Kendall)

MK <- function(fn) {
  
  v <- read.csv(paste0("./gwvar/pkl/", fn)) %>%
    mutate(date=as.Date(Date)) %>%
    mutate(doy=yday(date), 
           year=year(date), 
           dcnt=as.numeric(date-min(date))
    ) %>%
    arrange(date) %>%
    pull(Val)
  
  m <- MannKendall(v)
  
  if (m$sl>0.05) {
    "MK no trend"
  } else {
    if (m$tau<0) {
      "MK decreasing trend"
    } else {
      "MK increasing trend"
    }
  }
  
}
