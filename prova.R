#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Calculate percentage change froma baseline---------------
#
# %>% data.drame()  http://bit.ly/2m3dkDi
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



mean_baseline <- subset(fsmeans_eeg , drug_dose == "baseline" )  %>%
  group_by_(.dots = c(as.character(sel),  "channel", "subject" ) ) %>%
  dplyr::summarise(  Mean_PSD = mean(Mean_PSD) ) %>%   data.frame()

levelsort <- function(x) {
  factor(   x, levels =   sort(as.character(levels(x))) )
} 

lisf<- list(as.character(sel),  "channel", "subject" )
for (x in lisf) mean_baseline[, as.character(x)] <- levelsort( mean_baseline[, as.character(x)])

mean_baseline <-  dplyr::arrange_(data.frame(ungroup(mean_baseline)), .dots = c(as.character(sel),  "channel", "subject" )  )



mean_nobaseline <- as.data.frame(subset(fsmeans_eeg, drug_dose != "baseline"))
obs_nobaseline <- mean_nobaseline   %>%
  group_by_(.dots = c(as.character(sel),  "channel", "subject" ) ) %>%
  dplyr::summarise(  Observ = n() ) %>%   data.frame()


for (x in lisf) obs_nobaseline[, as.character(x)] <- levelsort( obs_nobaseline[, as.character(x)])
for (x in lisf) mean_nobaseline[, as.character(x)] <- levelsort( mean_nobaseline[, as.character(x)])


obs_nobaseline <-  dplyr::arrange_(data.frame(ungroup(obs_nobaseline)), .dots = c(as.character(sel),  "channel", "subject" )  )
mean_nobaseline <-  dplyr::arrange_(data.frame(ungroup(mean_nobaseline)), .dots = c(as.character(sel),  "channel", "subject" )  )


names(mean_nobaseline)
                
                
mean_nobaseline[, "baseline_PSD"] <- rep(mean_baseline$Mean_PSD, obs_nobaseline$Observ)
mean_nobaseline[, "Percent_baseline"] <- mean_nobaseline$Mean_PSD/mean_nobaseline$baseline_PSD*100




prova <- mean_nobaseline  %>%
  group_by_(.dots = c(sel, "intervals_sec", "channel", "drug_dose")) %>%
  dplyr::summarise(  Mean_PSD2 = mean(Percent_baseline), n2 = n(), SD2 = sd( Percent_baseline ), Median_PSD2 = median( Percent_baseline ))

names(prova) <- names(fsmeans_eeg)[names(fsmeans_eeg) != c("subject", "date")]

prova$Bands <- factor( prova$Bands, levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 
point_graph (prova, sp = 1.2)
