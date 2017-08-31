# 

library("reticulate")


# SET Directory to analyze and list of files 
f_here <- setwd(choose.dir())

files <- list.files(include.dirs=FALSE)

#details experiment
dte <-  files[grepl("RAT.*txt", files)]

if (length(dte) == 0) message("Error: Info file not found!")

dte <- unlist(strsplit(dte, "_"))

names(dte) <- c("subject", "date", "drug", "exp", "fdose", "ldose", "dint", "btime","inttime", "route")

# create a list of the names of channels to import
for (e in c("aux", "vdd", "amp")) {
    d <- files[grepl(e, files)]
    assign(e, d)
}

rm(d, e)  
  


#RHD2000 HD

info <- paste0(f_here, "/info.rhd")

py <- import_builtins()
np <- import("numpy", convert = FALSE)

info_py = py$open(info,'r')

headers <- list()
ty <- c("int32", "int16", "int16","single", "int16", rep("single",6))

for (x in ty) {
     headers <- append(headers, py_to_r(np$fromfile(info_py, dtype=np[[x]], count = as.integer(1))))
}

names(headers) <- c("magic_n","ver1", "ver2", "sampr", "DSP", "DSP_cutoff", 
                    "lower_BDW", "upper_BDW","des_DSPcutoff", "des_lowband", "des_upband")



# header["magic_n"] <- py_to_r(np$fromfile(info_py, dtype=np$int32, count = as.integer(1)))




# This is amplif
amp_ta <- paste0(f_here,  "/", amp[1])

npoint  <- file.size(amp_ta)/2 # int16 =  2 bytes

ch <- readBin(amp_ta, what = "integer", size = 2, n = npoint)

ch <- as.numeric(ch * 0.195 )

assign(amp[1], ch)


# This is for the time
# time.dat
# Divide by the amplifier  sampling rate (in Samples/s) to get a time vector with units of seconds.

#timestamp
tst <- paste0(f_here, "/time.dat")

npoint  <- file.size(tst)/4  #int32 = 4 bytes

time.dat <- readBin(tst, what = "integer", size = 4, n = npoint)

time.dat <- time.dat/as.numeric(headers["sampr"])


