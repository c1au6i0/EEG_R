# load packages and scripts
# few comands to subset the database and take the data used for 
# Prism dose-effect curves


source("J:/EEG data/EEG_R/script_start.R")

# Use this to import from database
imp <-  import_sqltb(dbp = "J:/EEG data/EEG_R/my-db.sqlite", tab = "cocaine")



list2env(imp, .GlobalEnv )


# setwd( "J:\\EEG data\\Claudio output files\\for prism")


# Means##################################################
alleeg2 <-  equal_sub(alleeg, interv = 300)


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

fgperc_eeg  <- pblapply(fsperc_eeg, chan_group_mean )





#########################################################



#3 for 60 sec, 4 for 300s, 
forprismg  <- as.data.frame(fgperc_eeg[4])

forprisms  <- as.data.frame(fsperc_eeg [4])


# first interval to take, last interval and interinterval time in min
int <- seq(10, 50, 10) * 60
      
int

prism <- forprisms %>% 
          dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int & Bands == "Beta")


prismg <- forprismg %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int & Bands == "Delta")


# plot(prism$intervals_sec, prism$PSD_perc)

# setwd("J:\\EEG data\\Claudio output files\\for prism")

# write.csv(saline_prism , file = "saline_prism.csv")

# prova <- prism %>% 
  # select(UQ(c("subject", "Bands","intervals_sec", "drug_dose", "PSD_perc"))) %>%
  # spread(subject, PSD_perc)

# fitprova <- aov(PSD_perc~drug_dose +Error(subject/drug_dose),data=prism)
# summary(fitprova)


