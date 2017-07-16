# dbp = path of SQL database
# tab = name of tab





import_sqltb  <- function( dbp, tab) {
  
  
  mydb <- dbConnect(RSQLite::SQLite(), dbp)
  
  alleeg  <- tbl(mydb, tab)
  
  aleeg <- as.data.frame(alleeg)
  
  alldoses <- as.numeric(unique(alleeg$D_interval[!alleeg$D_interval == "baseline"]))
  
  drug <- alleeg$drug[1]
  
  injection_int <- as.numeric( alleeg$injection_int[1] )*60
  
  baseline_int <- as.numeric( alleeg$baseline[1] )*60
  
  out <- list(alldoses, alleeg, baseline_int, drug, injection_int)
  
  names(out) <- c("alldoses", "alleeg", "baseline_int", "drug", "injection_int")
  
  out
  
  
}