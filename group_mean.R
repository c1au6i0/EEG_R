group_mean <- function (dat, variab, forB) {


  if(missing(forB)) forB <- "Bands"
  
  
  
  fmeans_eeg <- group_by(dat, .dots = c(forB, "intervals_sec", "channel", " drug_dose", "drug"))
  

  variab <- enquo(variab)
  

  x <- dplyr::summarise(fmeans_eeg, 
                   a = mean(!!variab),
                   n = n(),
                   SD = sd(!!variab),
                   Median_PSD = median(!!variab)
  )

  x <- rename(x, Mean_PSD = a )
  
  x

}
  

  
# prova <-  group_mean(dat = fsmeans_eeg, variab = Mean_PSD)
  

