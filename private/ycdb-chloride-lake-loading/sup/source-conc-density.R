ggplot(dfg) +
  theme_bw() +
  theme(axis.text.y = element_blank(), axis.title.y = element_blank(),
        legend.position = c(.15,.8)) +
  geom_density(aes(x=VALUE, color=Source, fill=Source), alpha=.3) +
  # geom_histogram(aes(x=VALUE, color=Source, fill=Source), alpha=.3) +
  geom_label(aes(x=1000,y=.5,label=paste0("n=",format(nrow(dfg),big.mark=",",scientific=FALSE))), fill = "white") +
  scale_x_log10(labels = comma, limits = c(.1,NA)) +
  labs(x=paste0('Maximum measured chloride concentration (mg/L)')) #, title = summary)
