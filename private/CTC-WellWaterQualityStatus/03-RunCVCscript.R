

# load CVC functions
source('ORMGP Groundwater Chemistry.R')



dftem <- read.csv("dat/temporal.csv")
dfloc <- read.csv('dat/locations.csv')


# hard-coded corrections
dfloc$Well[dfloc$Well=='Cedarvale 3A'] = 'Cedarvale 3/3A'
dfloc$Well[dfloc$Well=='Georgetown PW 1A (Cedarvale)'] = 'Georgetown PW 1/1A (Cedarvale)'
dfloc$Well[dfloc$Well=='Georgetown PW 3A (Cedarvale)'] = 'Georgetown PW 3/3A (Cedarvale)'
dfloc$Upp_Muni[dfloc$LOC_ID==49457] = 'Dufferin'
dfloc$Upp_Muni[dfloc$LOC_ID==43001] = 'Dufferin'


# update by municipality
munis <- unique(dftem$Muni)
df.col <- vector(mode = "list", length = length(munis))
for (i in 1:length(munis)) {
  m <- munis[[i]]
  print(m)
  df.col[[i]] <- RunCVCscript(dftem %>% filter(Muni==m),dfloc %>% filter(Muni==m))
}
df.all <- bind_rows(df.col, .id = "column_label")
write.csv(df.all, 'dat/locations-stats.csv', row.names = FALSE)


# # Update location table and print plots (all at once)
# dfloc <- RunCVCscript(dftem,dfloc)
# print(dfloc)
# write.csv(dfloc, 'dat/locations-stats.csv', row.names = FALSE)



# # for testing
# m <- "Vaughan" # "Caledon" # "Scugog" #"Marmora and lake" # "Whitchurch-stouffville" #  "
# # View(dftem %>% filter(Muni==m))
# # RunCVCscript(dftem %>% filter(Muni==m),dfloc %>% filter(Muni==m))
# source('ORMGP Groundwater Chemistry.R')
# dfloc2 <- RunCVCscript(dftem %>% filter(Muni==m),dfloc %>% filter(Muni==m))
# print(dfloc2)


# dftem <- dftem %>% filter(Muni==m)
# dfloc <- dfloc %>% filter(Muni==m)
