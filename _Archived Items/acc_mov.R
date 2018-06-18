library("reticulate")
library("pracma")

lib_acc <-  import_from_path("lib_acc", "J:/EEG data/EEG_R")


mod_aux <- sqrt(unlist(aux_ch[1])^2 + unlist(aux_ch[2])^2 + unlist(aux_ch[3])^2)

mod_aux_st <- sqrt(((mod_aux-mean(mod_aux))/sd(mod_aux))^2)

mod_aux_nr <- mod_aux_st[seq(1, length(mod_aux_st),4)]


peaks <- as.data.frame(findpeaks(mod_aux_nr, minpeakheight = 2, minpeakdistance = 500 ))


 
 nrow(peaks[peaks$V2 <= (500*30*60) &  peaks$V2 >= (500*25*60), ])
 
 nrow(peaks[peaks$V2 <=  (500*60*60) &  peaks$V2 >= (500*55*60), ])
 
 nrow(peaks[peaks$V2 <=  (500*90*60) &  peaks$V2 >= (500*85*60), ])
 
 nrow(peaks[peaks$V2 <=  (500*120*60) &  peaks$V2 >= (500*115*60), ])
 

li <- peaks[peaks$V2 <= (500*30*60) &  peaks$V2 >= (500*25*60), ]
# mod_filt <- as.vector(lib_acc$filter_acc(x = mod_aux, wp = 0.5, ws = 0.1))


# mod_sfilt <- sqrt(mod_filt^2)


her_aux <-  mod_aux_nr
her_peaks <- peaks

plot(mod_aux_nr[ (500*25*60):(500*30*60)],
     type = "l"
     )

points(x = (li$V2 -500*25*60)  , y = li[,1])



