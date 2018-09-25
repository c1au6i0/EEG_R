

import_ale <- function ( fold ) {
  
  # import data from Ale csv and add dose colunmn

  setwd(fold)    #set the directory
  file <- list.files(include.dirs=FALSE)
  
  dirs <- basename(list.dirs())
  file <- file[!file %in% dirs]
  
  nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv", file)]
  
  file <- file[!file %in% nread]
  

  # prova <- map_dfr(file, function (x) read_csv( x ))

  alleeg  <- map_dfr(file, function (x) {
                            tmp <- read_csv( x )
                            message(paste0("Subject imported: ", tmp$subject[1]))
                            tmp}
    )

  # alleeg  <-  Reduce(function(...) merge(..., all=T),   prova )
  
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
  alleeg$D_interval[is.na(alleeg$D_interval)] <- max(alldoses)
  
  
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
  
  alldoses <- unique(alleeg$D_interval[!alleeg$D_interval == "baseline"])
  
  drug <- alleeg$drug[1]
  
  injection_int <- as.numeric( alleeg$injection_int[1] )*60
  
  baseline_int <- as.numeric( alleeg$baseline[1] )*60
  
  out <- list(alldoses, alleeg, baseline_int, drug, injection_int)
  
  names(out) <- c("alldoses", "alleeg", "baseline_int", "drug", "injection_int")
  
  dbDisconnect(mydb)
  
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

get_mi <- function (dir_intan) {
  
  
  #require svDialogs, dplyr, lubridate, reticulate and link to libmov functiontion written in python
  
  
  setwd(dir_intan)
  
  files <- list.files(include.dirs=FALSE)
  
  #details experiment are in the txt file
  dte <-  files[grepl("RAT.*txt", files)]
  dte2 <- dte
  
  if (length(dte) == 0) stop("Error: Info file not found!")
  
  dte <- unlist(strsplit(dte, "_"))
  dte[10] <- "iv"
  dte[4]  <- "Cumulative"
  
  dte_res <- dlg_message(paste0(dte2, " are info correct?"), "yesno")$res
  
  if (dte_res == "no") stop("Error: details exp wrong!")
  
  #here add semething in case of error
  
  names(dte) <- c("subject", "date", "drug", "exp", "fdose", "ldose", "dint", "btime","inttime", "route")
  
  
  # create a list of amp, aux, vdd  channels names to import ----
  for (e in c("aux", "vdd", "amp")) {
    d <- files[grepl(e, files)]
    assign(e, d)
  }
  
  
  # RHD2000 HD ----
  
  info <- paste0(dir_intan, "/info.rhd")
  
  py <- import_builtins()
  np <- import("numpy")
  main <- import_main()
  spsi <- import("scipy.signal") 
  pdb <-  import("pdb")
  
  
  info_py = py$open(info,'r')
  
  headers <- list()
  ty <- c("int32", "int16", "int16","single", "int16", rep("single",6))
  
  for (x in ty) {
    headers <- append(headers, np$fromfile(info_py, dtype=np[[x]], count = as.integer(1)))
  }
  
  
  names(headers) <- c("magic_n","ver1", "ver2", "sampr", "DSP", "DSP_cutoff", 
                      "lower_BDW", "upper_BDW","des_DSPcutoff", "des_lowband", "des_upband")
  
  
  
  # header["magic_n"] <- py_to_r(np$fromfile(info_py, dtype=np$int32, count = as.integer(1)))
  
  
  
  # Import timestamp, aux, amp, vdd ---------------------------------
  # http://www.intantech.com/files/Intan_RHD2000_data_file_formats.pdf
  
  # info sessions 
  
  info_txt <- str_split(read_lines(file = str_subset(files, "^RAT.*txt"), n_max = 2), "_")
  
  info_session <- as.list(unlist(info_txt[[1]]))
  names(info_session ) <- as.list(unlist(info_txt[[2]]))
  
  #time.dat
  tst <- unlist(import_chan( chan = "time.dat", ty = "int32", conv = 1/as.numeric(headers["sampr"])))
  
  # aux
  aux_ch <- lapply(aux, import_chan, ty = "uint16", conv = 0.0000374) # repeated 4 at the time
  
  # amplifier-------------
  # amp_ch <- pblapply(amp, import_chan, ty = "int16", conv = 0.195)
  
  # vdd
  vdd_ch <- unlist(pblapply(vdd, import_chan, ty = "uint16", conv = 0.0000748)) 
  
  
  # Check if there is a drop in power.
  if ( (max(vdd_ch) - min(vdd_ch)) > 0.2 ) {
    warning("Data indicate that there was a drop in the power!")
    
  } 
  
  
  # Movement Index analysis -----------
  
  # module of the 3 vectors 
  aux_ch_mod <- sqrt(aux_ch[[1]]^2 + aux_ch[[2]]^2 + aux_ch[[3]]^2)
  
  #import alex mi
  lib_acc <- import_from_path("lib_acc", path = "/Users/NCCU/Documents/EEG/EEG_R/", convert = TRUE)
  
  
  aux_filt <- lib_acc$filter_acc(np$asarray(aux_ch_mod))
  movix <- lib_acc$movement_index(np$asarray(aux_filt))
  
  
  
  #lets create the dataframe including info in the headers and in the info_session file
  mov_df <- data_frame("time" = seq_along(movix)/ headers$sampr,
                       "x" = movix
  )
  
  
  # The PSD analysis is done for timewindows of 10 seconds. This does the same for mov_df
  
  mov_df[, "time_bin"] <- as.numeric(as.character(cut(as.vector(unlist(mov_df$time)),
                                                      as.vector(seq(0, tail(mov_df$time,1), 10)), 
                                                      labels = seq(10, tail(mov_df$time,1), 10),
                                                      include.lowest = FALSE)))
  
  mov_df10 <- mov_df %>% 
    group_by(time_bin) %>% 
    summarize(mov_ix = sum(x)) %>% 
    mutate(                    
      "subject" = info_session$SUBJECT,
      "date" = as_date(info_session$DATE),
      time = time_bin,
      "dose_rounte" = info_session$ROUTE,
      "dose_interval" = info_session$DOSEINTERVAL,
      "drug" = info_session$DRUG,
      "experiment" = info_session$EXPERIMENT,
      "session_name" =  paste( unlist(info_txt[[1]]), collapse='_'),
      "d0" = info_session$D0,
      "d1" = info_session$D1,
      "time_interval" = info_session$TIMEINTERVAL,
      "baseline_time" = info_session$BASELINE
    )
  
  mov_df10 <- na.omit(mov_df10)
  return(mov_df10)
}