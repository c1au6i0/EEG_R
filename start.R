

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Library and user functions ----------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
to_load  <- list( "colorspace",
                  "DBI",
                  "dbplyr",
                  "dplyr",
                  "ggplot2",
                  "lazyeval",
                  "magrittr",
                  "packrat",
                  "plyr",
                  "RSQLite",
                  "scales",
                  "svDialogs",
                  "viridis")


lapply(to_load, require, character.only = TRUE)


setwd("J:/EEG data/EEG_R")
ufunc <- list( "fheatmap.R",
               "group_mean.R",
               "equal_sub.R",
               "import_ale.R",
               "insert_freq.R",
               "jitterplot.R",
               "levelsort.R",
               "mean_bands.R",
               "no_lateral.R",
               "point_graph.R",
               "point_graph2.R",
               "remcorr.R",
               "remcorr2.r",
               "percent_baseline.R"
               )

sapply(ufunc, source, .GlobalEnv)

