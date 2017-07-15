#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Function to remove corrupted channels in alleeg DF -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
remcorr2 <- function (dat) {
  
  
  while( !exists("loop") ||   loop == "yes" ) {
  
      rsubj <- dlgList( unique(dat$subject), multiple = TRUE, title = "Select the subject")$res
      
      rchan <- dlgList( unique( subset(dat, subject == rsubj)$channel ), multiple = TRUE, title = "Select the channel to remove")$res
      
      alleeg <- alleeg  [-c( which( dat$subject == rsubj & dat$channel == rchan)),] 
      
      loop <- dlgMessage(c("Do you want to remove more channels?"), "yesno" )$res
      
  }
  
  alleeg 
}
