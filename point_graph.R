#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Graph function -----------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# needs "sel", and subt2


point_graph <- function(x, sp, perc) {
  
  #sp size points
  if (missing(sp)) {  sp <- (max(x$intervals_sec) / interv) / 18 }
  
  csp <-  sp + sp/2
  
  
  lx <- c(0 - min(x$intervals_sec/60), max(x$intervals_sec/60) + min(x$intervals_sec/60))
  lerr <- aes(ymax = Mean_PSD + SD/sqrt(n), ymin= Mean_PSD - SD/sqrt(n))
  
  # breaks axis
  yseqbreaks <- seq(0, max(x$Mean_PSD)+10, by = 5)
  
  #title changes depending on subject/ group
  if ("subject" %in% names(x) ) {
    gtitle <- paste0( x$date[1]," ",  x$subject[1], " ", drug )
  } else {
    gtitle <- paste0(drug, " group means")
    
  }
  
# Y lab  
answ <- list("yes","Yes", "YES","y", "Y")


  
if (missing(perc) || !perc %in% answ ) {
  ylab <- "PSD  (dB) and St.Err"
  prefix <- "Absolute_" 
} else {
  ylab <- " % baseline PSD  (dB) and St.Err"
  prefix <- "Perc_" 
}

  
  mean_point <-
    ggplot(x, aes(intervals_sec/60, Mean_PSD,  colour = drug_dose)) +
    geom_line(colour = "grey20") +
    geom_errorbar(lerr, colour = "grey20") +
    geom_point(size = csp, colour = "grey20", show.legend = TRUE) + 
    geom_point(size = sp) +
    scale_color_brewer(palette = "Set1") +
    facet_grid(as.formula(paste(sel,"~","channel")), scales = "free_y") +
    scale_x_continuous( expand = c(0,0), breaks = seqbreaks, limits = lx  ) +
    # scale_y_continuous( expand = c(0,0), breaks = seq(0, max(x$Mean_PSD)+10, by = 5),
    #                     limits = c(0, max(x$Mean_PSD)+10 )) +
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
      axis.text = element_text(size = 6, face = "bold")
      # plot.caption = element_text(vjust = 1), 
      # panel.grid.major = element_line(colour = "gray93"), 
      # panel.grid.minor = element_line(colour = "gray93"), 
      # panel.background = element_rect(fill = "white")
    )
  
  ggsave(filename = paste0(prefix, gtitle, "_", interv, "_sec_interv.pdf"), plot = mean_point, device = "pdf",  width = 11, height = 8.5)
  
  
}