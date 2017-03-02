#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Calculate percentage change froma baseline---------------
#
# %>% data.drame()  http://bit.ly/2m3dkDi
# needs fsmeans_eeg
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



# Calculate mean of baseline by subject, Channel, Band
baseline_eeg <- subset(fsmeans_eeg, drug_dose == "baseline" )  %>%
  group_by_(.dots = c(as.character(sel),  "channel", "subject" ) ) %>%
  dplyr::summarise(  Mean_PSD = mean(Mean_PSD) ) %>%   data.frame()

# Apply function and sort all factors alphabetically
lisf<- list(as.character(sel),  "channel", "subject" )
for (x in lisf) baseline_eeg[, as.character(x)] <- levelsort( baseline_eeg[, as.character(x)])



# Sort baseline_eeg by sel, channel, subject
baseline_eeg <-  dplyr::arrange_(data.frame(ungroup(baseline_eeg)), .dots = c(as.character(sel),  "channel", "subject" )  )





# Calculate number of observation for each subject, fr/bandm, channel
obs <- fsmeans_eeg  %>%
  group_by_(.dots = c(as.character(sel),  "channel", "subject" ) ) %>%
  dplyr::summarise(  Observ = n() ) %>%   data.frame()

# Sort the  fsmean_eeg df and observation with same codes
for (x in lisf) obs[, as.character(x)] <- levelsort( obs[, as.character(x)])
for (x in lisf) fsmeans_eeg[, as.character(x)] <- levelsort( fsmeans_eeg[, as.character(x)])
obs <-  dplyr::arrange_(data.frame(ungroup(obs)), .dots = c(as.character(sel),  "channel", "subject" )  )
fsperc_eeg <-  dplyr::arrange_(data.frame(ungroup(fsmeans_eeg)), .dots = c(as.character(sel),  "channel", "subject" )  )






# Repeat baseline values n times depending on number of observations                
fsperc_eeg[, "baseline_PSD"] <- rep(baseline_eeg$Mean_PSD, obs$Observ)
fsperc_eeg[, "Percent_baseline"] <- fsperc_eeg$Mean_PSD/fsperc_eeg$baseline_PSD*100




fgperc_eeg <- fsperc_eeg  %>%
  group_by_(.dots = c(sel, "intervals_sec", "channel", "drug_dose")) %>%
  dplyr::summarise(  Mean_PSD2 = mean(Percent_baseline), n2 = n(), SD2 = sd( Percent_baseline ), Median_PSD2 = median( Percent_baseline ))

names(fgperc_eeg) <- names(fsmeans_eeg)[names(fsmeans_eeg) != c("subject", "date")]


fgperc_eeg$Bands <- factor( fgperc_eeg$Bands, levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 
fsperc_eeg$Bands <- factor( fgperc_eeg$Bands, levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 





