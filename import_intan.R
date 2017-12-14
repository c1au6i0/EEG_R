# import data intan files, a file for each channel 
# http://www.intantech.com/files/Intan_RHD2000_data_file_formats.pdf

# 
# library("reticulate")
# library("pbapply")

source("J:/EEG data/EEG_R/Scripts/start.R")
# SET Directory to analyze and list of files ---- 
f_here <- choose.dir()

setwd(f_here)

files <- list.files(include.dirs=FALSE)

#details experiment are in the txt file
dte <-  files[grepl("RAT.*txt", files)]

if (length(dte) == 0) message("Error: Info file not found!")

dte <- unlist(strsplit(dte, "_"))
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

info <- paste0(f_here, "/info.rhd")

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

headers

# Import timestamp, aux, amp, vdd ----
# http://www.intantech.com/files/Intan_RHD2000_data_file_formats.pdf

#time.dat
tst <- unlist(import_chan( chan = "time.dat", ty = "int32", conv = 1/as.numeric(headers["sampr"])))

# aux
aux_ch <- lapply(aux, import_chan, ty = "uint16", conv = 0.0000374) # repeated 4 at the time

# amplifier
amp_ch <- pblapply(amp, import_chan, ty = "int16", conv = 0.195)

# vdd
vdd_ch <- unlist(pblapply(vdd, import_chan, ty = "uint16", conv = 0.0000748)) 


if ( (max(vdd_ch) - min(vdd_ch)) > 0.2 ) {
  warning("Data indicate that there was a drop in the power!")
  
} 




