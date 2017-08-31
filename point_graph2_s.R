# point_graph2 applyed to each subject of the dataframe


point_graph2_s <- function (dat, yaes, lerr, perc, sp, sel, subt2, seqbreaks) {
  
  dat  <- as.data.frame(dat)

  by(dat, dat$subject, point_graph2, yaes, lerr, perc, sp, sel, subt2, seqbreaks)
  
}