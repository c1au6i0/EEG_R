# Script to analyze combo data

source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R")

mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG/Databases_EEG/PSD3b.sqlite")



db_list_tables(mydb)
# alone <- as_data_frame(tbl(mydb, "Heroin"))

baseline <- as_data_frame(dbGetQuery(mydb, " SELECT *
                          FROM Heroin
                          WHERE  D_interval  = 'baseline' "))

combo <-  as_data_frame(tbl(mydb,  "Heroin + 10JHW007" ))


same_subj<- intersect(unique(baseline$subject), unique(combo$subject))

combo <- combo %>% 
  filter(subject %in% same_subj)

baseline <- baseline %>% 
  filter(subject %in% same_subj)




# I need to add time to comb
# 0 is for the new baseline
# interval injection in min
int <- 30

combo$time_sec <-  combo$time_sec + 30*60

combo$D_interval[combo$D_interval == "baseline"] <- "10_JHW007"
allcombo <- bind_rows(combo, baseline)

allcombo$drug <-  "Heroin+10_JHW007"

dbWriteTable(mydb, "combo_Heroin_10_JHW007", allcombo)


dbDisconnect(mydb)
# setequal

