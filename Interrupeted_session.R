source("J:/EEG data/EEG_R/start.R")


setwd(choose.dir())
dirs <- basename(list.dirs())
file <- list.files(include.dirs=FALSE)
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv|RData", file)]

file <- file[!file %in% nread]


# list of files to import
RAT20 <- pblapply(file, function (x) read.csv( x , header = TRUE, sep = "," ))

names(RAT20) <- LETTERS[1: length(RAT20)]

# max(RAT20_A$Time)

# starting times
stl <- c("170718_143840", "170718_145702", "170718_152357", "170718_153002")

# trasform in format Posixcl
st_time <- lapply(stl, function (x) strptime(x, format = "%y%m%d_%H%M%S"))

# as.numeric(difftime(st_time[2:4],st_time[1:3], units = "sec"))


# find the difference in seconds between 2 Posixcl values
time_dif <- function (a, b) {
  
  as.numeric(difftime(a,b, units = "sec"))
  
}

# time that needs to be added  
toadd  <- mapply (time_dif, st_time[2:4], rep(st_time[1],3))

# round up
toadd  <- ceiling(toadd/5)*5



# add time

addtime <-  function (x, y) {
         x[, "Time"]  <- x[, "Time"] + y
  
        x
}


prova     <-  mapply ( addtime,
              RAT20[2:length(RAT20)],
              toadd,
              SIMPLIFY = FALSE
     )

       
RAT20_int <- Reduce(function(...) merge(..., all=T),   prova )


RAT20_int <- rbind(RAT20$A, RAT20_int)

write.csv (RAT20_int, file = "RAT20_int.csv", row.names = F)




