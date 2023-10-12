

p +
  # geom_polygon(data=drainage.area, aes(long,lat), alpha=.2) +
  geom_sf(data=drainage.area, alpha=.3) +
  geom_point(data=dfg, aes(LNG,LAT,color=Source), alpha=.5, size=2) +
  coord_sf(ylim = c(43, 44.2), xlim = c(-80.25, -77.5)) +
  theme(legend.position = c(0.9, 0.55),
        legend.background = element_blank(),
        legend.key = element_rect(fill = "lightblue")) 
#       plot.caption=element_text(size=12, hjust=0, margin=margin(15,0,0,0))) +
# labs(caption="Locations of Chloride samples grouped by their source. Shaded in grey is the\ncontributing area and stretch of Lake Ontario shoreline being investigated.")

vp <- viewport(width = 0.25, height = 0.25, x = 0.71, y = 0.3)
print(p.inset, vp = vp)