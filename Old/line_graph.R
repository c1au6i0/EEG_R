

alleegM <- alleeg2 %>%
  group_by_(.dots = c(sel, "channel", "D_interval", "M_interval", "drug", "date", "time_sec") ) %>%
  dplyr::summarise(  Mean_PSD = mean(PSD), n = n(), SD = sd(PSD), Median_PSD = median(PSD))


ggplot(alleegM, aes(time_sec/60, Mean_PSD, colour = D_interval)) +
  geom_line() +
  facet_grid(as.formula(paste(sel,"~","channel")), scales = "free_y")


