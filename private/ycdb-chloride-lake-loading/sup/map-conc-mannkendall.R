

# Adding the $sl after MannKendall() specifies the p value. Alternatively, you could specify tau, Kendall Score (S), denominator (D) of variance of S (varS)
nn <- 100
yn <- 10
p + geom_point(data = df %>%
                 group_by(INT_ID,LNG,LAT) %>%
                 mutate(n=n(), nd=max(SAMPLE_DATE)-min(SAMPLE_DATE)) %>%
                 filter(n>nn, nd>yn*365*86400) %>%
                 arrange(SAMPLE_DATE) %>%
                 summarise(pmk=MannKendall(VALUE)$sl, zmk=MannKendall(VALUE)$tau) %>%
                 ungroup() %>%
                 mutate(Trend = 1) %>%
                 mutate(Trend = case_when(zmk > 0 ~ 24 , zmk < 0 ~ 25)) %>%
                 mutate(Trend = case_when(pmk > .02 ~ 1, TRUE ~ Trend)) %>%
                 mutate(zmk = case_when(Trend == 1 ~ 0.1, TRUE ~ zmk)) %>%
                 mutate(Trend = as.integer(Trend)) %>%
                 mutate(Trend = as.factor(Trend)),
               aes(LNG,LAT,size=abs(zmk),fill=Trend, shape=Trend)) +
  
  scale_shape_manual(values=c(21,24,25), labels = c("none", "increasing", "decreasing")) +
  scale_fill_manual(values=c("black","blue","red"), labels = c("none", "increasing", "decreasing")) +
  scale_size(guide="none", range = c(1, 3)) +
  labs(title=paste0("Mann-Kendall test for trend (n>",nn,", PoR>",yn,"yr, p<0.02)"),
       subtitle="Chloride",
       x=NULL, y=NULL) +
  theme(legend.position = c(0.9, 0.55),
        legend.background = element_blank(),
        legend.key = element_rect(fill = "lightblue")) 
