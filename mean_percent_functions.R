
mean_bands <- function(dat, interv, freq) {
  # dat = an alex dataframe with a column with continuum frequencies "frequency_eeg" and 
  #       one with time in seconds "time_sec"
  # create intevals based on band selection and interval in seconds.
  # freq = vector containing upper limit of Bands "Delta", "Theta", "Alpha", "Beta", "Gamma"
  
  
  if (missing(freq)) freq <- c(4,8,13,30,50)
  
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
  fsmeans_eeg <-  dplyr::summarise(fsmeans_eeg, PSD_abs = mean(PSD),
                                                n = n(), 
                                                PSD_abs_SD = sd(PSD),
                                                PSD_abs_SER = PSD_abs_SD / sqrt(n),
                                                PSD_median = median(PSD)
                                   )
  
  
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


chan_group_mean <- function (dat, groupby) {
  
  # create aggregated means in a data.frame based on categorical var (column) selected in groupby
  
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


percent_baseline <- function(df, groupby, basel, variab , form, oper, namen) {
  
  # Percent baseline function
  # df = dataframe
  # groupby = list of columns/factors by which calculate operation
  # basel = column that contains multiple factors one of which is called "baseline"
  # oper = formula
  # vars = column containing  the continous variable to apply the func
  # namen = name of the new created column with the fourmula.
  #  form = formula to summarize the baseline, default is mean
  # oper = formula to use to expresse variab as function of baseline express in baseline (/*-+) Mean_PSD or viceversa
  
  
  if(missing(form)) form <- "mean"
  
  df <- as.data.frame(df)
  
  # create formula
  formvars <- paste0(form, "(", variab , ")")
  
  baseline_eeg <- subset(df, get(basel) == "baseline" )
  
  baseline_eeg  <- group_by_(baseline_eeg,.dots = groupby)
  
  baseline_eeg <- summarize_(baseline_eeg, .dots = as.lazy(formvars) )
  
  
  #changes names of the new created columns
  names(baseline_eeg)[length(names(baseline_eeg))] <- variab 
  
  
  # Sort baseline_eeg by sel, channel, subject
  baseline_eeg <-  dplyr::arrange_(data.frame(ungroup(baseline_eeg)), .dots =  groupby)
  
  
  obsv <-  group_by_(df, .dots = groupby) 
  obsv <-  dplyr::summarise(obsv,  Observ = n() ) 
  obsv <-  dplyr::arrange_(data.frame(ungroup(obsv)), .dots =  groupby)
  
  
  
  
  out <-  dplyr::arrange_(data.frame(ungroup(df)), .dots =groupby)
  
  

  out[, "baseline"] <- rep(baseline_eeg[, variab], obsv$Observ)
  
  
  
  baseline <-  out$baseline
  x <- out[, variab]
  
  assign(paste(variab),x)
  
  out[, namen] <-   eval(parse(text = oper))
  
  
  as.data.frame(out)
}












