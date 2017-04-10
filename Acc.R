# Script to average data created by Alessandro EEG python script
#




#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Library and user functions ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
library("colorspace")
library("cowplot")
library("plyr")
library("dplyr")
library("ggplot2")
library("magrittr")
library("packrat")
library("scales")
library("svDialogs")
library("viridis")
library("pracma")


# setwd("i:/EEG data/EEG_R")

setwd("J:/EEG data/EEG_R")
ufunc <- list( "fheatmap.R", "insert_freq.R", "levelsort.R", "point_graph.R", "remcorr.R" )

sapply(ufunc, source, .GlobalEnv)



# cat("SELECT THE FOLDER THAT CONTAINS THE FILES")
setwd( choose.dir(caption = "Select folder") )    #set the directory
file <- list.files(include.dirs=FALSE)

dirs <- basename(list.dirs())
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|*pzf|Doses.csv", file)]

file <- file[!file %in% nread]

msgBox(c("Relax...importing the files will take few seconds. PRESS OK "))

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Loop to read all the files ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

for(x in file) {
  eeg <- read.csv( x , header = TRUE, sep = "," )
  
  # 
  # if (exists("alleeg")) {
  #   alleeg <- rbind( alleeg, eeg,row.names=NULL )
  # } else {
  alleeg <- eeg
#   }
# }  




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



alleeg <- rename(alleeg, time_sec = time )
alleeg <- rename(alleeg, injection_int = timeinterval )



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Some unique values 
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

exp_type <- alleeg$experiment[1]
alleeg$date <- as.character(alleeg$date)
alleeg$route <- "iv"


drug <- alleeg$drug[1]

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#  Add a column with the dose of drug received
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# CHECK: ADD PART TO VERIFY DOSES FILE -----------------
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
#Graph ----------------------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

gtitle <- paste0( alleeg$date[1]," ",  alleeg$subject[1], " ", drug, " doses = ", paste(round(alldoses, 3), collapse = ", "), 
                  " mgkg ", injection_int/60, " min.pdf" ) 
subt <- paste0( )

seqbreaks <- seq(0, max(alleeg$time_sec/60), by = injection_int/60)



p1 <- ggplot(alleeg, aes(time_sec/60, mean_acc_modulus)) +
  geom_line() +
  geom_smooth(method = "lm") +
  labs(x = "",
       y = "",
       title = ""
  ) +
  scale_x_continuous( expand = c(0,0), breaks = seqbreaks ) 


p2 <- ggplot(alleeg, aes(time_sec/60, acc_x)) +
  geom_line() +
  geom_smooth(method = "lm") +
  labs(x = "",
       y = "",
       title = ""
  ) +
  scale_x_continuous( expand = c(0,0), breaks = seqbreaks ) 


p3 <- ggplot(alleeg, aes(time_sec/60, acc_y)) +
  geom_line() +
  geom_smooth(method = "lm") +
  labs(x = "Time (min)",
       y = "",
       title = ""
  ) +
  scale_x_continuous( expand = c(0,0), breaks = seqbreaks ) 


p4 <- ggplot(alleeg, aes(time_sec/60, acc_z)) +
  geom_line() +
  geom_smooth(method = "lm") +
  labs(x = "Time (min)",
       y = "",
       title = ""
  ) +
  scale_x_continuous( expand = c(0,0), breaks = seqbreaks ) 


lab <- c("Mean acc Modulus", "         Acc_x", "         Acc_y","         Acc_z")

allACC <- plot_grid(p1,p2,p3,p4, labels = lab, hjust = -0.5)
save_plot(filename = gtitle, allACC, base_aspect_ratio = 2.1)
 

evenint <- as.numeric( (length(alldoses) + 1) * injection_int)

alleeg_acc <- subset( alleeg, alleeg$time_sec <= evenint   )

n_obs <- by(data = alleeg_acc, INDICES = alleeg_acc$D_interval,  function (x) length(x$mean_acc_modulus) )

n_events <- by(data = alleeg_acc, INDICES = alleeg_acc$D_interval,  
               function (x) nrow(findpeaks(x$mean_acc_modulus)))

n_events <-  do.call(rbind, as.list(n_events) )

n_events

write.csv(n_events, file = "n_events.csv" )

}


as.numeric( (length(alldoses) + 1) * injection_int )

