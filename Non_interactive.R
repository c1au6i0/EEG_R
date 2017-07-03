
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


# wdir <- getwd()

# res <- dlgMessage( c("Are you interested in heatmaps?"), "yesno" )$res
# 
# if (res == "yes") {
#   
#   msgBox(c("Good, it might take few sec. PRESS OK "))
  
by(alleeg, alleeg$subject, fheatmap, subt = subt)  
  
#   msgBox(c("Heatmaps have been created in ",  wdir) ) 
#   
# }



# use: alleeg2 <- no_lateral(dat = alleeg2) -----


fsmeans_eeg  <- mean_bands(dat = alleeg2, interv = "300",  freq =  c(4,8,13,30,50)) 


fsperc_eeg <- percent_baseline(df = fsmeans_eeg, groupby = c ("Bands", "channel", "subject") , basel = "drug_dose", variab = "Mean_PSD", 
                               namen = "Percent_baseline", oper = "Mean_PSD/baseline*100")


fgperc_eeg <-  group_mean(dat = fsperc_eeg , variab = Percent_baseline, namen = "Percent_baseline")


x <-  lapply(c(300, 600), mean_bands, dat = alleeg2, freq =  c(4,8,13,30,50))



