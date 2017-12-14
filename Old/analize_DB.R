# this is for analysing the data directelly from the database.


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Library and user functions ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
library("colorspace")
library("DBI")
library("plyr")
library("dplyr")
library("ggplot2")
library("magrittr")
library("packrat")
library("RSQLite")
library("scales")
library("svDialogs")
library("viridis")

# mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")
# alleeg <- dbGetQuery(mydb, "SELECT * FROM cocaine")

alleeg$subject <- as.factor(alleeg$subject)
alleeg$channel <- as.factor(alleeg$channel)




setwd("J:/EEG data/EEG_R")
ufunc <- list( "fheatmap.R", "insert_freq.R", "levelsort.R", "point_graph.R", "remcorr.R", "point_graph2.R" )

sapply(ufunc, source, .GlobalEnv)

# cat("SELECT THE FOLDER THAT CONTAINS THE FILES")
gdir <- choose.dir(caption = "Select folder")
setwd(gdir)    #set the directory

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Some unique values and other vectors/lists--------------------------------
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


f_resol <- unique( alleeg$frequency_eeg )[1]  #frequenciesolution
f_max <- max( alleeg$frequency_eeg )
exp_type <- alleeg$experiment[1]

alleeg$date <- as.character(alleeg$date)

alleeg$route <- "iv"

drug <- alleeg$drug[1]

injection_int <- as.numeric( alleeg$injection_int[1] )*60

baseline_int <- as.numeric( alleeg$baseline[1] )*60

alldoses <- scan( "Doses.csv" ,  sep = "," )

subt <- paste0("doses = ", paste(round(alldoses, 3), collapse = ", "), 
               " mg/kg given every ", injection_int/60, " min" )

seqbreaks <- seq(0, max(alleeg$time_sec/60), by = injection_int/60)

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Set interval and band-----------------------------------------------------
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

interv <- as.numeric(60)

res <- "Bands"
# max shared length of session...  
maxtim <- min( by(alleeg, alleeg$subject, function(x) max(x$time_sec)) )

#this alleeg2 is used for the loop
alleeg2 <- alleeg

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# If not intrested in laterality-------------------------------------------
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

lr <- dlgMessage(c("Are you interested in differences between Left/Right electrodes?"), "yesno" )$res



if (lr == "no") {
  
  alleeg2$channel <- plyr::revalue(alleeg2$channel, c("EEG_FL" = "EEG_FRONT", 
                                                      "EEG_FR" = "EEG_FRONT", 
                                                      "EEG_PL" = "EEG_PARIE",
                                                      "EEG_PR" = "EEG_PARIE",
                                                      "EEG_OL" = "EEG_OCCIP",
                                                      "EEG_OR" = "EEG_OCCIP"))
  
}

alleeg2 <- dplyr::filter( alleeg2, time_sec  <=  floor(maxtim/injection_int)*injection_int)


alleeg2[, "M_interval"] <- as.numeric(findInterval(alleeg2$time_sec, 
                                     as.numeric(seq(interv, max(alleeg2$time_sec), interv), left.open = TRUE)) ) + 1



freq <- c(4,8,13,30,50)



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Compute means of bands or frequencies-----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

alleeg2$M_interval <- alleeg2$M_interval * interv



# set subtitle of the graph depending on the choice Bands/Frequencies and make the choice = symbol
if (res == "Bands") {
  blab <-c("Delta", "Theta", "Alpha", "Beta", "Gamma")
  freq <-as.numeric(c(0,freq))
  alleeg2[, "Bands"] <- cut(alleeg2$frequency_eeg,  freq, labels = blab, include.lowest = FALSE)
  sel <- as.symbol("Bands")
  subt2  <- res
  #remove frequencies over upper limit of bands (not necessary is NA are omitted after means)
  alleeg2 <- dplyr::filter( alleeg2, frequency_eeg  <=  max(freq))
}

if (res == "Frequencies") {
  alleeg2 <- subset(alleeg2, frequency_eeg %in% freq)
  sel <- as.symbol("frequency_eeg")
  subt2  <- paste(res, " (Hz)", sep = "")
}


#Final-Subject-means-eeg
fsmeans_eeg <- alleeg2 %>%
  group_by_(.dots = c(sel, "M_interval", "channel", "D_interval", "drug", "date", "subject")) %>%
  dplyr::summarise(  Mean_PSD = mean(PSD), n = n(), SD = sd(PSD), Median_PSD = median(PSD))


