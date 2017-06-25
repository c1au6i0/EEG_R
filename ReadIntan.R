# 
# This is for reading the info file
#
info <- file.choose()
info.dat <- file(info, "rb")

readBin(info.dat, integer(), n=1, size = 2)


# This is amplif

amp <- file.choose()

npoint  <- file.size(amp)/2

ch <- readBin(amp, what = "integer", size = 2, n = npoint)

ch <- as.numeric(ch * 0.195 )


# This is for the time
# time.dat
# Divide by the amplifier
# sampling rate (in Samples/s) to get a time vector with units of seconds.

tst <- file.choose()

npoint  <- file.size(tst)/2

time.dat <- readBin(tst, what = "integer", size = 4, n = npoint)

time.dat[1:10]
