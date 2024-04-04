
library(ggplot2)
library(scales)
library(tidyr)



# layer.cols <- c("#cb4f31", "#52c274", "#c25abc", "#65af3a", "#7a67ca", "#b6b138", "#6b8fce", "#d79139", "#4cbdaf", "#d1416d", "#447f47", "#bc6990", "#a0b26a", "#c77a5c")

# df.full %>%
#   mutate(FORMATION = str_replace(FORMATION, ' \\(ORMGP\\)', '')) %>%
#   filter(FORMATION != "") %>%
#   filter(FORMATION != "Newmarket Till/Northern Till") %>% # removes 2 points
#   mutate(FORMATION=factor(FORMATION, levels = rev(layers.ordered))) %>%
#   ggplot(aes(FORMATION, K_MS, fill=FORMATION)) +
#     theme_bw() +
#     # theme(legend.position = 'bottom') +
#     geom_violin() +
#     # geom_jitter(width=.1,alpha=.1) +
#     scale_fill_manual(values = layer.cols, guide='none') +
#     labs(title="Distribution of estimated hydraulic conductivity (by formation)",
#          x=NULL, y="hydraulic conductivity (m/s)") +
#     scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
#                   labels = trans_format("log10", math_format(10^.x))) +
#     coord_flip() +
#     scale_x_discrete(position = 'top')



# From: https://stackoverflow.com/questions/35717353/split-violin-plot-with-ggplot2
GeomSplitViolin <- ggproto("GeomSplitViolin", GeomViolin, 
                           draw_group = function(self, data, ..., draw_quantiles = NULL) {
                             data <- transform(data, xminv = x - violinwidth * (x - xmin), xmaxv = x + violinwidth * (xmax - x))
                             grp <- data[1, "group"]
                             newdata <- plyr::arrange(transform(data, x = if (grp %% 2 == 1) xminv else xmaxv), if (grp %% 2 == 1) y else -y)
                             newdata <- rbind(newdata[1, ], newdata, newdata[nrow(newdata), ], newdata[1, ])
                             newdata[c(1, nrow(newdata) - 1, nrow(newdata)), "x"] <- round(newdata[1, "x"])
                             
                             if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
                               stopifnot(all(draw_quantiles >= 0), all(draw_quantiles <=
                                                                         1))
                               quantiles <- ggplot2:::create_quantile_segment_frame(data, draw_quantiles)
                               aesthetics <- data[rep(1, nrow(quantiles)), setdiff(names(data), c("x", "y")), drop = FALSE]
                               aesthetics$alpha <- rep(1, nrow(quantiles))
                               both <- cbind(quantiles, aesthetics)
                               quantile_grob <- GeomPath$draw_panel(both, ...)
                               ggplot2:::ggname("geom_split_violin", grid::grobTree(GeomPolygon$draw_panel(newdata, ...), quantile_grob))
                             }
                             else {
                               ggplot2:::ggname("geom_split_violin", GeomPolygon$draw_panel(newdata, ...))
                             }
                           })

geom_split_violin <- function(mapping = NULL, data = NULL, stat = "ydensity", position = "identity", ..., 
                              draw_quantiles = NULL, trim = TRUE, scale = "area", na.rm = FALSE, 
                              show.legend = NA, inherit.aes = TRUE) {
  layer(data = data, mapping = mapping, stat = stat, geom = GeomSplitViolin, position = position, 
        show.legend = show.legend, inherit.aes = inherit.aes, 
        params = list(trim = trim, scale = scale, draw_quantiles = draw_quantiles, na.rm = na.rm, ...))
}

df.full %>% 
  mutate(FORMATION = str_replace(FORMATION, ' \\(ORMGP\\)', '')) %>%
  filter(FORMATION != "") %>%
  filter(FORMATION != "unknown") %>%
  filter(FORMATION != "Newmarket Till/Northern Till") %>% # removes 2 points
  mutate(FORMATION=factor(FORMATION, levels = rev(layers.ordered))) %>%
  
  select(c(FORMATION, K_MS, KSC_SCR_MS)) %>%
  gather("est", "k", -FORMATION) %>%
  mutate(est = str_replace(est, '_MS', '')) %>%
  drop_na() %>%
  
  ggplot(aes(FORMATION, k, fill=est)) +
    theme_bw() +
    theme(legend.position = c(.01,.99),
          legend.title = element_blank(),
          legend.justification = c(0,1),
          legend.background = element_blank()) +
    geom_split_violin() +
    labs(title="Distribution of estimated hydraulic conductivity (by formation)",
         x=NULL, y="hydraulic conductivity (m/s)") +
    scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x))) +
    coord_flip() +
    scale_x_discrete(position = 'top')


ggsave("../../md/hydraulicProperties-ggplot-k-violin.png", height=6, width=6, units = "in", dpi="retina")




# TABLE
View(
df.full %>% 
  mutate(FORMATION = str_replace(FORMATION, ' \\(ORMGP\\)', '')) %>%
  filter(FORMATION != "") %>%
  filter(FORMATION != "unknown") %>%
  filter(FORMATION != "Newmarket Till/Northern Till") %>% # removes 2 points
  mutate(FORMATION=factor(FORMATION, levels = layers.ordered)) %>%
  
  select(c(FORMATION, K_MS, KSC_SCR_MS)) %>%
  gather("est", "k", -FORMATION) %>%
  mutate(est = str_replace(est, '_MS', '')) %>%
  drop_na() %>%

  group_by(FORMATION,est) %>%
  summarise(n=n(), 
            mean=mean(k, na.rm=TRUE), 
            geomean=exp(mean(log(k), na.rm=TRUE)), 
            median=median(k, na.rm=TRUE)) 
)
