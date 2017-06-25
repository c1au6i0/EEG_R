#how to work with sqlite https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html

library(DBI)
library(RSQLite)


dbWriteTable(DB, "tablename", dtf, append=TRUE, row.names = FALSE)



mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")
dbListTables(mydb)



dbRemoveTable(mydb, "lat60s")


alleeg <- dbGetQuery(mydb, 'SELECT * FROM morphine')


getwd()




dbWriteTable(mydb, "lat60s", fsperc_eeg)

setOldClass(c("grouped_df", "tbl_df", "data.frame"))

