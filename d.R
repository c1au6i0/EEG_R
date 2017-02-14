


fheatmap <- function (x) { 
  gtitle <- paste0( alleeg_date," ",  x$subject[1], " ", drug )
  
  grapheat <-
  ggplot(x, aes(time_sec/60, frequency_eeg)) +
    geom_raster(aes(fill = PSD ))
  
  ggsave(filename = paste("heatmap ", gtitle, ".pdf", sep =""), plot = grapheat, device = "pdf",  width = 11, height = 8.5)
  
  
  
}

by(alleeg, alleeg$subject, prova)


rm(prova)