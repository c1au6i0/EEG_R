# Function that removes the lat


no_lateral <- function (dat) {
  
  dat <- as.data.frame(dat)

  dat[,"channel"] <-  plyr::revalue(  dat[,"channel"] , c("EEG_FL" = "EEG_FRONT", 
                                                   "EEG_FR" = "EEG_FRONT",
                                                   "EEG_PL" = "EEG_PARIE",
                                                   "EEG_PR" = "EEG_PARIE",
                                                   "EEG_OL" = "EEG_OCCIP",
                                                   "EEG_OR" = "EEG_OCCIP"))
  dat
  
}
  
  

# use: alleeg2 <- no_lateral(dat = alleeg2)

