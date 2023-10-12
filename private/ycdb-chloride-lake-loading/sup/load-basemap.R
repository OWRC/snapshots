

p <- ggplot() +
  geom_sf(data = lakes_sf,
          mapping = aes(geometry = geometry),
          color = "black",
          fill = "lightblue") +
  # geom_sf_label(data = lakes_sf, aes(label = name)) +
  coord_sf(ylim = c(43, 44.2),
           xlim = c(-80.25, -77.5),
           expand = TRUE) +
  annotation_scale(location = "br",
                   width_hint = 0.25,
                   text_cex = 1) +
  annotation_north_arrow(location = "br",
                         which_north = "true",
                         pad_x = unit(0.15, "in"),
                         pad_y = unit(0.3, "in"),
                         style = north_arrow_fancy_orienteering) +
  annotate("text",-78.75,43.6,label="Lake Ontario") +
  labs(x = "Longitude",
       y = "Latitude") +
  theme_bw() +
  theme(axis.text.x = element_text(size = 12, color = "black"),
        axis.text.y = element_text(size = 12, color = "black"),
        panel.grid.major = element_line(color = gray(0.5),
                                        linetype = "dashed",
                                        linewidth = 0.5))


p.inset <- basemapGL +
  geom_rect(aes(xmin=-80.25, xmax=-77.5, ymin=43, ymax=44.3), fill=NA, color='black', linewidth=1)