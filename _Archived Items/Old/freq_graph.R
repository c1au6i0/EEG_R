##


freq_graph  <- function(dat)
  
  
alleeg$D_interval  
dat  <-  alleeg2

dat <- dat %>%
          dplyr::group_by(time_sec, frequency_eeg, channel, D_interval, drug)%>%
          dplyr::summarise(PSD_abs = mean(PSD),
                          PSD_SD = sd(PSD),
                          PSD_n = n(),
                           PSD_SER =sd(PSD)/sqrt(n())
          )


dat$D_interval <- factor(dat$D_interval, levels = append("baseline", unique(dat$D_interval)[!unique(dat$D_interval) == "baseline"]))
prova <- ggplot(alleeg3, aes(x = frequency_eeg, y = PSD_abs, colour = D_interval)) + 
  geom_line() +
  facet_grid(.~channel)



ggplotly(prova)


