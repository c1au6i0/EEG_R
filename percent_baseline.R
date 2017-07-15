# Percent baseline function
# df = dataframe
# groupby = list of columns/factors by which calculate operation
# basel = column that contains multiple factors one of which is called "baseline"
# oper = formula
# vars = column containing  the continous variable to apply the func
# namen = name of the new created column with the fourmula.
#  form = formula to summarize the baseline, default is mean
# oper = formula to use to expresse variab as function of baseline express in baseline (/*-+) Mean_PSD or viceversa



percent_baseline <- function(df, groupby, basel, variab , form, oper, namen) {
  
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

  
  ########################
  
  out[, "baseline"] <- rep(baseline_eeg[, variab], obsv$Observ)

  

  baseline <-  out$baseline
  x <- out[, variab]
  
  assign(paste(variab),x)

  out[, namen] <-   eval(parse(text = oper))
  
  
  as.data.frame(out)
}




# prova <- percent_baseline(df = fsmeans_eeg, groupby = c ("Bands", "channel", "subject") , basel = "drug_dose", variab = "Mean_PSD", 
#                  namen = "Percent_baseline", oper = "Mean_PSD/baseline*100")

# 


