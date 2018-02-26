#how to work with sqlite https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html

library(DBI)
library(RSQLite)
library(dplyr)
library(dbplyr)
library(pragma)

mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")

dbListTables(mydb)

# <- dbGetQuery(mydb, 'SELECT * FROM cocaine')

toadd <- dbGetQuery(mydb, 'SELECT * FROM RAT16_24_JHW007')

alleeg  <- tbl(mydb, "ketamine") 


alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
drug <- alleeg$drug[1]
injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60


dbWriteTable(mydb, 'methylphenidate', alleeg2)

dbWriteTable(mydb, 'allfront_nl', prism)

dbRemoveTable(mydb, "saline3")

 prova <- dbGetQuery(mydb, 'SELECT *
                  FROM allfront_nl')


                  WHERE  drug = "cocaine" ')


                  ORDER BY ROWID ASC LIMIT 300')


db_list_tables(mydb)
