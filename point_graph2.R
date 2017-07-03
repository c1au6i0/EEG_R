#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Graph function -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# this is an updated function that allows more flexibility and to choose the variable to plot
# sel = list of frequencies or bands. it is used to create facets
# subt2 = subtitle graph
# seqbreaks = vector containing sequency of x axis break
# sp = size of the points
# perc = is it a percentage or not
# df = dataframe
# lerr is the column that contain the error
# use as.name to use variables....

point_graph2 <- function(df, yaes, lerr, perc, sp, sel, subt2, seqbreaks) {
  
  #sp size points
  if (missing(sp) || sp == "A") {  sp <- (17/(max(df$intervals_sec)/df$intervals_sec[1])) }
  csp <-  sp + sp/2
  
  #limit x
  lx <- c(0 - min(df$intervals_sec/60), max(df$intervals_sec/60) + min(df$intervals_sec/60))
  
  
  # breaks axis
  yseqbreaks <- seq(0, max(df[, yaes]) + 10, by = 5)

  # title changes depending on subject/ group
    if ("subject" %in% names(df) ) {
    gtitle <- paste0( df$date[1]," ",  df$subject[1], " ", drug )
  } else {
    gtitle <- paste0(drug, " group means")
  }
  

  # Y lab and name file
  answ <- list("yes","Yes", "YES","y", "Y")
  # check if argument is present
  if (missing(perc) || !perc %in% answ ) {
    prefix <- "Absolute_"
  } else {
    prefix <- "Perc_"
  }
  
  
  if ( missing(lerr) ) {
      ylab <- yaes
  } else {
      ylab<- paste0(yaes, " + ", lerr)
  }

  #error bars
  df[, "emax"] <- df[, yaes ] + df[, lerr ]  
  df[, "emin"] <- df[, yaes ] - df[, lerr ]  

  mean_point <-
    ggplot(df, aes_string("intervals_sec/60", as.name(yaes), colour = "drug_dose")) +
    geom_line(colour = "grey20") +
    geom_errorbar(aes(ymax = emax, ymin = emin), colour = "grey20") +
    geom_point(size = csp, colour = "grey20", show.legend = TRUE) +
    geom_point(size = sp) +
    scale_color_brewer(palette = "Set1") +
    facet_grid(as.formula(paste(sel,"~","channel")), scales = "free_y") +
    scale_x_continuous( expand = c(0,0), breaks = seqbreaks, limits = lx  ) +
    labs(x = "Time (min)",
         y = ylab,
         colour = "Dose (mg/kg)",
         element_text(face = "bold"),
         title = gtitle,
         subtitle = paste0("Channels ", "X ",   subt2 )
    ) +
    theme(
      strip.background  = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(face = "bold", hjust = 0.5),
      legend.key = element_blank(),
      legend.title = element_text(face = "bold", hjust = 0.5),
      legend.background = element_rect ( color = "grey20"),
      strip.text = element_text(size=8, face = "bold"),
      axis.text = element_text(size = 6, face = "bold"),
      plot.caption = element_text(vjust = 1),
      panel.grid.major = element_line(colour = "white"),
      panel.grid.minor = element_line(colour = "white")
      # panel.background = element_rect(fill = "white")
    )
  

#  ggsave(filename = paste0(prefix, gtitle, "_", interv, "_sec_interv.pdf"), plot = mean_point, device = "pdf",  width = 11, height = 8.5)
    
  mean_point

}


# point_graph2(df = fmeans_eeg,  yaes = "Mean_PSD", lerr= "SD", sp= "A", subt2 = subt2, sel = sel, seqbreaks = seqbreaks)



