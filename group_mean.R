group_mean <- function (dat, forB) {


  if(missing(forB)) forB <- "Bands"
  
  
  
  fmeans_eeg <- group_by(dat, .dots = c(forB, "intervals_sec", "channel", " drug_dose", "drug"))
  


  x <- dplyr::summarise(fmeans_eeg, 
                   Mean_abs = mean(Mean_PSD),
                   n = n(),
                   Abs_SD = sd(Mean_PSD),
                   Abs_SER = Abs_SD / sqrt(n()),
                   Median_abs = median(Mean_PSD),
                   Perc = mean(Percent_baseline),
                   Perc_SD = sd(Percent_baseline),
                   Perc_SER = Perc_SD/ sqrt(n())
  )

  # names(x)[names(x) == "a"] <- paste(namen)
  
  x
}
  

   

