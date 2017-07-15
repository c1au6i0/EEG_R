# Script to average data created by Alessandro EEG python script
#




#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Library and user functions ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
to_load  <- list( "colorspace",
                  "DBI",
                  "plyr",
                  "dplyr",
                  "ggplot2",
                  "lazyeval",
                  "magrittr",
                  "packrat",
                  "RSQLite",
                  "scales",
                  "svDialogs",
                  "viridis")


lapply(to_load, require, character.only = TRUE)


setwd("J:/EEG data/EEG_R")
ufunc <- list( "fheatmap.R", 
               "group_mean.R",
               "equal_sub.R",
               "insert_freq.R", 
               "levelsort.R", 
               "mean_bands.R",
               "no_lateral.R",
               "point_graph.R",
               "remcorr.R", 
               "percent_baseline.R" )

sapply(ufunc, source, .GlobalEnv)



# cat("SELECT THE FOLDER THAT CONTAINS THE FILES")
gdir <- choose.dir(caption = "Select folder")
setwd(gdir)    #set the directory
file <- list.files(include.dirs=FALSE)

dirs <- basename(list.dirs())
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv", file)]

file <- file[!file %in% nread]


msgBox(c("Relax...importing the files will take few seconds. PRESS OK "))

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Loop to read all the files ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

for(x in file) {
  eeg <- read.csv( x , header = TRUE, sep = "," )
  eeg$date <- as.character(eeg$date)
  eeg$date <- gsub("/","-", eeg$date) # remove / from date, / can cause problems
  
  if (exists("alleeg")) {
    alleeg <- rbind( alleeg, eeg,row.names=NULL )
  } else {
    alleeg <- eeg
  }
}  


msgBox( paste0(length (file), " files have been imported. PRESS OK") ) 
  
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Save a copy of the original dataset ---------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

alleeg_original <- alleeg



# alleeg <- alleeg_original

alleeg <- na.omit(alleeg)

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Change the name of some variables in alleeg, save unique values and Add a column with the dose of drug received----

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# all names to low cases (Ale be consistent! all or nothing!)

names(alleeg)[ !names(alleeg) %in% c("PSD","Frequency") ] <- tolower( names(alleeg)[ !names(alleeg) %in% c("PSD","Frequency") ] )

# remove Frequencies = 0
alleeg <- subset(alleeg, Frequency > 0)


alleeg <- dplyr::rename(alleeg, time_sec = time )
alleeg <- dplyr::rename(alleeg, injection_int = timeinterval )
alleeg <- dplyr::rename(alleeg, frequency_eeg = Frequency )



# this is to order the facet in the graph
alleeg$channel <- factor( alleeg$channel, levels = c("EEG_FL","EEG_FR", "EEG_PL", "EEG_PR", "EEG_OL", "EEG_OR") ) 


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Some unique values 
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


f_resol <- unique( alleeg$frequency_eeg )[1]  #frequenciesolution
f_max <- max( alleeg$frequency_eeg )
exp_type <- alleeg$experiment[1]

alleeg$date <- as.character(alleeg$date)
alleeg$route <- "iv"


drug <- alleeg$drug[1]

injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#  Add a column with the dose of drug received
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#



# sd0 <- unlist(strsplit(as.character(basename(x)), "_"))
# sd0 <- sd0[ 2: length(sd0) ]
# 
# #this remove the .csv from the last dose
# sd0 [length(sd0)] <- as.numeric( paste( unlist( strsplit(tail(sd0,1), "")) 
#                                         [1 : (length(unlist(strsplit(tail(sd0,1), ""))) - 4)], collapse = "") )
# alldoses <- as.numeric(sd0)
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Do we have a dose file? -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# Looks for a file called call Doses.csv and imports doses

while (!"Doses.csv" %in% list.files(include.dirs=FALSE)) {
  
  msgBox(c("Please create a Doses.csv file that list the doses used separated by commas") )
  
}

alldoses <- scan( "Doses.csv" ,  sep = "," )

alldoses <- as.numeric(alldoses)



