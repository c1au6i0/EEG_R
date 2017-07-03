# set the lenght session to the minimum shared between subjects and multiple of injection_interval


equal_sub <- function (dat, injection_int) {
  
  maxtim <- min( by(dat, dat[,"subject"], function(x) max(dat[,"time_sec"]) ))
  
  dat <- dplyr::filter( dat, time_sec  <=  floor(maxtim/injection_int)*injection_int)
  
  dat
 
}


# prova <- equal_sub(alleeg2)
