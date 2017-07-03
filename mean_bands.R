#create intevals based on band selection and interval in seconds.
# freq = vector containing upper limit of Bands "Delta", "Theta", "Alpha", "Beta", "Gamma"
 



mean_bands <- function(dat, interv, freq) {
  

  interv <- as.numeric(interv)
 
  # Intervals used for the mean  -> mean_intervals (+1 so it does not start from 0)
  
  dat[, "M_interval"] <- as.numeric(findInterval(dat[,"time_sec"], 
                                                 as.numeric(seq(interv, max(dat[,"time_sec"]), interv), left.open = TRUE)) ) + 1
  
  
  dat[, "M_interval"] <-  dat[, "M_interval"] * interv
  
  
  blab <- c("Delta", "Theta", "Alpha", "Beta", "Gamma")
  freq <- as.numeric(c(0,freq))
  
  dat[, "Bands"] <- cut(dat[,"frequency_eeg"],  freq, labels = blab, include.lowest = FALSE)
   
  sel <- as.symbol("Bands")

  # subt2  <- res
  
  #remove frequencies over upper limit of bands (not necessary is NA are omitted after means)
  dat <- dplyr::filter( dat, frequency_eeg  <=  max(freq))
  
  
  
  #Final-Subject-means-eeg
  fsmeans_eeg <- group_by_(dat, .dots = c(sel, "M_interval", "channel", "D_interval", "drug", "date", "subject"))
  fsmeans_eeg <-  dplyr::summarise(fsmeans_eeg,  Mean_PSD = mean(PSD), n = n(), SD = sd(PSD), Median_PSD = median(PSD))
  
  
  fsmeans_eeg <- data.frame(na.omit(fsmeans_eeg))
  
  
  
  # #Final-means-eeg 
  # fmeans_eeg <- fsmeans_eeg  %>%
  #   group_by_(.dots = c(sel, "M_interval", "channel", "D_interval", "drug")) %>%
  #   dplyr::summarise(  Mean_PSD2 = mean(Mean_PSD), n2 = n(), SD2 = sd( Mean_PSD ), Median_PSD2 = median( Mean_PSD ))
  
  
  names(fsmeans_eeg) [c(1,2,4)] <- c( paste(sel), "intervals_sec", "drug_dose" )
  # names(fmeans_eeg) <- names(fsmeans_eeg)[names(fsmeans_eeg) != c("subject", "date")]
  # 
  # 
  # 
  # fmeans_eeg <- na.omit(fmeans_eeg)
  
  fsmeans_eeg

}

# prova <- mean_bands(dat = alleeg2, interv = "300",  freq = freq) 



