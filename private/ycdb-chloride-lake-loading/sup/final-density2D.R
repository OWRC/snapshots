


## 2D Density plot (see density.R for values from MD)
n.samples <- 100000
mm.to.km3 <- 6526.3841/1000/1000 # 64030/1000/1000 # 
# df.dir <- data.frame(x=rlnorm(n.samples,
#                               meanlog = fit$estimate[[1]],
#                               sdlog = fit$estimate[[2]]),
#                      y=rnorm(n.samples, mean = 18, sd = 26.41401848)) %>%
#   mutate(load=mm.to.km3*x*y)  # numerical model direct discharge
# df.ind <- data.frame(x=rlnorm(n.samples,
#                               meanlog = fit$estimate[[1]],
#                               sdlog = fit$estimate[[2]]),
#                      y=rnorm(n.samples, mean = 145, sd = 48.18655831)) %>%
#   mutate(load=mm.to.km3*x*y)  # numerical model indirect discharge
# df.ind <- data.frame(x=rlnorm(n.samples, mean = fit$estimate[[1]], sd = fit$estimate[[2]]),y=rnorm(n.samples, mean = 218.3561 , sd = 93.97991)) %>% mutate(load=mm.to.km3*x*y) # separated discharge
df.ind <- data.frame(x=rlnorm(n.samples, mean = fit$estimate[[1]], sd = fit$estimate[[2]]),
                     y=rlnorm(n.samples, mean = 5.30178701, sd = 0.41321367)) %>% 
  mutate(load=mm.to.km3*x*y) 
df.dir <- data.frame(x=rlnorm(n.samples, mean = fit$estimate[[1]], sd = fit$estimate[[2]]),
                     y=rlnorm(n.samples, mean = 2.64252697, sd = 0.41321367)) %>% 
  mutate(load=mm.to.km3*x*y)  # numerical model total discharge

# ggplot() +
#   stat_density_2d(data=df.dir,
#                   geom = "polygon", contour = TRUE,
#                   aes(x,load, fill = after_stat(level)), colour = "black",
#                   bins = 5) +
#   scale_x_log10(labels = comma) +
#   scale_y_log10(labels = comma) +
#   scale_fill_distiller(palette = "Blues", direction = 1) +
#   labs(x='Chloride concentration (mg/L)',y="Lake Ontario N.shore loading (kilotonnes/yr)")



p.mdl <- ggplot() +
  theme_bw() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  # geom_density(data=data.frame(y=rnorm(n.samples, mean = 145, sd = 48.18655831)), aes(y, fill="indirect"), linewidth = I(1.2), alpha=.5) +
  # geom_density(data=data.frame(y=rnorm(n.samples, mean = 18, sd = 26.41401848)), aes(y, fill="direct"), linewidth = I(1.2), alpha=.5) +
  geom_density(data=df.ind, aes(y*mm.to.km3, fill="indirect"), linewidth = I(1.2), alpha=.5) +
  geom_density(data=df.dir, aes(y*mm.to.km3, fill="direct"), linewidth = I(1.2), alpha=.5) +
  scale_x_log10(limits=c(.02,8)) +
  scale_fill_manual(values = c("#5691ff", "#c31214")) +
  rotate() + 
  # clean_theme() + 
  guides(fill="none")


twoD <- ggplot() +
  theme_bw() +
  theme(legend.position = c(0.2, 0.85)) +
  stat_density_2d(data=df.ind,
                  geom = "polygon", contour = TRUE,
                  aes(x,load,
                      alpha = after_stat(nlevel),
                      fill="indirect",
                      group=1),
                  colour = "black", size=1,
                  bins = 5) +
  stat_density_2d(data=df.dir,
                  geom = "polygon", contour = TRUE,
                  aes(x,
                      load,
                      alpha = after_stat(nlevel),
                      fill="direct",
                      group=2),
                  colour = "black", size=1,
                  bins = 5) +
  # geom_point(alpha=.1) +
  scale_x_log10(labels = comma_format(accuracy = 1), limits = c(1, 1000)) +
  scale_y_log10(labels = comma_format(accuracy = 1), limits = c(.2, 500)) +
  scale_fill_manual(values = c("#5691ff", "#c31214")) +
  labs(x='Maximum measured chloride concentration (mg/L)',
       y="Lake Ontario north shore loading (kta)",
       fill="Source") +
  guides(alpha="none") +
  annotation_logticks(sides = "lb")




ggarrange(p.hist1 + clean_theme() + theme(axis.text = NULL, legend.position = "none"), 
          NULL, 
          twoD, 
          p.mdl + labs(x="Lake Ontario north shore discharge (km³/a)", y=NULL), 
          ncol = 2, nrow = 2,  align = "hv", 
          widths = c(2, .5), heights = c(.5, 2))
          # common.legend = TRUE)




# # http://www.sthda.com/english/articles/24-ggpubr-publication-ready-plots/81-ggplot2-easy-way-to-mix-multiple-graphs-on-the-same-page/
# # Scatter plot colored by groups ("Species")
# sp <- ggscatter(iris, x = "Sepal.Length", y = "Sepal.Width",
#                 color = "Species", palette = "jco",
#                 size = 3, alpha = 0.6)+
#   border()
# # Marginal density plot of x (top panel) and y (right panel)
# xplot <- ggdensity(iris, "Sepal.Length", fill = "Species",
#                    palette = "jco")
# yplot <- ggdensity(iris, "Sepal.Width", fill = "Species",
#                    palette = "jco")+
#   rotate()
# # Cleaning the plots
# yplot <- yplot # + clean_theme()
# xplot <- xplot # + clean_theme()
# # Arranging the plot
# ggarrange(xplot, NULL, sp, yplot,
#           ncol = 2, nrow = 2,  align = "hv",
#           widths = c(2, 1), heights = c(1, 2),
#           common.legend = TRUE)
# 
