

# load CVC functions
source('ORMGP Groundwater Chemistry.R')



temfp <- "dat/dta_ORMGP_SampleData_20240117.csv"
dfloc <- read.csv('dat/locations.csv')


# temporary correction, to be removed
dfloc$Name[dfloc$Name=='Cedarvale 3A'] = 'Cedarvale 3/3A'



# Update location table and print plots
dfloc <- RunCVCscript(temfp,dfloc)
print(dfloc)
write.csv(dfloc, 'dat/locations-stats.csv', row.names = FALSE)
