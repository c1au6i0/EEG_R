# 

library("reticulate")

info <- file.choose()

py <- import_builtins()

info_py = py$open(info,'r')

np$fromfile(info_py, dtype=np$int32, count = as.integer(1))

np$fromfile(info_py, dtype=np$int16, count = as.integer(1))

np$fromfile(info_py, dtype=np$int16, count = as.integer(1))

np$fromfile(info_py, dtype=np$single, count = as.integer(1))




# This is amplif

amp <- file.choose()

npoint  <- file.size(amp)/2

ch <- readBin(amp, what = "integer", size = 2, n = npoint)

ch <- as.numeric(ch * 0.195 )


# This is for the time
# time.dat
# Divide by the amplifier  sampling rate (in Samples/s) to get a time vector with units of seconds.

tst <- file.choose()

npoint  <- file.size(tst)/2

time.dat <- readBin(tst, what = "integer", size = 4, n = npoint)

