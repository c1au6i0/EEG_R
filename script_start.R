

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
                  "packrat",
                  "pbapply",
                  "pracma",
                  "reticulate",
                  "RSQLite",
                  "scales",
                  "svDialogs",
                  "viridis")


lapply(to_load, require, character.only = TRUE)


setwd("J:/EEG data/EEG_R")
ufunc <- list( "graphing_functions.R",
               "equalizing_factor_functions.R",
               "import_functions.R",
               "interactive_functions.R",
               "mean_percent_functions.R"
                )

sapply(ufunc, source, .GlobalEnv)

