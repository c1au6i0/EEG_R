# load packages and scripts
# few comands to subset the database and take the data used for Prism dose-effect curves
######ATTENTION NEEDS TO BE DEBUGGED#####################

source("J:/EEG data/EEG_R/start.R")

# Use this to import from database
imp <-  import_sqltb(dbp = "J:/EEG data/EEG_R/my-db.sqlite", tab = "JHW007")



list2env(imp, .GlobalEnv )


# setwd( "J:\\EEG data\\Claudio output files\\for prism")

alleeg2 <-  equal_sub(alleeg, interv = 300)

nl_alleeg2 <- no_lateral(dat = alleeg2) 

freq <-   c(4,8,13,30,50)

fsmeans_eeg <- mean_bands(dat = nl_alleeg2, interv = 60, freq = freq)

fsperc_eeg  <- percent_baseline(
                        df = fsmeans_eeg,
                        groupby = c ("Bands", "channel", "subject"),
                        basel = "drug_dose", variab = "PSD_abs", 
                        namen = "PSD_perc", 
                        oper = "PSD_abs/baseline*100" 
                        )
fgperc_eeg  <- as.data.frame(group_mean(fsperc_eeg))

int <- seq(30, 120, 30) * 60
           
           
JHW007_prism <- fgperc_eeg %>% 
          dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int)

setwd(choose.dir())

write.csv(JHW007_prism, file = "JHW007_prism.csv")

rm(alleeg)
