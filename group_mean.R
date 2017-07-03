group_mean <- function (dat, variab, forB, namen) {


  if(missing(forB)) forB <- "Bands"
  
  
  
  fmeans_eeg <- group_by(dat, .dots = c(forB, "intervals_sec", "channel", " drug_dose", "drug"))
  

  variab <- enquo(variab)
  

  x <- dplyr::summarise(fmeans_eeg, 
                   a = mean(!!variab),
                   n = n(),
                   SD = sd(!!variab),
                   Median_PSD = median(!!variab)
  )

  names(x)[names(x) == "a"] <- paste(namen)
  
  x

}
  

#   
# prova <-  group_mean(dat = fsmeans_eeg, variab = Mean_PSD, namen = "xxx")
#   
# 
# names(prova)[names(prova) == "namen"] <- paste(namen)
# 
# 
# namen <- "prova"
