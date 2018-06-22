<<<<<<< HEAD
# load packages and scripts
# few comands to subset the database and take the data used for 
# Prism dose-effect curves


source("J:/EEG data/EEG_R/script_start.R")

tbdrug <-    "methylphenidate"

# What to take ---------------
# 3 for 60s, 4 for 300s

binsec <- 4

# first interval to take, last interval and interinterval time in min
int <- seq(10, 60, 10) * 60

int




# Use this to import from database
imp <-  import_sqltb(dbp = "J:/EEG data/EEG_R/my-db.sqlite", tab = tbdrug)



list2env(imp, .GlobalEnv )


# setwd( "J:\\EEG data\\Claudio output files\\for prism")
alleeg2 <- na.omit(alleeg)

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
forprismg  <- as.data.frame(fgperc_eeg[binsec])

forprisms  <- as.data.frame(fsperc_eeg [binsec])




prism <- forprisms %>% 
          dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int & Bands ==  "Beta")


prismg <- forprismg %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int & Bands ==  "Beta")


plot(prismg$intervals_sec, prismg$PSD_perc, type = "p")

prismg <- forprismg %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int)

# setwd("J:\\EEG data\\Claudio output files\\for prism")

write.csv(prismg , file = paste0("J:\\EEG data\\Claudio output files\\for prism\\PSD1\\", tbdrug, "_prism.csv"))



=======
# load packages and scripts
# few comands to subset the database and take the data used for 
# Prism dose-effect curves


source("J:/EEG data/EEG_R/script_start.R")
source("/Users/NCCU/Documents/EEG_R/script_start.R")


tbdrug <-    "methylphenidate"

# What to take ---------------
# 3 for 60s, 4 for 300s

binsec <- 4

# first interval to take, last interval and interinterval time in min
int <- seq(10, 60, 10) * 60

int




# Use this to import from database
# imp <-  import_sqltb(dbp = "J:/EEG data/EEG_R/my-db.sqlite", tab = tbdrug)
imp <-  import_sqltb(dbp = "/Users/NCCU/Documents/EEG_R/PSD1.sqlite", tab = tbdrug)



list2env(imp, .GlobalEnv )


# setwd( "J:\\EEG data\\Claudio output files\\for prism")
alleeg2 <- na.omit(alleeg)

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
forprismg  <- as.data.frame(fgperc_eeg[binsec])

forprisms  <- as.data.frame(fsperc_eeg [binsec])




prism <- forprisms %>% 
          dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int & Bands ==  "Beta")


prismg <- forprismg %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int & Bands ==  "Beta")


plot(prismg$intervals_sec, prismg$PSD_perc, type = "p")

prismg <- forprismg %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int)

# setwd("J:\\EEG data\\Claudio output files\\for prism")

write.csv(prismg , file = paste0("J:\\EEG data\\Claudio output files\\for prism\\PSD1\\", tbdrug, "_prism.csv"))



>>>>>>> 91c25638d0d8ba66ac1d314af2c666b49f434269
