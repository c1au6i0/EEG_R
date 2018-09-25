# 7/24/18
# script to group sum



# load packages and scripts
if (Sys.info()["sysname"] != "Windows" ) {
  source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R") } else {
    source("J:/EEG data/EEG_R/script_start.R")
  }  

mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG/Databases_EEG/Mov_index.sqlite")



# dbRemoveTable(mydb, "cocaine")

cocaine <- dbGetQuery(mydb, " SELECT *
                      FROM cocaine
                      
                      ")
int = 300
 

cocaine[,"time_bin"] <- findInterval(cocaine$time, seq(0, floor(tail(cocaine$time,1)), int), left.open = TRUE ) * int


cocaine %>% 
  group_by(subject, time_bin) %>% 
  summarize(sum_mi = sum(mov_ix), N = n()) %>% 
  ggplot(aes(x = time_bin, sum_mi, col = subject)) +
    geom_point(position = position_jitter()) +
    geom_line() +
    stat_summary(fun.data = "mean_sdl", geom = "point", col = "red", size = 3) +
    stat_summary(fun.data = "mean_sdl", geom = "line", col = "red") 
    




dbListTables(mydb)
dbDisconnect(mydb)