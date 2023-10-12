

frm.build <- function() {
    
  smpl <- list(dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[1],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[2],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[3],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[4],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[5],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[6],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[7],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[8],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[9],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[10],]$VALUE,
               dfg[dfg$SCREEN_GEOL_UNIT==layers_ordered[11],]$VALUE
               )

  ll <- length(smpl)

  is <- rep(0, ll*ll)
  js <- rep(0, ll*ll)
  vs <- rep(0, ll*ll)
  ss <- rep("", ll*ll)
  c <- 0
  for (i in 1:ll) {
    for (j in 1:ll) {
      c = c+1
      # if (j==i) break
      is[c] = i
      js[c] = j
      
      if (j>=i) {
        vs[c] = NA
        ss[c] = ""
      } else {
        ks <- ks.test(smpl[[i]], smpl[[j]])
        vs[c] = ks$statistic
        if (ks$p.value<0.001) {
          ss[c] = round(ks$statistic,2)
        } else if (ks$p.value<0.05) {
          ss[c] = paste0(round(ks$statistic,2),"*")
        } else {
          ss[c] = paste0(round(ks$statistic,2),"**")
        }
      }
    }
  }
  
  ddd <- data.frame(X=layers_ordered[is], Y=layers_ordered[js], Z=vs[is>0], s=ss[is>0])
  ddd$X <- factor(ddd$X, levels=layers_ordered)
  ddd$Y <- factor(ddd$Y, levels=layers_ordered)
  return(ddd[complete.cases(ddd), ])
}


# Give extreme colors:
ggplot(frm.build() , aes(X, Y, fill=Z)) + 
  geom_tile(colour="white", size=1.5) +
  geom_text(aes(label = s), color="black", size=rel(3.5)) +
  scale_fill_gradient(low = "white", high = "dodgerblue", space = "Lab", na.value = "white", guide = "colourbar") +
  scale_x_discrete(position = "top", expand = c(0, 0)) +
  scale_y_discrete(limits=rev, expand = c(0, 0)) +
  labs(title="Two-sample Kolmogorov-Smirnov test, D-statistic",
       caption = "* p>.001; ** p>0.05") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(angle = 90, size=10, hjust=0),
        axis.text.y = element_text(size=10),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill=NA,color="white", size=0.5, linetype="solid"),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        panel.background = element_rect(fill="white"),
        plot.background = element_rect(fill="white"),
        legend.position = "none", 
        axis.text = element_text(color="black", size=14) )
  


# ks.test(log10(smpl[[1]]), log10(smpl[[3]]))

