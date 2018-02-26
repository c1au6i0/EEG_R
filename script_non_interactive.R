# Comands to create graphs...
#

# load packages and scripts
source("J:/EEG data/EEG_R/script_start.R")

# Use this to import those stupid cvs
imp <- import_ale(choose.dir())


# Use this to import from database
# imp <-  import_sqltb(dbp = "J:/EEG data/EEG_R/my-db.sqlite", tab = "methylphenidate")

# setwd(choose.dir())



list2env(imp, .GlobalEnv )

# alleeg$route <- "iv"
alleeg$subject <- droplevels(alleeg$subject)



alleeg2 <-  equal_sub(alleeg, interv = 300)


alleeg2 <- na.omit(alleeg2)

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




# Create intervals of bands and time on list of dataframe depending on freq
fsmeans_eeg <- mapply(mean_bands, list(alleeg2, alleeg2, nl_alleeg2, nl_alleeg2),
                      rep(c(60, 300),2), 
                      rep(list(freq), 4),
                      SIMPLIFY = FALSE
)


#Percent baseline by subject
fsperc_eeg  <- lapply(fsmeans_eeg[1:2], percent_baseline, 
                      groupby = c("Bands", "channel", "subject"),
                      basel = "drug_dose", variab = "PSD_abs", 
                      namen = "PSD_perc", 
                      oper = "PSD_abs/baseline*100" )


# Percent no laterality by single channel

fsperc_eeg_nlat <- lapply(fsperc_eeg ,  no_lateral)

fsperc_eeg_nlat <- lapply(fsperc_eeg_nlat, chan_group_mean,
              groupby = c("Bands", "intervals_sec", "channel", "drug_dose", "drug", "date", "subject")
              )

fsperc_eeg <- append(fsperc_eeg, fsperc_eeg_nlat)

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


fgperc_eeg  <- pblapply(fsperc_eeg, chan_group_mean )


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

# plots all group mean jitter
lapply(fsperc_eeg, jitterplot,
       yaes = "PSD_abs",
       perc = "no",
       sp= "A",
       subt2 = subt,
       sel = "Bands",
       seqbreaks = seqbreaks
)

