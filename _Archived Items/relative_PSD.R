#import the absolute output file fmean_eeg

eeg <- read.csv( file.choose() , header = TRUE, sep = "," , stringsAsFactors = F)
names(eeg)
eeg <-  eeg[,2: ncol(eeg)]


# require tidyr and dplyr and ggplot

library("tidyr")
library("ggplot2")

perc <- function (i) {
   perct <- i$Mean_PSD / sum(i$Mean_PSD) * 100
    names (perct) <- i$Bands
   perct
}



relativePSD  <- as.data.frame (sapply(split(eeg, list(eeg$intervals_sec, eeg$channel)), perc ))

relativePSD[, "Bands"] <-  row.names(relativePSD)
  



names(relativePSD)[names(relativePSD) != "Bands"]

relativePSD_t <- relativePSD   %>% 
  gather_(gather_col= names(relativePSD)[names(relativePSD) != "Bands"],
          key_col= "key", value_col= "PSD") %>% 
  separate(key, c("interval_sec","channel"), extra = "merge")



FR_rel <- subset(relativePSD_t, channel == "EEG_FRONT")

 
ggplot(data = FR_rel, aes(x = as.numeric(interval_sec)/300, y = PSD, colour = Bands)) + 
   geom_line(aes(group = Bands)) +
   labs(x =  "Interval (5 min)", 
       y = "% Relative Power") +
  
  scale_x_continuous(breaks = unique (as.numeric(FR_rel$interval_sec)/300))





  


