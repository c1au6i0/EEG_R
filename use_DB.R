#how to work with sqlite https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html

library(DBI)
library(RSQLite)
library(dplyr)
library(dbplyr)

mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")

dbListTables(mydb)

alleeg <- dbGetQuery(mydb, 'SELECT * FROM ketamine')

toadd <- dbGetQuery(mydb, 'SELECT * FROM RAT16_24_JHW007')

# alleeg  <- tbl(mydb, "ketamine") 


alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
drug <- alleeg$drug[1]
injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60




dbWriteTable(mydb, 'morphineld_naltrexone', alleeg2)

