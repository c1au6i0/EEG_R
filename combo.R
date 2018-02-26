db_list_tables(mydb)
cocaine <- as.data.frame(tbl(mydb, "cocaine"))
combo <-  as.data.frame(tbl(mydb, "cocaine+10JHW007"))

sort(unique(cocaine$subject)) == sort(unique(combo$subject))

sum(is.na(combo))

baselinecoc <-  filter(cocaine,  D_interval  == "baseline")

# I need to add time to cocainecomb
# 0 is for 10 JHW007

combo$time_sec <-  combo$time_sec + 10*60

combo$D_interval[combo$D_interval== "baseline"] <- 0
cocainecombo<- rbind(combo, baselinecoc)


dbWriteTable(mydb, "combo_cocaine_JHW007", combo)

dbDisconnect()


