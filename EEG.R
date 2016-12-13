# Script to average data created by Alessandro EEG python script
#
# Variables 
# freq   =  frequencies of interest
# interv = interval of intereset
# res = Bands or Frequencies
# tree1 = yesno : go back and insert interval tyueyet

library("colorspace")
library("plyr")
library("dplyr")
library("ggplot2")
library("magrittr")
library("packrat")
library("scales")
library("svDialogs")
library("viridis")


original <- read.csv( dlgOpen(title = "Select the csv file")$res, header = TRUE, sep = "," )


eeg <- original
eeg <- na.omit(eeg)

#all names to low cases (Ale be consistent! all or nothing!)

names(eeg)[ !names(eeg) %in% c("PSD","Frequency") ] <- tolower( names(eeg)[ !names(eeg) %in% c("PSD","Frequency") ] )

#remove Frequencies = 0
eeg <- subset(eeg, Frequency > 0)

###########################################
# Fix some column names and get some info #
###########################################

eeg <- rename(eeg, time_sec = time )
eeg <- rename(eeg, injection_int = timeinterval )
eeg <- rename(eeg, frequency_eeg = Frequency )



# this is to order the facet in the graph
eeg$channel <- factor( eeg$channel, levels = c("EEG_FL","EEG_FR", "EEG_PL", "EEG_PR", "EEG_OL", "EEG_OR") ) 

subj <- eeg$subject[1]
f_resol <- unique( eeg$frequency_eeg )[1]  #frequenciesolution
f_max <- max( eeg$frequency_eeg )
exp_type <- eeg$experiment[1]
eeg_date <- strptime( eeg$date,  "%y%m%e" )[1]
drug <- eeg$drug[1]

###############################################
# Add a column with the dose of drug received #
###############################################

injection_int <- as.numeric( eeg$injection_int[1] )*60
baseline_int <- as.numeric( eeg$baseline[1] )*60

d0 <- eeg$d0[1]
d1 <- eeg$d1[1]
dose_int <- eeg$doseinterval[1]

# This is to find the max number of decimal needed to report that is the decimals of the first dose
sd0 <- unlist(strsplit(as.character(d0), ""))
ndecimal <- as.numeric(length(sd0) - match(".", sd0 ))


alldoses <-  round( 10^( seq(log10(d0), log10(d1), by = dose_int )), ndecimal)

# Every dose int we have a different dose but the first injection was given at baseline interval so:
injection_time <- as.numeric( c( 0, baseline_int, baseline_int + seq_along(alldoses)* injection_int ) )

# Dosing Intervals
eeg[, "D_interval"] <- cut( eeg$time_sec, injection_time, labels =  c("baseline", alldoses),  include.lowest = FALSE )
eeg$D_interval[is.na(eeg$D_interva)] <- max(alldoses)

##############
# A graph #
##############
gtitle <- paste0( eeg_date," ",  subj, " ", drug )
subt <- 
  paste0("doses = ", paste(round(alldoses, 3), collapse = ", "), " mg/kg given every ", injection_int/60, " min" )

seqbreaks <- seq(0, max(eeg$time_sec/60), by = injection_int/60)

grapheat <-
ggplot(eeg, aes(time_sec/60, frequency_eeg)) +
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

wdir <- getwd()
msgBox(c("An heatmap has been created in ",  wdir) )

#########################################################
# Interactive section to choose time interval for means #
#########################################################

is.wholenumber <-
  function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol

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



# All the intervals have the same length. This is to avoid that
# the last interval is just 10 sec

eeg <-  eeg %>% 
        filter( time_sec  <= floor(max(time_sec)/300)*300 )

interv <- as.numeric(interv)

# Intervals used for the mean  -> mean_intervals

eeg[, "M_interval"] <- as.numeric(findInterval(eeg$time_sec, 
                                                as.numeric(seq(interv, max(eeg$time_sec), interv), left.open = TRUE)) ) + 1

#########################################################################
# Interactive section to choose  between frequencies or bands for means #
#########################################################################
dlgMessage("Are you intrested in bands or particular frequencies?\n PRESS OK TO CHOOSE")$res

bandfreq <-  c("Bands", "Frequencies")

res <- dlgList(bandfreq, multiple = TRUE, title = "Select one")$res

while ( !length(res)) {
    tree1 <- dlgMessage( c("You pressed cancel", "Do you want to go back?"), "yesno" )$res
    stopifnot ( tree1 ==  "yes" ) 
    res <- dlgList(bandfreq, multiple = TRUE, title = "Select one")$res
}


###############################################################################
# Function for Interactive session to indicate frequencies or bands for means #
###############################################################################

