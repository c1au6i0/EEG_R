eeg <- read.csv( file.choose() , header = TRUE, sep = "," , stringsAsFactors = F)
names(eeg)
eeg <-  eeg[,2: ncol(eeg)]


# require tidyr and dplyr and ggplot


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



FR_rel <- subset(relativePSD_t, channel == "EEG_FL")

 
ggplot(data = FR_rel, aes(x = factor(interval_sec), y = PSD, colour = Bands)) + 
   geom_line(aes(group = Bands)) +
   labs(x =  "Interval (5 min)", 
       y = "% Power") +

  scale_x_discrete( expand = c(0,0), labels = B)


+ 

  
B <- 1:27