# Every dose interval we have a different dose but the first injection was given at baseline interval so:
injection_time <- as.numeric( c( 0, baseline_int, baseline_int + seq_along(alldoses)* injection_int ) )

# Dosing Intervals
alleeg[, "D_interval"] <- cut( alleeg$time_sec, injection_time, labels =  c("baseline", alldoses),  include.lowest = FALSE )
alleeg$D_interval[is.na(alleeg$D_interva)] <- max(alldoses)



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Heatmaps ----------------------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#



subt <- paste0("doses = ", paste(round(alldoses, 3), collapse = ", "), 
               " mg/kg given every ", injection_int/60, " min" )
  
seqbreaks <- seq(0, max(alleeg$time_sec/60), by = injection_int/60)


wdir <- getwd()

res <- dlgMessage( c("Are you interested in heatmaps?"), "yesno" )$res

if (res == "yes") {
  
  msgBox(c("Good, it might take few sec. PRESS OK "))
    
  by(alleeg, alleeg$subject, fheatmap, subt = subt, seqbreaks = seqbreaks)  
  
  msgBox(c("Heatmaps have been created in ",  wdir) ) 

}


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Remove corrupted channel ------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# 
res <- dlgMessage( c("Are there any corrupted channels to remove?"), "yesno" )$res

alleeg <- remcorr(res)


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#HERE SAVE THE DB---------------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
write.csv(alleeg , file = "alleeg.csv" )

# mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")
# dbWriteTable(mydb, "morphineld", alleeg)

loop <- "yes"

