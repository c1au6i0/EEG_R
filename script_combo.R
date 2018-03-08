
source("J:/EEG data/EEG_R/script_start.R")

mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite3")




db_list_tables(mydb)
alone <-tbl(mydb, "heroin")
combo <-  tbl(mydb, "heroin+10VK440")

# sort(unique(alone$subject)) == sort(unique(combo$subject))

# sum(is.na(combo))

baselinecoc <-  filter(alone,  D_interval  == "baseline")

# I need to add time to cocainecomb
# 0 is for 10 JHW007

combo$time_sec <-  combo$time_sec + 10*60

combo$D_interval[combo$D_interval == "baseline"] <- "10_JHW007"
allcombo <- rbind(combo, baselinecoc)


dbWriteTable(mydb, "combo_cocaine_JHW007", allcombo)


dbDisconnect(mydb)