#' Interactive session for  bands or frequency.
#' 
#' \code{insert_freq} returns a vector of function/bands of interests.
#' 
#' This is a generic function to interctively insert bands or frequencies of 
#' interst with messages varying depending on the choices
#'
#' @param x the choice "Bands" of "Frequencies".
#' 
#' 



insert_freq<- function(fb) {
  
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
    
    while(sum(as.numeric(freq %in% eeg$frequency_eeg)) != length (freq) | !length(freq)) {
      
        tree1 <- dlgMessage(c("You pressed cancell or inserted one or more frequencies that are not present",
                            "Do you want to go back?"), "yesno" )$res
      
        stopifnot ( tree1 ==  "yes" ) 
      
        freq <- dlgInput( paste( msg, f_resol, 
                                 " and max is ", f_max, sep = ""), paste(def_ch))$res  
        
        freq <- as.numeric(unlist(strsplit(freq, ",")))
    }
    
    return(freq)  
}



freq <- insert_freq(res)

#########################################
# Compute means of bands or frequencies #
#########################################


eeg$M_interval <- eeg$M_interval * interv

if (res == "Bands") {
  blab <-c("Delta", "Theta", "Alpha", "Beta", "Gamma")
  freq<-as.numeric(c(0,freq))
  eeg[, "Bands"] <- cut(eeg$frequency_eeg,  freq, labels = blab, include.lowest = FALSE)
  sel <- as.symbol("Bands")
  subt2  <- res
  }

if (res == "Frequencies") {
  eeg <- subset(eeg, frequency_eeg %in% freq)
  sel <- as.symbol("frequency_eeg")
  subt2  <- paste(res, " (Hz)", sep = "")
}


fmeans_eeg <- eeg %>%
  group_by_(.dots = c(sel, "M_interval", "channel", "D_interval" )) %>%
  dplyr::summarise(  Mean_PSD = mean(PSD), n = n(), SD = sd(PSD), Median_PSD = median(PSD))

fmeans_eeg <- na.omit(fmeans_eeg)
names(fmeans_eeg) [c(1,2,4)] <- c( paste(sel), "intervals_sec", "drug_dose" )


#########
# Graph #
#########

#limit x axis
lx <- c(0 - min(fmeans_eeg$intervals_sec/60), max(fmeans_eeg$intervals_sec/60) + min(fmeans_eeg$intervals_sec/60))
lerr <- aes(ymax = Mean_PSD + SD, ymin= Mean_PSD - SD)

# breaks axis
yseqbreaks <- seq(0, max(fmeans_eeg$Mean_PSD)+10, by = 5)



# Size of the points changes depending on the number of intervals
sp <- interv/100
csp <-  sp + sp/3


mean_point <-
ggplot(fmeans_eeg, aes(intervals_sec/60, Mean_PSD,  colour = drug_dose)) +
  geom_line(colour = "grey20") +
  geom_errorbar(lerr, colour = "grey20") +
  geom_point(size = csp, colour = "grey20", show.legend = TRUE) + 
  geom_point(size = sp) +
  scale_color_brewer(palette = "Set1") +
  facet_grid(as.formula(paste("channel","~", sel))) +
  scale_x_continuous( expand = c(0,0), breaks = seqbreaks, limits = lx  ) +
  scale_y_continuous( expand = c(0,0), breaks = seq(0, max(fmeans_eeg$Mean_PSD)+10, by = 5), 
                            limits = c(0, max(fmeans_eeg$Mean_PSD)+10 )) +
  labs(x = "Time (min)", 
             y = " mean PSD (dB) and St.Dev", 
             colour = "Dose (mg/kg)", 
             element_text(face = "bold"),
             title = gtitle,
             subtitle = paste(subt2)
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


#######################
# Save plot and means #
#######################     
          
# save graph         
ggsave(filename = paste(gtitle, ".pdf", sep =""), plot = mean_point, device = "pdf",  width = 11, height = 8.5)


# Rename columns and reorder them
tabegg <-fmeans_eeg

colnames(tabegg) <- c( paste(subt2), "intervals_sec", "channel", 
                           "drug dose (mg/kg)", "mean PSD (dB)","n", "SD", "median PSD (dB)")  
tabegg <- mutate(tabegg, subj = subj, drug = drug, eeg_date = as.character.Date(eeg_date) )
tabegg <- tabegg[, c(9, 10, 11, 1:8)]
  

# save csv
write.csv(tabegg, file = paste(gtitle,".csv", sep = "")) 

msgBox(c("A point graph and a summary csv has been created in ",  wdir) )

rm(list= ls())
