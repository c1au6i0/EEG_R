alleeg <- read_csv(dlg_open()$res)

alleeg$Time <- alleeg$Time - 60


alleeg2 <- filter(alleeg, Time >= 0)

distinct(alleeg2$Time)
max(unique(alleeg2$Time))/60
write_csv(alleeg2, "RAT43f_intcorr.csv")
