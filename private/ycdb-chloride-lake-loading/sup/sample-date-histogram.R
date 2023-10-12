df %>%
  mutate(Source=case_when(INT_TYPE=='Surface Water - All' ~ 'surface', 
                          SCREEN_TOP_DEPTH_M<=20 ~ 'deep GW', 
                          SCREEN_TOP_DEPTH_M>20 ~ 'shallow GW', 
                          TRUE ~ 'unknown')) %>%
  mutate(yr=year(SAMPLE_DATE), mo=as.factor(month(SAMPLE_DATE))) %>%
  ggplot(aes(x=mo,fill=Source)) +
  theme_bw() +
  geom_bar(position = "dodge") +
  # geom_histogram() +
  scale_x_discrete(name=NULL, labels = month.abb)
