


library(ggplot2)
library(gridExtra)
library(leaflet)
library(leaflet.extras)
library(leaflet.minicharts)
library(leaflegend)
library(leafpop)
library(dplyr)

# YRe = replace(YRe, YRe>YRx, YRx)

df <- read.csv("baseflow/baseflow-piechart-gauge-summary.csv") %>%
  mutate(slowflow=meanQ*BFI,
         quickflow=meanQ*(1-BFI),
         normQ=meanQ/SW_DRAINAGE_AREA_KM2*86400*365.24/1000,
         normQ=replace(normQ, normQ>1000, 1000), ##################################################################################
         normSlow=normQ*BFI,
         lab=paste0("<h2>",paste0(LOC_NAME,': ',LOC_NAME_ALT1),"</h2>",
                    "Period of record: ",YRb,"-",YRe,
                    "<br>Missing data: ",round((1-QUAL)*100,1),"%",
                    "<br>Drainage area: ",round(SW_DRAINAGE_AREA_KM2,1)," km²",
                    "<br>Mean discharge: ",round(meanQ,2)," m³/s",
                    "<br>Baseflow index: ", round(BFI,3),
                    "<br>Streamflow recession coefficient (k): ", round(k,3),
                    "<hr>", html,
                    '<br><a href="https://owrc.shinyapps.io/sHyStreamflow/?sID=',LOC_ID,'" target="_blank" rel="noopener noreferrer">open hydrograph</a>'
         )
  ) %>%
  filter_all(all_vars(!is.infinite(.))) %>%
  filter(!(LOC_NAME %in% c('02EC004','02EC918'))) # exclusions, mainly severn canal

mean <- mean(df$normSlow)
sd <- sd(df$normSlow)
med <- median(df$normSlow)
n <- nrow(df)

