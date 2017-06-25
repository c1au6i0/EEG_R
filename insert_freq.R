#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Function for Interactive session to indicate frequencies or bands for means -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

# fb band of frequency


insert_freq <- function(fb) {
  
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