fsmeans_eeg <- data.frame(na.omit(fsmeans_eeg))



#Final-means-eeg 
fmeans_eeg <- fsmeans_eeg  %>%
  group_by_(.dots = c(sel, "M_interval", "channel", "D_interval", "drug")) %>%
  dplyr::summarise(  Mean_PSD2 = mean(Mean_PSD), n2 = n(), SD2 = sd( Mean_PSD ), Median_PSD2 = median( Mean_PSD ))


names(fsmeans_eeg) [c(1,2,4)] <- c( paste(sel), "intervals_sec", "drug_dose" )
names(fmeans_eeg) <- names(fsmeans_eeg)[names(fsmeans_eeg) != c("subject", "date")]



fmeans_eeg <- na.omit(fmeans_eeg)



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Calculate percentages -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# Calculate mean of baseline by subject, Channel, Band
baseline_eeg <- subset(fsmeans_eeg, drug_dose == "baseline" )  %>%
  group_by_(.dots = c(as.character(sel),  "channel", "subject" ) ) %>%
  dplyr::summarise(  Mean_PSD = mean(Mean_PSD) ) %>%   data.frame()


# Apply function and sort all factors alphabetically
lisf <- list(as.character(sel),  "channel", "subject" )

for (x in lisf) baseline_eeg[, as.character(x)] <- levelsort( baseline_eeg[, as.character(x)])


# Sort baseline_eeg by sel, channel, subject
baseline_eeg <-  dplyr::arrange_(data.frame(ungroup(baseline_eeg)), .dots = c(as.character(sel),  "channel", "subject" )  )


# Calculate number of observation for each subject, fr/band, channel
obs <- fsmeans_eeg  %>%
  group_by_(.dots = c(as.character(sel),  "channel", "subject" ) ) %>%
  dplyr::summarise(  Observ = n() ) %>%   data.frame()

# Sort the  fsmean_eeg df and observation with same codes
for (x in lisf) obs[, as.character(x)] <- levelsort( obs[, as.character(x)])

for (x in lisf) fsmeans_eeg[, as.character(x)] <- levelsort( fsmeans_eeg[, as.character(x)])

obs <-  dplyr::arrange_(data.frame(ungroup(obs)), .dots = c(as.character(sel),  "channel", "subject" )  )

fsperc_eeg <-  dplyr::arrange_(data.frame(ungroup(fsmeans_eeg)), .dots = c(as.character(sel), 
                                                                           "channel", "subject" )  )

# Repeat baseline values n times depending on number of observations                
fsperc_eeg[, "baseline_PSD"] <- rep(baseline_eeg$Mean_PSD, obs$Observ)

fsperc_eeg[, "Percent_baseline"] <- fsperc_eeg$Mean_PSD/fsperc_eeg$baseline_PSD*100



##########ADD HERE FORMULAS FOR OTHER 

# if I call it Percent_baseline it fucks everything up
fgperc_eeg <- fsperc_eeg  %>%
  group_by_(.dots = c(sel, "intervals_sec", "channel", "drug_dose", "drug")) %>%
  dplyr::summarise(  Percent_baseline2 = mean(Percent_baseline), n = n(), SD = sd( Percent_baseline ), Percent_Median_PSD = median( Percent_baseline ))

names(fgperc_eeg)[6] <- "Percent_baseline"


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# SAVE ON PC -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


fgperc_eeg$Bands <- factor( fgperc_eeg$Bands, levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 
fsperc_eeg$Bands <- factor( fsperc_eeg$Bands, levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 


write.csv(fgperc_eeg  , file = paste0("fgperc_eeg_",interv, "_sec_interv.csv") )
write.csv(fsperc_eeg  , file = paste0("fsperc_eeg_",interv, "_sec_interv.csv") )




#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# graphs -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


if (exists("spm")) sp <- spm else sp <- "A"

msgBox(c("Now we make some graphs..it might take few sec. PRESS OK "))

if ( !length(unique(alleeg2$subject)) == 1) {
  point_graph (fmeans_eeg, sp = sp)
  point_graph (fgperc_eeg, perc = "yes", sp = sp)
}


by(fsmeans_eeg, fsmeans_eeg$subject, point_graph, sp = sp)
by(fsperc_eeg, fsperc_eeg$subject, point_graph, perc = "yes", sp = sp)

