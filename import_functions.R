

import_ale <- function ( fold ) {
  
  # import data from Ale csv and add dose colunmn
  
  setwd(fold)    #set the directory
  file <- list.files(include.dirs=FALSE)
  
  dirs <- basename(list.dirs())
  file <- file[!file %in% dirs]
  
  nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv", file)]
  
  file <- file[!file %in% nread]
  

  prova <- pblapply(file, function (x) read.csv( x , header = TRUE, sep = "," ))
  

  alleeg  <-  Reduce(function(...) merge(..., all=T),   prova )
  
  # alleeg$route <- "iv"
  
  alleeg <- na.omit(alleeg)
  
  
  alleeg$date <- as.character(alleeg$date)
  alleeg$date <- gsub("/","-", alleeg$date) # remove / from date, / can cause problems
  
  names(alleeg)[ !names(alleeg) %in% c("PSD","Frequency") ] <- tolower( names(alleeg)[ !names(alleeg) %in% c("PSD","Frequency") ] )
  
  # remove Frequencies = 0
  alleeg <- subset(alleeg, Frequency > 0)
  
  alleeg <- dplyr::rename(alleeg, time_sec = time )
  alleeg <- dplyr::rename(alleeg, injection_int = timeinterval )
  alleeg <- dplyr::rename(alleeg, frequency_eeg = Frequency )
  
  # this is to order the facet in the graph
  alleeg$channel <- factor( alleeg$channel, levels = c("EEG_FL","EEG_FR", "EEG_PL", "EEG_PR", "EEG_OL", "EEG_OR") ) 
  
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  # Some unique values -
  # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
  
  
  f_resol <- unique( alleeg$frequency_eeg )[1]  #frequenciesolution
  f_max <- max( alleeg$frequency_eeg )
  exp_type <- alleeg$experiment[1]
  
  alleeg$date <- as.character( alleeg$date )

  alleeg$route <- "iv"
  
  
  drug <- alleeg$drug[1]
  
  injection_int <- as.numeric( alleeg$injection_int[1] )*60
  baseline_int <- as.numeric( alleeg$baseline[1] )*60
  
  # alleeg[,"baseline"] <- 30
  # baseline_int <- 1800
  
  
  
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
  
  
  out <- list(alldoses, alleeg, baseline_int, drug, injection_int)
  
  names(out) <- c("alldoses", "alleeg", "baseline_int", "drug", "injection_int")
  
  out
}



import_sqltb  <- function( dbp, tab) {
  
  # import table of sql3 database
  # dbp = path of SQL database
  # tab = name of tab
  
  mydb <- dbConnect(RSQLite::SQLite(), dbp)
  
  alleeg  <- tbl(mydb, tab)
  
  alleeg <- as.data.frame(alleeg)
  
  alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
  
  drug <- alleeg$drug[1]
  
  injection_int <- as.numeric( alleeg$injection_int[1] )*60
  
  baseline_int <- as.numeric( alleeg$baseline[1] )*60
  
  out <- list(alldoses, alleeg, baseline_int, drug, injection_int)
  
  names(out) <- c("alldoses", "alleeg", "baseline_int", "drug", "injection_int")
  
  out
  
  
}


import_chan <- function (chan, ty, conv) {
  
  # Import intan channels ----
  # chan = name of the channel/file  to import
  # ty = int16, int32...
  # conv = conversion factor
  
  # return a vector
  
  ch_lin <-  py$open(chan,'r')
  
  ch_imp <- np$fromfile(ch_lin, dtype=np[[ty]])
  
  ch_imp <- as.vector(ch_imp) * conv
  
  ch_imp
  
}

