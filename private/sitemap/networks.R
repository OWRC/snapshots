

# Load package
library(networkD3)
library(dplyr)



nds <- read.csv("nodes.csv") 
nds[10,'typ'] <- 1 # Hard coding for '/database-manual/Contents/TOC.html'


nds <- nds %>% mutate(size=(2-typ)*100+1, charge=-15)

nds$size <- as.numeric(nds$size)
nds$charge <- as.numeric(nds$charge)
lnks <- read.csv("links.csv")

# Plot
forceNetwork(Links = lnks, Nodes = nds,
             Source = "source", Target = "target",
             Value = "value", NodeID = "name",
             Group = "group", opacity = 1.,
             fontSize = 16, Nodesize = "size",
             charge = -15,
             zoom = TRUE, arrows = TRUE) #, legend = TRUE)

