#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Function to remove corrupted channels in alleeg DF -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
remcorr <- function (x) {

    if ( x == "yes") {
      
      while( !exists("loop") ||   loop == "yes" ) {
        
        rsubj <- dlgList( unique(alleeg$subject), multiple = TRUE, title = "Select the subject")$res
        
        rchan <- dlgList( unique( subset(alleeg, subject == rsubj)$channel ), multiple = TRUE, title = "Select the channel to remove")$res
        
        alleeg <- alleeg  [-c( which( alleeg$subject == rsubj & alleeg$channel == rchan)),] 
        
        loop <- dlgMessage(c("Do you want to remove more channels?"), "yesno" )$res
        
 
      }
        
    }
  
  alleeg 
}




