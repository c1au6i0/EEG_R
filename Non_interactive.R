
# load packages and scripts
source("J:/EEG data/EEG_R/start.R")


imp <- import_ale(choose.dir())


list2env(imp, .GlobalEnv )



#all subject length session =

alleeg2 <-  equal_sub(alleeg)


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Heatmaps ----------------------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

subt <- paste0("doses = ", paste(round(alldoses, 3), collapse = ", "), 
               " mg/kg given every ", injection_int/60, " min" )

seqbreaks <- seq(0, max(alleeg$time_sec/60), by = injection_int/60)


by(alleeg, alleeg$subject, fheatmap, subt = subt, seqbreaks = seqbreaks)  
  
#------------------------------------------------------------------------



nl_alleeg2 <- no_lateral(dat = alleeg2) 


fsmeans_eeg  <- mean_bands(dat = alleeg2, interv = "300",  freq =  c(4,8,13,30,50)) 


fsperc_eeg <- percent_baseline(df = fsmeans_eeg, groupby = c ("Bands", "channel", "subject") , basel = "drug_dose", variab = "Mean_PSD", 
                               namen = "Percent_baseline", oper = "Mean_PSD/baseline*100")


fgperc_eeg <-  group_mean(dat = fsperc_eeg)


# x <-  lapply(c(60, 300), mean_bands, dat = alleeg2, freq =  c(4,8,13,30,50))
# 
point_graph2(df = fgperc_eeg,  yaes = "Perc", lerr= "Perc_SER", sp= "A", subt2 = subt, sel = "Bands", seqbreaks = seqbreaks)
# point_graph2(df = fgperc_eeg,  yaes = "Mean_abs", lerr= "Abs_SER", sp= "A", subt2 = subt, sel = "Bands", seqbreaks = seqbreaks)


# rep(c(60,300),2)
# rep(c(alleeg2,nl_alleeg2, each =2))

# mapply( mean_bands, rep(c(60,300),2), rep(c(alleeg2,nl_alleeg2, each =2), freq = c(4,8,13,30,50)  )