while( !exists("loop") ||   loop == "yes" ) {
 
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Interactive section time interval for means  -----------------
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol
  
  interv <- as.numeric(dlgInput( paste0(c("Insert the lenght of the intervals in sec. Injection was given every ", 
                                          injection_int, " sec"), collapse =" " ), 300 )$res)
  
  
  # if the user does not insert any value o value is not multiple of 
  while ( !length(interv)  ||  is.na (interv)  || !is.wholenumber(injection_int/interv)) {
    tree1 <- dlgMessage(paste0(c("You did not insert any value or ", injection_int, " is not a multiple of it.",
                                 " Press Yes to continue"), collapse = ""), "yesno" )$res
    stopifnot ( tree1 ==  "yes" ) 
    interv <- as.numeric(dlgInput( paste0(c("Insert the lenght of the intervals in sec. Injection was given every ", 
                                            injection_int, " sec"), collapse =" " ), 300 )$res)
  }
  
  
  
  interv <- as.numeric(interv)
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Interactive section  frequencies or bands for means -----------------------------------
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  dlgMessage("Are you intrested in bands or particular frequencies?\n PRESS OK TO CHOOSE")$res
  
  bandfreq <-  c("Bands", "Frequencies")
  
  res <- dlgList(bandfreq, multiple = TRUE, title = "Select one")$res
  
  while ( !length(res)) {
    tree1 <- dlgMessage( c("You pressed cancel", "Do you want to go back?"), "yesno" )$res
    stopifnot ( tree1 ==  "yes" ) 
    res <- dlgList(bandfreq, multiple = TRUE, title = "Select one")$res
  }
  
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Calalculate Time intervalsand  Fix some intervals,  bands and freq-----------------
  # this is to avoid that the last interval is just 10 sec or is only 1 subj
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  # alleeg$subject <- droplevels(alleeg$subject)
  
  # max shared length of session...  
  maxtim <- min( by(alleeg, alleeg$subject, function(x) max(x$time_sec)) )
  
  #this alleeg2 is used for the loop
  alleeg2 <- alleeg
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Laterality?  -----------------
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  lr <- dlgMessage(c("Are you interested in differences between Left/Right electrodes?"), "yesno" )$res
  
  
  
  if (lr == "no") {
    
    alleeg2$channel <- plyr::revalue(alleeg2$channel, c("EEG_FL" = "EEG_FRONT", 
                                                        "EEG_FR" = "EEG_FRONT",
                                                        "EEG_PL" = "EEG_PARIE",
                                                        "EEG_PR" = "EEG_PARIE",
                                                        "EEG_OL" = "EEG_OCCIP",
                                                        "EEG_OR" = "EEG_OCCIP"))
    
  }
  
  
  if (lr == "yes") lat <- "lat" else lat <- "nolat"
  
  
  
  alleeg2 <- dplyr::filter( alleeg2, time_sec  <=  floor(maxtim/injection_int)*injection_int)
  
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Calculate intervals  -----------------
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  
  # Intervals used for the mean  -> mean_intervals (+1 so it does not start from 0)
  
  alleeg2[, "M_interval"] <- as.numeric(findInterval(alleeg2$time_sec, 
                                                    as.numeric(seq(interv, max(alleeg2$time_sec), interv), left.open = TRUE)) ) + 1
  
  
  
  freq <- insert_freq(res)
  
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
  # Percent baseline function
  # df = dataframe
  # groupby = list of columns/factors by which calculate operation
  # basel = column that contains multiple factors one of which is called "baseline"
  # variab = column containing  the continous variable to apply the func
  # namen = name of the new created column with the fourmula.
  #  form = formula to summarize the baseline, default is mean
  # oper = formula to use to expresse variab as function of baseline express in baseline (/*-+) Mean_PSD or viceversa. 
  #       neads to contain colnames that are present
  
  fsperc_eeg <- percent_baseline(df = fsmeans_eeg, groupby = c ("Bands", "channel", "subject") , basel = "drug_dose", variab = "Mean_PSD", 
                                            namen = "Percent_baseline", oper = "Mean_PSD/baseline*100")
  
  ##########ADD HERE FORMULAS FOR OTHER --------------------------------
  
  # if I call it Percent_baseline it fucks everything up
  fgperc_eeg <- fsperc_eeg  %>%
    group_by_(.dots = c(sel, "intervals_sec", "channel", "drug_dose", "drug")) %>%
    dplyr::summarise(  Percent_baseline2 = mean(Percent_baseline), n = n(), SD = sd( Percent_baseline ), Percent_Median_PSD = median( Percent_baseline ))
  
  names(fgperc_eeg)[6] <- "Percent_baseline"


  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # MODIFY creating lapply function -----------------
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

  

  
  for (x in list(fgperc_eeg, fgperc_eeg))  {
    x[, "Bands"]  <-   factor( x[, "Bands"] , levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 
  }
 

  


  write.csv(fgperc_eeg  , file = paste0("fgperc_eeg_",interv, "_sec_",lat,".csv") )
  write.csv(fsperc_eeg  , file = paste0("fsperc_eeg_",interv, "_sec_",lat,".csv") )
  

  
  
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Create and save graphs -----------------
  #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  if (exists("spm")) sp <- spm else sp <- "A"
  
  msgBox(c("Now we make some graphs..it might take few sec. PRESS OK "))
  
  if ( !length(unique(alleeg2$subject)) == 1) {
    point_graph (fmeans_eeg, sp = sp)
    point_graph (fgperc_eeg, perc = "yes", sp = sp)
  }
  
  
  by(fsmeans_eeg, fsmeans_eeg$subject, point_graph, sp = sp)
  by(fsperc_eeg, fsperc_eeg$subject, point_graph, perc = "yes", sp = sp)
  
  
  
  
  msgBox(c("One or multiple point graphs have been created in ",  wdir) )
  
  loop <- dlgMessage(c("Do you want to make more graphs or summary tables?"), "yesno" )$res
  
    if (loop == "yes") {
      msgBox(c("Move outputs to different folder to avoid overwriting. Press OK when done.") )
      symb <- dlgMessage(c("Do you want to change size of the symbols?"), "yesno" )$res
      
      if (symb == "yes") {
        
        while ( !exists("spm") || !length(spm)  ||  is.na (spm) ) {
          
          spm <- as.numeric(dlgInput( paste0(c("Insert size of points")), 1.4 )$res)
          sp <- spm
          
        }
      }
      
    }

}

# rm( list= ls() )


