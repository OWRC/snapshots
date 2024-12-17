

# load CVC functions
source('ORMGP Groundwater Chemistry.R')



dftem <- read.csv("dat/temporal.csv")
dfloc <- read.csv('dat/locations.csv')


# temporary correction, to be removed
dfloc$Well[dfloc$Well=='Cedarvale 3A'] = 'Cedarvale 3/3A'


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
# m <- "Scugog" #"Marmora and lake" # "Whitchurch-stouffville" #  "
# # View(dftem %>% filter(Muni==m))
# # RunCVCscript(dftem %>% filter(Muni==m),dfloc %>% filter(Muni==m))
# source('ORMGP Groundwater Chemistry.R')
# dfloc2 <- RunCVCscript(dftem %>% filter(Muni==m),dfloc %>% filter(Muni==m))
# print(dfloc2)
