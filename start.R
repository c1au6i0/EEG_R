

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
                  "pbapply",
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
               "import_sqltb.R", 
               "insert_freq.R",
               "jitterplot.R",
               "levelsort.R",
               "mean_bands.R",
               "no_lateral.R",
               "percent_baseline.R",
               "point_graph.R",
               "point_graph2.R",
               "point_graph2_s.R",
               "remcorr.R",
               "remcorr2.R"
               )

sapply(ufunc, source, .GlobalEnv)

