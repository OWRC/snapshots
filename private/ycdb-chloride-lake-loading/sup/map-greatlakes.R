

print(
  basemapGL + 
    # geom_polygon(data=drainage.area, aes(long,lat, 
    #                                      fill='North shore catchment area',
    #                                      color='North shore catchment area',
    # )) +  
    geom_sf(data=drainage.area, aes(fill="North shore catchment area",
                                    color='North shore catchment area'), 
            linewidth=1, alpha=.3) +
    geom_polygon(data=lontario.da, aes(long,lat, 
                                       fill='Lake Ontario catchment area',
                                       color='Lake Ontario catchment area',
    ),
    linewidth=1) +
    geom_polygon(data=ormgp.bound, aes(long,lat, 
                                       fill='ORMGP',
                                       color='ORMGP',
    ),
    linewidth=2) +
    geom_sf_text(data = lakes_sf[lakes_sf$area > 1000,], aes(label = name), nudge_x = -.3, nudge_y = -.2) +
    scale_fill_manual(
      name=NULL,
      values = c("#e6d84a4D","#a85588","#00000000"),
    ) +
    scale_color_manual(
      name=NULL,
      values = c("black","#00000000","#71a356"),
    ) +
    annotation_scale(location = "br",
                     width_hint = 0.25,
                     text_cex = 1) +
    annotation_north_arrow(location = "br",
                           which_north = "true",
                           pad_x = unit(0.15, "in"),
                           pad_y = unit(0.3, "in"),
                           style = north_arrow_fancy_orienteering) + 
    theme_void() +
    theme(legend.position = c(.8,.85))  
)
