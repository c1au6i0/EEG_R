
fsmeans_eeg$drug_dose

baseline_eeg <- subset(fsmeans_eeg , drug_dose == "baseline" )




unique(baseline_eeg$drug_dose)
mean_baseline <- by(baseline_eeg, baseline_eeg$subject, function(x) mean(x$Mean_PSD))

mean_baseline <- baseline_eeg  %>%
  group_by_(.dots = c(sel,  "channel", "subject" ) ) %>%
  dplyr::summarise(  Mean_PSD = mean(Mean_PSD) )

baseline_eeg  %>%
  arrange(.dots = c(sel,  "channel", "subject" ) )


# mean_baseline <- aggregate(baseline_eeg[,"Mean_PSD",drop=F], baseline_eeg[, c( paste(sel),"channel", "subject" )], mean)



names(baseline_eeg)







# prova <- as.list(prova)
# 
# 
# 
# #percentage
# pcfsmeans_eeg <- subset(fsmeans_eeg, drug_dose != "baseline")
# 
# 
# 
# x = "RAT06"
# 
# by (pcfsmeans_eeg, pcfsmeans_eeg$subject, function (x)  x$Mean_PSD/as.numeric(prova[ x$subject[1] ])  )
# 
# 
# 
# 
# pcfsmeans_eeg %>% arrange(subject)  ->  pcfsmeans_eeg
# subjobs<- table(pcfsmeans_eeg$subject)
# 
# 
# prova2<- rep(prova, subjobs)
# 
# length (prova2[prova2 == "RAT06"])
