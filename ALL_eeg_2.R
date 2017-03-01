# Script to average data created by Alessandro EEG python script
#

library("colorspace")
library("plyr")
library("dplyr")
library("ggplot2")
library("magrittr")
library("packrat")
library("scales")
library("svDialogs")
library("viridis")


# cat("SELECT THE FOLDER THAT CONTAINS THE FILES")
setwd( choose.dir(caption = "Select folder") )    #set the directory
file <- list.files(include.dirs=FALSE)

dirs <- basename(list.dirs())
file <- file[!file %in% dirs]
link <- file[grepl(paste ("*","lnk", sep=""), file )]
file <- file[!file %in% link]



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Loop to read all the files ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

for(x in file) {
  eeg <- read.csv( x , header = TRUE, sep = "," )
  
  
  if (exists("alleeg")) {
    alleeg <- rbind( alleeg, eeg,row.names=NULL )
  } else {
    alleeg <- eeg
  }
}  


msgBox( paste0(length (file), " files have been imported") ) 
  
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

alleeg <- rename(alleeg, time_sec = time )
alleeg <- rename(alleeg, injection_int = timeinterval )
alleeg <- rename(alleeg, frequency_eeg = Frequency )



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

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#  Add a column with the dose of drug received
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60


sd0 <- unlist(strsplit(as.character(basename(x)), "_"))
sd0 <- sd0[ 2: length(sd0) ]

#this remove the .csv from the last dose
sd0 [length(sd0)] <- as.numeric( paste( unlist( strsplit(tail(sd0,1), "")) 
                                        [1 : (length(unlist(strsplit(tail(sd0,1), ""))) - 4)], collapse = "") )
alldoses <- as.numeric(sd0)



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

# function that creates heatmap  

fheatmap <- function (x) { 
  gtitle <- paste0( x$date[1]," ",  x$subject[1], " ", drug ) 
  grapheat <-
  ggplot(x, aes(time_sec/60, frequency_eeg)) +
   geom_raster(aes(fill = PSD )) +
   facet_wrap(~ channel, ncol = 2) +
   scale_fill_viridis()+
   labs(x = "Time (min)",
        y = "Frequency (Hz)",
        fill = "Power (db)",
        title = paste(gtitle),
        subtitle = paste(subt)) +
   scale_x_continuous( expand = c(0,0), breaks = seqbreaks ) +
   scale_y_continuous( expand = c(0,0) ) +
   theme( plot.subtitle = element_text(hjust = 0.5),
     plot.caption = element_text(vjust = 1),
     plot.title = element_text(hjust = 0.5) )

  ggsave(filename = paste("heatmap ", gtitle, ".pdf", sep =""), plot = grapheat, device = "pdf",  width = 11, height = 8.5)
}

wdir <- getwd()

  
by(alleeg, alleeg$subject, fheatmap)  

msgBox(c("Heatmaps have been created in ",  wdir) ) 


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Remove corrupted channel ------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


# Need to add interactive part

alleeg <- alleeg  [-c( which( alleeg$subject == "RAT06" & alleeg$channel == "EEG_OR")),]
alleeg <- alleeg  [-c( which( alleeg$subject == "RAT08" & alleeg$channel == "EEG_FR")),]
alleeg <- alleeg  [-c( which( alleeg$subject == "RAT08" & alleeg$channel == "EEG_PR")),]

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

dlgMessage("Are you intrested in bands or particular frequencies?\n PRESS OK TO CHOOSE")$res

bandfreq <-  c("Bands", "Frequencies")

res <- dlgList(bandfreq, multiple = TRUE, title = "Select one")$res

while ( !length(res)) {
  tree1 <- dlgMessage( c("You pressed cancel", "Do you want to go back?"), "yesno" )$res
  stopifnot ( tree1 ==  "yes" ) 
  res <- dlgList(bandfreq, multiple = TRUE, title = "Select one")$res
}



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Function for Interactive session to indicate frequencies or bands for means -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# fb band of frequency


insert_freq <- function(fb) {
  
  banddef<-"4,8,13,30,50"
  fdef<-"10,20,30,40"
  
  # Depending of the choice frequency/bands the message changes
  
  if (fb == "Bands") {
    msg <- "Insert upper limit of  Del, Thet, Alp, Bet, Gam  bands sep by ,. Resol = "
    def_ch <- banddef
  }
  
  if (fb == "Frequencies") {
    msg <- "Insert the frequencies of interest separated by comma. Resolution is "
    def_ch <- fdef
  }
  
  
  freq <- dlgInput( paste( msg, f_resol, 
                           " and max is ", f_max, sep = ""), paste(def_ch))$res  
  
  freq <- as.numeric(unlist(strsplit(freq, ","))) 
  
  #Loops if frequencies inserted are not present or the user pressed cancel
  
  while(sum(as.numeric(freq %in% alleeg$frequency_eeg)) != length (freq) | !length(freq)) {
    
    tree1 <- dlgMessage(c("You pressed cancell or inserted one or more frequencies that are not present",
                          "Do you want to go back?"), "yesno" )$res
    
    stopifnot ( tree1 ==  "yes" ) 
    
    freq <- dlgInput( paste( msg, f_resol, 
                             " and max is ", f_max, sep = ""), paste(def_ch))$res  
    
    freq <- as.numeric(unlist(strsplit(freq, ",")))
  }
  
  return(freq)  
}



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Fix some intervals,  bands and freq, and calalculate Time intervals -----------------
# this is to avoid that the last interval is just 10 sec or is only 1 subj
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# max shared length of session...  
maxtim <- min( by(alleeg, alleeg$subject, function(x) max(x$time_sec)) )

