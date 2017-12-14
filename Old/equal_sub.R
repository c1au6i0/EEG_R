

equal_sub <- function (dat, interv) {
  
  # set the lenght session to the minimum shared between subjects and multiple of injection_interval
  # interv = minimal interval to keep equal....
  
  maxtim <- min( by(dat, dat$subject, function(x) max(x["time_sec"])))
  
  dat <- dplyr::filter( dat , time_sec  <=  floor((maxtim/interv)*as.numeric(interv)))
  
  dat
 
}



no_lateral <- function (dat) {
  
  # Function that removes the lat
  
  dat <- as.data.frame(dat)
  
  dat[,"channel"] <-  plyr::revalue(  dat[,"channel"] , c("EEG_FL" = "EEG_FRONT", 
                                                          "EEG_FR" = "EEG_FRONT",
                                                          "EEG_PL" = "EEG_PARIE",
                                                          "EEG_PR" = "EEG_PARIE",
                                                          "EEG_OL" = "EEG_OCCIP",
                                                          "EEG_OR" = "EEG_OCCIP"))
  dat
  
}




levelsort <- function(x) {
  # Function to sort levels of a DF factor. 
  factor(   x, levels =   sort(as.character(levels(x))) )
} 

