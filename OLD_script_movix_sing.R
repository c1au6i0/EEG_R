# import data intan files, a file for each channel 
# and those analysis of movement
# http://www.intantech.com/files/Intan_RHD2000_data_file_formats.pdf

# load packages and scripts
if (Sys.info()["sysname"] != "Windows" ) {
  source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R") } else {
    source("J:/EEG data/EEG_R/script_start.R")
  }  



# SET Directory to analyze and list of files ----------
dir_intan <- dlgDir()$res


setwd(dir_intan)

files <- list.files(include.dirs=FALSE)

#details experiment are in the txt file
dte <-  files[grepl("RAT.*txt", files)]
dte2 <- dte

if (length(dte) == 0) message("Error: Info file not found!")

dte <- unlist(strsplit(dte, "_"))
dte[10] <- "iv"
dte[4]  <- "Cumulative"
dte

#here add semething in case of error

names(dte) <- c("subject", "date", "drug", "exp", "fdose", "ldose", "dint", "btime","inttime", "route")


# create a list of amp, aux, vdd  channels names to import ----
for (e in c("aux", "vdd", "amp")) {
    d <- files[grepl(e, files)]
    assign(e, d)
}

rm(d, e)  
  


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

# %>% 
#     filter(time_bin< 3000)

mov_df10 %>% 
  ggplot(aes(time_bin, mov_ix)) +
  geom_line(aes(group = 1)) +
  scale_x_continuous(breaks= seq(0, tail(mov_df10$time_bin,1), by = 600)) +
  geom_smooth()
    


mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG/Databases_EEG/Mov_index.sqlite")

glimpse(mov_df10)

# dbRemoveTable(mydb, "cocaine")

dbAppendTable(mydb, "cocaine", mov_df10)

dbListTables(mydb)
dbDisconnect(mydb)
# names(amp_ch) <- amp

# #Graph snipet ---------------
# 
# front <- amp_ch$`amp-D-012.dat`
# 
# # mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.PSD1examples")
# # dbWriteTable(mydb, dte2, as.data.frame(front))
# 
# # mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/PSD1_examples.sqlite")
# mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG_R/PSD1_examples.sqlite")
# 
# dbListTables(mydb)
# front <-  dbGetQuery(mydb, "SELECT * FROM 'RAT15_2017-08-03_JHW007_Cumul_1_10_0.5_30_30_iv.txt'  ")
# 
# front <- front$front
# # min start
# st <- 114
# 
# #snipet lenghtn in min
# lgsn <- 0.1
#   
# 
# y <- front[ (st*60*2000):(st*60*2000 + lgsn* 60 * 2000)]
# 
# x <- seq_along(y)/2000
# 
# plot(x, y, type = "l",
#      
#      xlab = "sec",
#      ylab = "microV",
#      ylim = c(-200, 200)
#      )
# 
# 
# # dbDisconnect(mydb)
# 
