alleeg <- read.csv2(file.choose(), header = TRUE, sep = ",")


names(alleeg)

head(alleeg)
alleeg <- subset(alleeg, select = -X)





firstint <- filter(alleeg, time_sec < 5220)


lastint <-  filter(alleeg, time_sec  >  5580)

lastint$time_sec <- lastint$time_sec -180

extra3  <- filter(alleeg, time_sec  >  5400 & time_sec  <= 5580  )

extra3$time_sec <-  extra3$time_sec -180

flextra <- c( head(extra3$time_sec,1), tail(extra3$time_sec,1) )


flfirst <- c( head(firstint$time_sec,1), tail(firstint$time_sec,1) )


fllast <- c( head(lastint$time_sec,1), tail(lastint$time_sec,1) )


corr_alleeg <- rbind(corr_alleeg, lastint)

