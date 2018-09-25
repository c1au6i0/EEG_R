# 7-23-18
# script to import and calculate moving index.
# 

# load packages and scripts
if (Sys.info()["sysname"] != "Windows" ) {
  source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R") } else {
    source("J:/EEG data/EEG_R/script_start.R")
  }  

py <- import_builtins()
np <- import("numpy")
main <- import_main()
spsi <- import("scipy.signal") 
pdb <-  import("pdb")


dir_intan <- dlg_dir()$res

mov_df10 <- get_mi(dir_intan = dir_intan)

mov_df10 <- mov_df10 %>% 
  filter(time_bin <= 3000)


mov_df10 %>% 
  ggplot(aes(time_bin, mov_ix)) +
  geom_line(aes(group = 1)) +
  scale_x_continuous(breaks= seq(0, tail(mov_df10$time_bin,1), by = 600)) +
  geom_smooth()



# Interrupted session ---------------
      
      # you need to create a list of dataframes ordered by data of creations and call it RAT
      RAT <-  list ( A = RAT30A,
                     B = RAT30B,
                     C = RAT3BA
                      )

      
      # starting times
      stl <- c("180709_144011", "180709_145126", "180709_152803")
      
      # trasform in format Posixcl
      st_time <-  strptime(stl, format = "%y%m%d_%H%M%S")
      
      # find the difference in seconds between 2 Posixcl values
      time_dif <- function (a, b) {
        
        as.numeric(difftime(a, b, units = "sec"))
        
      }
      
      # time that needs to be added  
      toadd  <- mapply (time_dif, st_time[2:length(st_time)], rep(st_time[1],length(st_time) - 1))
      
      # round up
      toadd  <- ceiling(toadd/10)*10
      
      
      
      # add time
      
      addtime <-  function (x, y) {
        x[, "Time"]  <- x[, "Time"] + y
        
        x
      }
      
      
      #add time to each of the elments of the list of interrupted sessions
      prova     <-  mapply ( addtime,
                             RAT[2:length(RAT)],
                             toadd,
                             SIMPLIFY = FALSE
      )
      
      RAT_int <- bind_rows(prova)
      
      
      RAT_int <-  bind_rows(RAT$A, RAT_int)
      
####################################


mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG/Databases_EEG/Mov_index.sqlite")

glimpse(mov_df10)

# dbRemoveTable(mydb, "cocaine")

dbAppendTable(mydb, "cocaine", mov_df10)

dbListTables(mydb)
dbDisconnect(mydb)
