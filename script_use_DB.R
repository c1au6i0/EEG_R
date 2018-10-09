
# source("J:/EEG data/EEG_R/script_start.R")
source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R")

# the database to open or where to save to. In case change file location
mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG/Databases_EEG/PSD3.sqlite")

# List tables
dbListTables(mydb)

# Write table: change name in ""
dbWriteTable(mydb, "Heroin + 10JHW007", alleeg2)

# # <- dbGetQuery(mydb, 'SELECT * FROM cocaine')
# 
# toadd <- dbGetQuery(mydb, 'SELECT * FROM RAT16_24_JHW007')
# 
# alleeg2  <- tbl(mydb, "Heroin + 10JHW007") 
# unique(alleeg$D_interval)
# 
# alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
# drug <- alleeg$drug[1]
# injection_int <- as.numeric( alleeg$injection_int[1] )*60
# baseline_int <- as.numeric( alleeg$baseline[1] )*60
# 
# 
# dbWriteTable(mydb,  "Cocaine+1WIN35428", alleeg2)
# 
# dbWriteTable(mydb, 'allfront_nl', prism)
# 
# dbRemoveTable(mydb, "saline3")
# 
# dbGetQuery(mydb, " SELECT DISTINCT  subject
#                           FROM 'cocaine' ")
# # WHERE  drug = "cocaine" ')
# 
# dbExecute(mydb, q)
# q <- "UPDATE Heroin SET subject = 'RAT35f' WHERE subject = 'RAT35'"
# q <- "ALTER TABLE cocaine RENAME TO Cocaine"
# 
# mov_df11 <- dbGetQuery(mydb, " SELECT *
#                    FROM cocaine
#                    WHERE subject is 'RAT30'
#            
#            ")
# unique(cocaine_noRAT34$subject)
# 
# dbWriteTable(mydb, "cocaine_noRAT34", cocaine_noRAT34)
# 
# dbDisconnect(mydb)
# 



