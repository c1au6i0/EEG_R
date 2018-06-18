library("reticulate")
library("quantmod")
# some of these functions were originally created by Alessandro Scaglione using Python in
# April 2017

# importing libraries
main <- import_main()
py <- import_builtins()
np <- import("numpy")

spsi <- import("scipy.signal") 
pdb <-  import("pdb")




mod_aux <- sqrt(unlist(aux_ch[1])^2 + unlist(aux_ch[2])^2 + unlist(aux_ch[3])^2)

mod_aux_st <- (mod_aux - mean(mod_aux))/sd(mod_aux)




filter_acc <- function ( x, gpass = 0.1, gstop = 50., sf = headers$sampr) {
  
  wp = 0.5 / (sf / 2.0)
  ws = 0.01 / (sf / 2.0)
  
  b_a <- spsi$iirdesign(wp, ws, gpass, gstop)
  
  acc <- spsi$filtfilt(unlist(b_a[1]),unlist(b_a[2]), x)
  
  as.vector(acc)
}


mod_aux_ft <- filter_acc(mod_aux_st)











movement_index <- function (x, sens = 1, sf = headers$sampr) {
  
    threshold <-  sens * median(abs(x)) / 0.6745
  
    kernel  <-  spsi$hanning(ceiling(0.5 * headers$sampr), "True")
    kernel <-  kernel / sum(kernel)
  
    peaks <- findPeaks(x, threshold)
    
    spsi$convolve(peaks, kernel, 'same')
    
    
}


    
prova <- movement_index(mod_aux_ft)

prova





# def movement_index(x, sensitivity=1, sf=2000):
#   
#   x = filter_acc(x)
# 
# threshold = sensitivity * np.median(abs(x)) / 0.6745
# 
# peaks, values = find_peaks(x, threshold, return_extrema=True)
# tmp = np.full(peaks.max() + 1, 0.)
# tmp[peaks] = values
# peaks = tmp
# 
# kernel = spsi.hanning(int(0.5 * 2000), True)
# kernel = kernel / sum(kernel)
# 
# return spsi.convolve(peaks, kernel, 'same')
# 
# 
# 
# 
# 




ch_filt <- filter_acc( x = aux_ch[1])

































plot(x = prova,  y = 1:length(prova),
     type = "l",
     ylab = "Cumulative events"
)
lines(mod_aux_st, col = 2)
legend()


aux_x[2000:4000]
