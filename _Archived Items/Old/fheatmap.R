#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
# Heatmaps ----------------------------------------------------------------
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

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
