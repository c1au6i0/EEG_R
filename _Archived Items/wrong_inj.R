library(data.table)
prova <- fread(file.choose())
after <- filter(prova, Time > 3000 )
before <-filter(prova, Time < 3000 )
min(after$Time)


max(before$Time)

after$Time <- after$Time + 600

fixed <-rbind(before, after)
write.csv (fixed, file = "RAT37_fixed.csv", row.names = F)


