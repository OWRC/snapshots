

ggplot(dfg %>% filter(!is.na(SCREEN_GEOL_UNIT))) +
  theme_bw() +
  theme(axis.title.y = element_blank()) +
  ggridges::geom_density_ridges(aes(x=VALUE, y=factor(SCREEN_GEOL_UNIT, levels=rev(layers_ordered)), color=SCREEN_GEOL_UNIT, fill=SCREEN_GEOL_UNIT), show.legend = FALSE) +
  # geom_histogram(aes(x=VALUE, color=SCREEN_GEOL_UNIT, fill=SCREEN_GEOL_UNIT), alpha=.3) +
  scale_x_log10(labels = comma, limits = c(.1,10000)) +
  scale_y_discrete(position = "right") +
  labs(x=paste0('Maximum measured chloride concentration (mg/L)')) #, title = summary)
