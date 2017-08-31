# create means in a data.frame based on var selected in group by

chan_group_mean <- function (dat, groupby) {

  dat <- as.data.frame(dat)
    
  if(missing(groupby)) groupby <- c("Bands", "intervals_sec", "channel", "drug_dose", "drug")
  
  
  
  fmeans_eeg <- group_by(dat, .dots = groupby)
  


  x <- dplyr::summarise(fmeans_eeg, 
                   PSD_abs2 = mean(PSD_abs),
                   n2 = n(),
                   PSD_abs_SD2 = sd(PSD_abs),
                   PSD_abs_SER2 = PSD_abs_SD2  / sqrt(n()),
                   PSD_Median2 = median(PSD_abs),
                   PSD_Perc2 = mean(PSD_perc),
                   Perc_SD2 = sd(PSD_perc),
                   Perc_SER2 = Perc_SD2/ sqrt(n())
  )

  
  names(x)[(length(names(x))-7) : length(names(x))] <- c("PSD_abs", 
                                                         "n",
                                                         "PSD_abs_SD",
                                                         "PSD_abs_SER",
                                                         "PSD_median",
                                                         "PSD_perc",
                                                         "PSD_perc_SD",
                                                         "PSD_perc_SER"
  )

  x                                                         

}
  

   

