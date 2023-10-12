




df <- read.csv('ps-3-1/Alton PS 3-1 Alton PS 3-1.csv')
names(df) <- c('date','wl','rf','sm')


df %>% filter(wl>300) %>% ggplot(aes(as.Date(date), wl)) +
  geom_line() +
  xlim(c(as.Date('2010-05-01'), as.Date('2011-01-01')))


df %>% gather('type','value', -date) %>% filter(type!='wl') %>% ggplot(aes(as.Date(date), value)) + 
  geom_bar(stat = "identity", aes(fill=type)) +
  xlim(c(as.Date('2010-05-01'), as.Date('2011-01-01'))) +
  scale_fill_manual(name=NULL, values = cols, labels = c("rainfall",'snowmelt')) +
  scale_y_continuous(trans="reverse")



# https://stackoverflow.com/questions/65844743/rainfall-runoff-plotting
minRange <- 392
maxRange <- 1.25 + minRange
coeff <- 100

df %>% 
  filter(wl>300) %>% 
  # mutate(wl=wl-minRange) %>% 
  ggplot(aes(as.Date(date))) +
    theme_bw() + 
    theme(legend.position = c(.2,.1),
          legend.background = element_blank(),
          legend.direction="horizontal") +
    geom_tile(aes(y = maxRange - rf/coeff/2,
                  height = rf/coeff,
                  fill = 'rainfall')) +
    geom_tile(aes(y = maxRange - (rf+sm/2)/coeff,
                  height = sm/coeff,
                  fill = 'snowmelt')) +
    geom_line(aes(y = wl), linewidth=1) +
    labs(x=NULL, title = "Alton PS 3-1") +
    # xlim() +
    scale_x_date(date_labels = "%b", date_breaks = "months", limits = c(as.Date('2010-05-01'), as.Date('2010-12-15'))) +
    scale_fill_manual(name=NULL, values = cols, labels = c("rainfall",'snowmelt')) +
    scale_y_continuous(name = "level (masl)", #"level (m)",
                       limit = c(NA, maxRange), #c(0, maxRange),
                       expand = c(0, 0),
                       sec.axis = sec_axis(trans = ~(.-maxRange)*coeff,
                                           name = "precipitation (mm/day)"))


# ggsave('./gwvar/img/AltonPS-3-1.png',height=6,width=13,units = 'cm')


