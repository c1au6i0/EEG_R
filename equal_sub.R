# set the lenght session to the minimum shared between subjects and multiple of injection_interval
# interv = minimal interval to keep equal....

equal_sub <- function (dat, interv) {
  
  maxtim <- min( by(dat, dat$subject, function(x) max(x["time_sec"])))
  
  dat <- dplyr::filter( dat , time_sec  <=  floor((maxtim/interv)*as.numeric(interv)))
  
  dat
 
}




