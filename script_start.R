
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Library and user functions ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
to_load  <- list( "colorspace",
                  "DBI",
                  "plyr",
                  "dbplyr",
                  "dplyr",
                  "ggplot2",
                  "lazyeval",
                  "magrittr",
                  "multcomp",
                  "nlme",
                  "packrat",
                  "pbapply",
                  "pracma",
                  "purrr",
                  "reticulate",
                  "RSQLite",
                  "scales",
                  "stringr",
                  "svDialogs",
                  "viridis")


lapply(to_load, require, character.only = TRUE)



if (Sys.info()["sysname"] != "Windows" ) {
  setwd("/Users/NCCU/Documents/EEG_R/") } else {
  setwd("J:/EEG data/EEG_R")
}  
  



ufunc <- list( "graphing_functions.R",
               "equalizing_factor_functions.R",
               "import_functions.R",
               "interactive_functions.R",
               "mean_percent_functions.R"
                )

sapply(ufunc, source, .GlobalEnv)

