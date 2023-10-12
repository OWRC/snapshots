

curve_df <- scale.transformation(dfg, fit)  

summary <- paste0('mean(sd) = ', round(exp(fit$estimate[[1]]),1), '(',
                  round(exp(fit$estimate[[2]]),1), ') mg/L\nn = ',
                  format(nrow(dfg),big.mark=",",scientific=FALSE)) 
#; p5 ', round(p5,1), '; p95 ', round(p95,1) )

p.qq <- ggplot(dfg, aes(sample=log10(VALUE))) + 
  theme_bw() +
  stat_qq() +
  stat_qq_line() +
  labs(x="Theoretical quantities",
       y="Log Cl- (mg/L)")

p.hist1 <- ggplot(dfg) +
  theme_bw() +
  theme(axis.text.y = element_blank(), axis.title.y = element_blank(),
        legend.position = c(.15,.8)) +
  # https://stackoverflow.com/questions/48050367/wrong-density-values-in-a-histogram-with-fill-option-in-ggplot2
  geom_histogram(aes(x=VALUE, 
                     y = after_stat(count)/ sum(after_stat(count)) / after_stat(width), 
                     fill=Source),
                 colour = 1) +
  geom_line(data = curve_df,
            aes(xx, pdf_10),
            col="darkred",
            linewidth = I(1.2),
            linetype = 1) +
  
  # geom_rect(aes(xmin=x0, xmax=x1, ymin=0, ymax=.6), color="transparent", fill="orange", alpha=0.3) +
  
  # geom_vline(xintercept = med, linetype="dotted", show_guide=TRUE) +
  # # annotate("text",x=med,y=.4, fill = "green",label=paste0(round(med,1)," mg/L")) +
  # geom_label(aes(x=med,y=.4,label=paste0(round(med,1)," mg/L")), fill = "white") +
  scale_x_log10(labels = comma, limits = c(.1,10000)) +
  scale_fill_discrete(name=NULL) +
  # coord_cartesian(ylim=c(NA,.55)) +
  labs(x=paste0('Maximum measured chloride concentration (mg/L)')) #, title = summary)

p.hist1 + geom_label(aes(x=1000,y=.5,label=summary), fill = "white")




vp <- viewport(x=0.8,y=0.7,width=0.25,height=0.25)
print(p.qq, vp = vp)

