

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Library and user functions ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
to_load  <- list( "colorspace",
                  "DBI",
                  "fmsb",
                  "plyr",
                  "dbplyr",
                  "dbplot",
                  "lazyeval",
                  "lubridate",
                  "magrittr",
                  "multcomp",
                  "nlme",
                  "packrat",
                  "pbapply",
                  "pracma",
                  "reticulate",
                  "RSQLite",
                  "scales",
                  "svDialogs",
                  "tidyverse",
                  "viridis")


lapply(to_load, require, character.only = TRUE)



if (Sys.info()["sysname"] != "Windows" ) {
  setwd("/Users/NCCU/Documents/EEG/EEG_R/") } else {
  setwd("J:/EEG data/EEG_R")
}  
  



ufunc <- list( "functions_graphing.R",
               "functions_equalizing_factor.R",
               "functions_import.R",
               "functions_interactive.R",
               "functions_mean_percent.R"
                )

sapply(ufunc, source, .GlobalEnv)

