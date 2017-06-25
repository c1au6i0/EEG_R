RAT12_A <- read.csv(file.choose(), header = TRUE, sep = "," )

#82m +30 sec

RAT12_B$Time <- RAT12_B$Time + 4950

RAT12 <- bind_rows(RAT12_A, RAT12_B)


write.csv (RAT12, file = "RAT12.csv", row.names = F)