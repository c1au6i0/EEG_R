

  
  part <- subset(fsmeans_eeg, fsmeans_eeg$subject == "RAT16" | fsmeans_eeg$subject == "RAT12"
                 | fsmeans_eeg$subject == "RAT18") 
  
  
  part <- fsperc_eeg
  
  part$Bands <- factor( part$Bands, levels = c("Delta","Theta", "Alpha", "Beta", "Gamma") ) 
  
  jitterplot <- ggplot(part , aes(intervals_sec/60, Percent_baseline, colour = drug_dose, shape = subject)) + 
     geom_line() +
    geom_jitter() +
    facet_grid(as.formula(paste("Bands","~","channel")), scales = "free_y") +
    scale_color_brewer(palette = "Set1") +
    scale_x_continuous( expand = c(0,0), breaks = seq(0, max(alleeg$time_sec/60), by = injection_int/60), 
                        limits = c(0 - min(fsmeans_eeg$intervals_sec/60), max(fsmeans_eeg$intervals_sec/60) + 
                                                                          min(fsmeans_eeg$intervals_sec/60))  ) +
    labs(x = "Time (min)",
       y = "% PSD  (dB)",
       colour = "Dose (mg/kg)",
       element_text(face = "bold"),
       title = "Single Subjects",
       subtitle = paste0("Channels X Bands" )
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
  scale_shape_manual(values = c(0,1,2,15,16,17) )


ggsave(filename = "jitterplot2.pdf", plot = jitterplot , device = "pdf",  width = 11, height = 8.5)
       