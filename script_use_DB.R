#how to work with sqlite https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html


# source("J:/EEG data/EEG_R/script_start.R")
source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R")

mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG/Databases_EEG/PSD3.sqlite")

dbListTables(mydb)


# <- dbGetQuery(mydb, 'SELECT * FROM cocaine')

toadd <- dbGetQuery(mydb, 'SELECT * FROM RAT16_24_JHW007')

alleeg  <- tbl(mydb, "ketamine") 


alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
drug <- alleeg$drug[1]
injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60


dbWriteTable(mydb, 'cocaine+1WIN35428', alleeg2)

dbWriteTable(mydb, 'allfront_nl', prism)

dbRemoveTable(mydb, "saline3")

dbGetQuery(mydb, 'SELECT DISTINCT drug
                            FROM allfront
                            ORDER BY ROWID ASC LIMIT 10')

   WHERE  drug = "cocaine" ')

db_list_tables(mydb)
