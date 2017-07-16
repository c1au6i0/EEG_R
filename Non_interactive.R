
# load packages and scripts
source("J:/EEG data/EEG_R/start.R")

# Use this to import those stupid cvs
imp <- import_ale(choose.dir())


# Use this to import from database
# # imp <-  import_sqltb(dbp = "J:/EEG data/EEG_R/my-db.sqlite", tab = "cocaine")
# setwd(choose.dir())


list2env(imp, .GlobalEnv )






# alleeg$subject <- droplevels(alleeg$subject)

#all subject length session =

alleeg2 <-  equal_sub(alleeg, interv = 300)


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Heatmaps ----------------------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

subt <- paste0("doses = ", paste(round(alldoses, 3), collapse = ", "), 
               " mg/kg given every ", injection_int/60, " min" )

seqbreaks <- seq(0, max(alleeg$time_sec/60), by = injection_int/60)


by(alleeg2, alleeg2$subject, fheatmap, subt = subt, seqbreaks = seqbreaks)  
  
#------------------------------------------------------------------------

# alleeg2 <- remcorr2(alleeg2)


nl_alleeg2 <- no_lateral(dat = alleeg2) 



freq <-   c(4,8,13,30,50)


 # point_graph2(df = as.data.frame(fgperc_eeg[4]),  yaes = "PSD_abs", lerr= "Abs_SER", sp= "A", subt2 = subt, sel = "Bands", seqbreaks = seqbreaks)
# point_graph2(df = fgperc_eeg,  yaes = "Mean_abs", lerr= "Abs_SER", sp= "A", subt2 = subt, sel = "Bands", seqbreaks = seqbreaks)


# Create intervals of bands and time on list of dataframe depending on freq
fsmeans_eeg <- mapply(mean_bands, list(alleeg2, alleeg2, nl_alleeg2, nl_alleeg2),
                      rep(c(60, 300),2), 
                      rep(list(freq), 4),
                      SIMPLIFY = FALSE
                      )


#Percent baseline by subject
fsperc_eeg  <- lapply(fsmeans_eeg, percent_baseline, 
                      groupby = c ("Bands", "channel", "subject"),
                      basel = "drug_dose", variab = "PSD_abs", 
                      namen = "PSD_perc", 
                      oper = "PSD_abs/baseline*100" )


# plots allsubj abs
lapply(fsperc_eeg, point_graph2_s,
       yaes = "PSD_abs",
       lerr= "PSD_abs_SER",
       sp= "A",
       subt2 = subt,
       sel = "Bands",
       seqbreaks = seqbreaks
       )

 # names(as.data.frame(fgperc_eeg[1]))


# plots allsubj perc
lapply(fsperc_eeg, point_graph2_s,
       yaes = "PSD_perc",
       perc = "yes",
       sp= "A",
       subt2 = subt,
       sel = "Bands",
       seqbreaks = seqbreaks
)


fgperc_eeg  <- lapply(fsperc_eeg,  group_mean )


# plots all group mean perc
lapply(fgperc_eeg, point_graph2,
       yaes = "PSD_perc",
       lerr= "PSD_perc_SER",
       perc = "yes",
       sp= "A",
       subt2 = subt,
       sel = "Bands",
       seqbreaks = seqbreaks
)


# plots all group mean abs
lapply(fgperc_eeg, point_graph2,
       yaes = "PSD_abs",
       lerr= "PSD_abs_SER",
       sp= "A",
       subt2 = subt,
       sel = "Bands",
       seqbreaks = seqbreaks
)


# plots all group mean jitter
lapply(fsperc_eeg, jitterplot,
       yaes = "PSD_perc",
       perc = "yes",
       sp= "A",
       subt2 = subt,
       sel = "Bands",
       seqbreaks = seqbreaks
)

   