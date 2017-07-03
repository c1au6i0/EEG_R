
#all subject length session =

alleeg2 <-  equal_sub(alleeg)


# use: alleeg2 <- no_lateral(dat = alleeg2)


fsmeans_eeg  <- mean_bands(dat = alleeg2, interv = "300",  freq =  c(4,8,13,30,50)) 


fsperc_eeg <- percent_baseline(df = fsmeans_eeg, groupby = c ("Bands", "channel", "subject") , basel = "drug_dose", variab = "Mean_PSD", 
                               namen = "Percent_baseline", oper = "Mean_PSD/baseline*100")


fgperc_eeg <-  group_mean(dat = fsperc_eeg , variab = Percent_baseline, namen = "Percent_baseline")


x <-  lapply(c(300, 600), mean_bands, dat = alleeg2, freq =  c(4,8,13,30,50))


str(x)

names(x) <- c("a","b")
list2env(x, .GlobalEnv)
