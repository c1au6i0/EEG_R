# Remove corrupted --------
remcorr2 <- function (dat) {
  
  # Function to remove corrupted channels in alleeg DF 
  
  while( !exists("loop") ||   loop == "yes" ) {
  
      rsubj <- dlgList( unique(dat$subject), multiple = TRUE, title = "Select the subject")$res
      
      rchan <- dlgList( unique( subset(dat, subject == rsubj)$channel ), multiple = TRUE, title = "Select the channel to remove")$res
      
      alleeg <- alleeg  [-c( which( dat$subject == rsubj & dat$channel == rchan)),] 
      
      loop <- dlgMessage(c("Do you want to remove more channels?"), "yesno" )$res
      
  }
  
  alleeg 
}

# Insert Freq --------
insert_freq <- function(fb) {
  # Function for Interactive session to indicate frequencies or bands for means 
  # fb: string = band or frequency
  
  banddef <- "4,8,13,30,50"
  fdef <- "10,20,30,40"
  
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
  
  while(sum(as.numeric(freq %in% alleeg2$frequency_eeg)) != length (freq) | !length(freq)) {
    
    tree1 <- dlgMessage(c("You pressed cancell or inserted one or more frequencies that are not present",
                          "Do you want to go back?"), "yesno" )$res
    
    stopifnot ( tree1 ==  "yes" ) 
    
    freq <- dlgInput( paste( msg, f_resol, 
                             " and max is ", f_max, sep = ""), paste(def_ch))$res  
    
    freq <- as.numeric(unlist(strsplit(freq, ",")))
  }
  
  return(freq)  
}
