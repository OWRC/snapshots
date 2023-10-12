

p +
  geom_sf(data=drainage.area, aes(fill="Whitebelt"), linewidth=1, alpha=.3) +
  # geom_polygon(data=drainage.area, aes(long,lat), alpha=.1) +
  geom_sf(data=drainage.area.grnblt, aes(fill="Greenbelt"), alpha=.3) + #, fill='darkgreen', color=NA) +
  geom_sf(data=drainage.area.builtup, aes(fill="Built-Up Areas"), alpha=.5) + #, fill='brown', color=NA) +
  # geom_sf(data=drainage.area.roads) +
  # annotate("text",x=-79.5,y=43.7, label="Toronto") +
  geom_shadowtext(aes(x = -79.5, y = 43.7),
                  label = "Toronto",
                  size = 5) +
  coord_sf(ylim = c(43, 44.2), xlim = c(-80.25, -77.5)) +
  scale_fill_manual(values = c("#F8766D", "#00BA38", "#FFCDBC"), name = "Land designation", 
                    guide = guide_legend(reverse = TRUE)) +
  theme(legend.position = c(0.9, 0.55),
        legend.background = element_blank(),
        legend.key = element_rect(fill = "lightblue")) 
#       plot.caption=element_text(size=12, hjust=0, margin=margin(15,0,0,0))) +
# labs(caption="Locations of Chloride samples grouped by their source. Shaded in grey is the\ncontributing area and stretch of Lake Ontario shoreline being investigated.")




vp <- viewport(width = 0.25, height = 0.25, x = 0.71, y = 0.3)
print(p.inset, vp = vp)