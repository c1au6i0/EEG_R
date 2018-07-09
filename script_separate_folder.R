# Script to  separate in 2 folders data of 2 animals recorded at the same time.


# load packages and scripts
if (Sys.info()["sysname"] != "Windows" ) {
  source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R") } else {
    source("J:/EEG data/EEG_R/script_start.R")
  }  


data_dir   <- dlgDir()$res

setwd(data_dir)

copyin_folder<- function (x) {
  let <- paste0("-", x, "-")
  files <- list.files(include.dirs=FALSE)
  to_copy <- c(files[str_detect(files, ".txt")], 
              files[str_detect(files, ".rhd")],
              files[str_detect(files, ".ods")],
              files[str_detect(files, ".xls")],
              files[str_detect(files, "time")],
              files[str_detect(files, let)])
  dir.create(x)
  file.copy(to_copy, paste0(data_dir, paste0("/", x)))
} 

map(c("A", "D"), copyin_folder)
rm(list.files(include.dirs=FALSE))



       