alleeg <- dplyr::filter( alleeg, time_sec  <=  floor(maxtim/injection_int)*injection_int)




# Intervals used for the mean  -> mean_intervals (+1 so it does not start from 0)

alleeg[, "M_interval"] <- as.numeric(findInterval(alleeg$time_sec, 
                                                  as.numeric(seq(interv, max(alleeg$time_sec), interv), left.open = TRUE)) ) + 1



freq <- insert_freq(res)

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Compute means of bands or frequencies-----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

alleeg$M_interval <- alleeg$M_interval * interv

write.csv(alleeg, file = paste0("alleeg_",interv, "_sec_interv.csv") )

# set subtitle of the graph depending on the choice Bands/Frequencies and make the choice = symbol
if (res == "Bands") {
  blab <-c("Delta", "Theta", "Alpha", "Beta", "Gamma")
  freq <-as.numeric(c(0,freq))
  alleeg[, "Bands"] <- cut(alleeg$frequency_eeg,  freq, labels = blab, include.lowest = FALSE)
  sel <- as.symbol("Bands")
  subt2  <- res
  #remove frequencies over upper limit of bands (not necessary is NA are omitted after means)
  alleeg <- dplyr::filter( alleeg, frequency_eeg  <=  max(freq))
}

if (res == "Frequencies") {
  alleeg <- subset(alleeg, frequency_eeg %in% freq)
  sel <- as.symbol("frequency_eeg")
  subt2  <- paste(res, " (Hz)", sep = "")
}


#Final-Subject-means-eeg
fsmeans_eeg <- alleeg %>%
  group_by_(.dots = c(sel, "M_interval", "channel", "D_interval", "subject", "date" )) %>%
  dplyr::summarise(  Mean_PSD = mean(PSD), n = n(), SD = sd(PSD), Median_PSD = median(PSD))


fsmeans_eeg <- na.omit(fsmeans_eeg)

names(alleeg)

#Final-means-eeg does not work
fmeans_eeg <- fsmeans_eeg  %>%
  group_by_(.dots = c(sel, "M_interval", "channel", "D_interval")) %>%
  dplyr::summarise(  Mean_PSD2 = mean(Mean_PSD), n2 = n(), SD2 = sd( Mean_PSD ), Median_PSD2 = median( Mean_PSD ))


names(fsmeans_eeg) [c(1,2,4)] <- c( paste(sel), "intervals_sec", "drug_dose" )
names(fmeans_eeg) <- names(fsmeans_eeg)[names(fsmeans_eeg) != c("subject", "date")]



fmeans_eeg <- na.omit(fmeans_eeg)

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Graph function -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
point_graph <- function(x, sp) {
  
  #sp size points
  if (missing(sp)) {  sp <- (max(x$intervals_sec) / interv) / 18 }
  
  csp <-  sp + sp/2
  
  
  lx <- c(0 - min(x$intervals_sec/60), max(x$intervals_sec/60) + min(x$intervals_sec/60))
  lerr <- aes(ymax = Mean_PSD + SD/sqrt(n), ymin= Mean_PSD - SD/sqrt(n))
  
  # breaks axis
  yseqbreaks <- seq(0, max(x$Mean_PSD)+10, by = 5)
  
  #title changes depending on subject/ group
  if ("subject" %in% names(x) ) {
    gtitle <- paste0( x$date[1]," ",  x$subject[1], " ", drug )
  } else {
    gtitle <- paste0(drug, " group means")
    
  }
  
  
  mean_point <-
    ggplot(x, aes(intervals_sec/60, Mean_PSD,  colour = drug_dose)) +
    geom_line(colour = "grey20") +
    geom_errorbar(lerr, colour = "grey20") +
    geom_point(size = csp, colour = "grey20", show.legend = TRUE) + 
    geom_point(size = sp) +
    scale_color_brewer(palette = "Set1") +
    facet_grid(as.formula(paste(sel,"~","channel")), scales = "free_y") +
    scale_x_continuous( expand = c(0,0), breaks = seqbreaks, limits = lx  ) +
    # scale_y_continuous( expand = c(0,0), breaks = seq(0, max(x$Mean_PSD)+10, by = 5),
    #                     limits = c(0, max(x$Mean_PSD)+10 )) +
    labs(x = "Time (min)", 
         y = " mean PSD (dB) and St.Err", 
         colour = "Dose (mg/kg)", 
         element_text(face = "bold"),
         title = gtitle,
         subtitle = paste0("Channels ", "X ",   subt2 )
    ) +
    theme(
      strip.background  = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(face = "bold", hjust = 0.5),
      legend.key = element_blank(),
      legend.title = element_text(face = "bold", hjust = 0.5),
      legend.background = element_rect ( color = "grey20"),
      strip.text = element_text(size=8, face = "bold"), 
      axis.text = element_text(size = 6, face = "bold")
      # plot.caption = element_text(vjust = 1), 
      # panel.grid.major = element_line(colour = "gray93"), 
      # panel.grid.minor = element_line(colour = "gray93"), 
      # panel.background = element_rect(fill = "white")
    )
  
  ggsave(filename = paste0(gtitle, "_", interv, "_sec_interv.pdf"), plot = mean_point, device = "pdf",  width = 11, height = 8.5)
  
  
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Create and save graphs -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

point_graph (fmeans_eeg, sp = 1.2)

by(fsmeans_eeg, fsmeans_eeg$subject, point_graph, sp = 1.2)


msgBox(c("One or multiple point graphs have been created in ",  wdir) )





