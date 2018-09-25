# load packages and scripts
if (Sys.info()["sysname"] != "Windows" ) {
  source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R") } else {
    source("J:/EEG data/EEG_R/script_start.R")
  }  


fold <- dlg_dir()$res
setwd(fold)    #set the directory
file <- list.files(include.dirs=FALSE)

dirs <- basename(list.dirs())
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv", file)]

file <- file[!file %in% nread]


# prova <- map_dfr(file, function (x) read_csv( x ))

alleeg  <- map(file, function (x) read_csv( x ))

RAT47 <- alleeg[[2]]

lastinj <-  90 * 60

delay <-  120
beforeinj <- filter(RAT47, Time  <= lastinj)
afterinj  <- filter(RAT47, Time  >= lastinj)
max(afterinj$Time )
min(afterinj$Time )


afterinj$Time <- afterinj$Time - 120
afterinj  <- filter(afterinj, Time  >= lastinj)
RAT47f_cor<- bind_rows(beforeinj, afterinj )
write_csv(RAT47f_cor, 'RAT47f_cor.csv')
