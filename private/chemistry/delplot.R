



###########################################
########### NEEDS QUERY FROM isotopes.R ###
###########################################





# interactive (see: https://davidgohel.github.io/ggiraph/)
library(ggiraph)
library(cowplot)
library(geojsonio)
library(sf)


# great.lakes <- geojson_read("E:/Sync/@gis/water/GreatLakes_WGS.geojson",  what = "sp") %>% broom::tidy()
lakes <-rnaturalearth::ne_download(scale = "large", type = 'lakes', category = 'physical') %>% sf::st_as_sf(lakes110, crs = 4269)



# ne_countries(scale = "medium", returnclass = "sf")

p1 <- df.val %>% ggplot() +
  geom_point_interactive(aes(x = `O18 (del O18)`, y = `2H (Deuterium)`, tooltip = tooltip, data_id = tooltip ), size = 1) +
  geom_abline(slope = 8,intercept = 10) +
  annotate(
    "text",
    x = -11.9,
    y = -12*7.5,
    # angle = 45,
    label = "GMWL"
  ) +
  labs(
    title=paste0("\u03B4-diagram (n=",length(df.val$LOC_ID),")"),
    # subtitle="Oak Ridges Moraine area",
    x=bquote(delta^18*O~"(\u2030)"), y="\u03B4\u00B2H (\u2030)")
# labs(title=paste0("\u03B4-diagram (n=",length(df.val$LOC_ID),")"), 
#      x="\u03B4<sup>18</sup>0 (\u2030)", y="\u03B4\u00B2H (\u2030)")


p2 <- df.val %>% ggplot() +
  theme_bw() +
  # geom_polygon(data = great.lakes, aes( x = long, y = lat, group=id), alpha=.6) +
  geom_sf(data=lakes) +
  geom_point_interactive(aes(x = LONG, y = LAT, tooltip = tooltip, data_id = tooltip ), size = 1) +
  labs(x=" ",y=NULL) + #title="hover over points", 
  xlim(c(min(df.val$LONG),max(df.val$LONG))) +
  ylim(c(min(df.val$LAT),max(df.val$LAT))) +
  coord_sf()

l <- girafe(ggobj = plot_grid(p1, p2), width_svg = 7, height_svg = 4, 
            options = list(
              opts_hover_inv(css = "opacity:0.25;"),
              opts_hover(css = "fill:orange; r:2;"),
              opts_toolbar(saveaspng = FALSE)
              # opts_zoom(max = 5)
            ))

htmlwidgets::saveWidget(l, "chemistry/chem-isotope-delplot-map.html", title = paste0("\u03B4-diagram (n=",length(df.val$LOC_ID),")") )









########################################################################



# del-graoh only
p <- df.val %>% ggplot() +
  geom_point(aes(`O18 (del O18)`,`2H (Deuterium)`, group=NAME, colour=Depth)) +
  geom_abline(aes(slope = 8,intercept = 10, linetype="GMWL"), colour="black") +
  geom_abline(aes(slope = 7.92,intercept = 10.53, linetype="LMWL"), colour="black") +
  # annotate(
  #   "text",
  #   x = -12,
  #   y = -12 * 8 + 9,
  #   angle = 45,
  #   label = "GMWL"
  # ) +
  # labs(title=paste0("\u03B4-diagram (n=",length(df.val$LOC_ID),")"),
  #      subtitle="Oak Ridges Moraine area",
  #      x=bquote(delta^18*O~"(\u2030)"), y="\u03B4\u00B2H (\u2030)",
  #      colour="depth", linetype=NULL) +
  labs(title=paste0("\u03B4-diagram (n=",length(df.val$LOC_ID),")"),
       x="\u03B4<sup>18</sup>0 (\u2030)", y="\u03B4\u00B2H (\u2030)",
       linetype=NULL) +
  scale_linetype_manual(values=c("solid","dashed")) +
  xlim(c(-20,-5))


l <- ggplotly(p) %>% layout(legend = list(x = 0.1, y = 0.9))
  # layout(annotations = list(x = -12.9, y = -12*8, text = "GMWL", showarrow = F ))

htmlwidgets::saveWidget(l, "chemistry/chem-isotope-delplot.html")






