#how to work with sqlite https://cran.r-project.org/web/packages/RSQLite/vignettes/RSQLite.html

library(DBI)
library(RSQLite)
library(dplyr)
library(dbplyr)

mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")

dbListTables(mydb)

alleeg <- dbGetQuery(mydb, 'SELECT * FROM ketamine')

# alleeg  <- tbl(mydb, "ketamine") 


alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
drug <- alleeg$drug[1]
injection_int <- as.numeric( alleeg$injection_int[1] )*60
baseline_int <- as.numeric( alleeg$baseline[1] )*60

setwd(choose.dir())


db_re

unique(alleeg$subject)


dbRemoveTable(mydb, "Modafinil")

dbWriteTable(mydb, "modafinil", alleeg2)



dbWriteTable(mydb, paste(drug), alleeg2)

db_list_tables(mydb)

db_drop_table(mydb, paste(drug))


dbListTables(mydb)


setOldClass(c("grouped_df", "tbl_df", "data.frame"))
cocaine_db <- tbl(mydb, "cocaine")


db


# change name table
#  https://stackoverflow.com/questions/42235110/how-to-rename-a-sqlite-table-with-dplyr
q <- "ALTER TABLE mtcars2 RENAME TO mtcars3"

DBI:::dbSendQuery(db$con, sql(q))

