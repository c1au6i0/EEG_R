
# Graph function group -----------------
point_graph2 <- function(df, yaes, lerr, perc, sp, sel, subt2, seqbreaks) {
  
  # this is an updated function that allows more flexibility and to choose the variable to plot
  # sel = list of frequencies or bands. it is used to create facets
  # subt2 = subtitle graph
  # seqbreaks = vector containing sequency of x axis break
  # sp = size of the points
  # perc = is it a percentage or not
  # df = dataframe
  # lerr is the column that contain the error
  # use as.name to use variables....


  #sp size points
  if (missing(sp) || sp == "A") {  sp <- (17/(max(df$intervals_sec)/df$intervals_sec[1])) }
  csp <-  sp + sp/2
  
  #limit x
  lx <- c(0 - min(df$intervals_sec/60), max(df$intervals_sec/60) + min(df$intervals_sec/60))
  
  
  # breaks axis
  yseqbreaks <- seq(0, max(df[, yaes]) + 10, by = 5)


  if ( missing(lerr) ) {
    ylab <- yaes
    df[, "emax"] <- df[, yaes ] 
    df[, "emin"] <- df[, yaes ]
    
    
  } else {
    ylab<- paste0(yaes, " + ", lerr)
    #error bars
    df[, "emax"] <- df[, yaes ] + df[, lerr ]  
    df[, "emin"] <- df[, yaes ] - df[, lerr ]  
  }
  
  
  # Y lab and name file
  answ <- list("yes","Yes", "YES","y", "Y")
  # check if argument is present
  if (missing(perc) || !perc %in% answ ) {
    prefix <- "Absolute_"
    ylab <- paste0(ylab, "(db)")
  } else {
    prefix <- "Perc_"
    # ylab <- "PSD Percent Baseline"
  }
  
  # title changes depending on subject/ group
  if ("subject" %in% names(df) ) {
    gtitle <- paste0( df$date[1],"_",  df$subject[1], "_", drug )
  } else {
    gtitle <- paste0(drug, "_group means")
    prefix <- paste0(prefix,"GROUP_")
  }
  

  

  # reordering levels of drug dose so that baseline is the first  
  df$drug_dose <- as.character(df$drug_dose)
  df$drug_dose <- factor(df$drug_dose, levels = append("baseline", unique(df$drug_dose)[!unique(df$drug_dose) == "baseline"]))


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

    )
  
  
  if (length(unique(df$channel)) %% 2 == 0 ) lat <- "lat" else lat <- "nolat"
  

  interv <- unique (df$intervals_sec)[2] - unique (df$intervals_sec)[1]
  
 ggsave(filename = paste0(prefix, gtitle, "_", lat, "_", interv, "_sec_interv.pdf"), plot = mean_point, device = "pdf",  width = 11, height = 8.5)
    
  # mean_point

}


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Graph function single subjects -----------------
point_graph2_s <- function (dat, yaes, lerr, perc, sp, sel, subt2, seqbreaks) {
  
  # point_graph2 applyed to each subject of the dataframe
  
  dat  <- as.data.frame(dat)
  
  by(dat, dat$subject, point_graph2, yaes, lerr, perc, sp, sel, subt2, seqbreaks)
  
}

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Jitterplot -----------------
jitterplot <- function(df, yaes, perc, sp, sel, subt2, seqbreaks) {
  # this is an updated function that allows more flexibility and to choose the variable to plot
  # sel = list of frequencies or bands. it is used to create facets
  # subt2 = subtitle graph
  # seqbreaks = vector containing sequency of x axis break
  # sp = size of the points
  # perc = is it a percentage or not
  # df = dataframe
  # use as.name to use variables....
  
  
  #sp size points
  if (missing(sp) || sp == "A") {  sp <- (17/(max(df$intervals_sec)/df$intervals_sec[1])) }
  csp <-  sp + sp/2
  
  #limit x
  lx <- c(0 - min(df$intervals_sec/60), max(df$intervals_sec/60) + min(df$intervals_sec/60))
  
  
  # breaks axis
  yseqbreaks <- seq(0, max(df[, yaes]) + 10, by = 5)
  
  ylab <- yaes
  
  # Y lab and name file
  answ <- list("yes","Yes", "YES","y", "Y")
  # check if argument is present
  if (missing(perc) || !perc %in% answ ) {
    prefix <- "Absolute_"
    ylab <- paste0(ylab, "(db)")
  } else {
    prefix <- "Perc_"
    ylab <- "PSD Percent Baseline"
  }
  
  
  gtitle <- paste0(drug, "_jitter")
  prefix <- paste0(prefix,"jitter_")
  
  
  
  # reordering levels of drug dose so that baseline is the first  
  # reordering levels of drug dose so that baseline is the first  
  df$drug_dose <- as.character(df$drug_dose)
  df$drug_dose <- factor(df$drug_dose, levels = append("baseline", unique(df$drug_dose)[!unique(df$drug_dose) == "baseline"]))
  
  
  
  jitterplot <-
    ggplot(df, aes_string("intervals_sec/60", as.name(yaes), colour = "drug_dose", shape = "subject" )) +
    geom_line() +
    geom_jitter() +
    scale_shape_manual(values = c(1, 0, 2, 6, 16, 15, 17, 18)) +
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
      
    )
  
  
  if (length(unique(df$channel)) %% 2 == 0 ) lat <- "lat" else lat <- "nolat"
  
  
  interv <- unique (df$intervals_sec)[2] - unique (df$intervals_sec)[1]
  
  ggsave(filename = paste0(prefix, gtitle, "_", lat, "_", interv, "_sec_interv.pdf"), plot = jitterplot, device = "pdf",  width = 11, height = 8.5)
  
  # mean_point
  
}


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Heatmaps ----------------------------------------------------------------
fheatmap <- function (x, subt, seqbreaks) { 
  gtitle <- paste0( x$date[1]," ",  x$subject[1], " ", drug ) 
  grapheat <-
    ggplot(x, aes(time_sec/60, frequency_eeg)) +
    geom_raster(aes(fill = PSD )) +
    facet_wrap(~ channel, ncol = 2) +
    scale_fill_viridis()+
    labs(x = "Time (min)",
         y = "Frequency (Hz)",
         fill = "Power (db)",
         title = paste(gtitle),
         subtitle = paste(subt)) +
    scale_x_continuous( expand = c(0,0), breaks = seqbreaks ) +
    scale_y_continuous( expand = c(0,0) ) +
    theme( plot.subtitle = element_text(hjust = 0.5),
           plot.caption = element_text(vjust = 1),
           plot.title = element_text(hjust = 0.5) )
  
  ggsave(filename = paste("heatmap ", gtitle, ".pdf", sep =""), plot = grapheat, device = "pdf",  width = 11, height = 8.5)
}
