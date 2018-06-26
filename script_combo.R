
source("J:/EEG data/EEG_R/script_start.R")

mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite3")




db_list_tables(mydb)
alone <- as_data_frame(tbl(mydb, "Cocaine" ))
combo <-  as_data_frame(tbl(mydb, "Cocaine+1WIN35428"))

# sort(unique(alone$subject)) == sort(unique(combo$subject))

# sum(is.na(combo))

baselinecoc <-  filter(alone,  D_interval  == "baseline")

# I need to add time to cocainecomb
# 0 is for 10 JHW007

combo$time_sec <-  combo$time_sec + 10*60

combo$D_interval[combo$D_interval == "baseline"] <- "1_WIN35428"
allcombo <- bind_rows(combo, baselinecoc)


dbWriteTable(mydb, "combo_Cocaine_1WIN35428", allcombo)


dbDisconnect(mydb)
# setequal


