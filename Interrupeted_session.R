# load packages and scripts
source("J:/EEG data/EEG_R/start.R")

setwd(choose.dir())
dirs <- basename(list.dirs())
file <- list.files(include.dirs=FALSE)
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv|RData", file)]

file <- file[!file %in% nread]


# list of files to import
RAT24 <- pblapply(file, function (x) read.csv( x , header = TRUE, sep = "," ))

names(RAT24) <- LETTERS[1: length(RAT24)]

# max(RAT24_A$Time)

# starting times
stl <- c("170822_150944", "170822_161814")

# trasform in format Posixcl
st_time <- lapply(stl, function (x) strptime(x, format = "%y%m%d_%H%M%S"))

# as.numeric(difftime(st_time[2:4],st_time[1:3], units = "sec"))


# find the difference in seconds between 2 Posixcl values
time_dif <- function (a, b) {
  
  as.numeric(difftime(a,b, units = "sec"))
  
}

# time that needs to be added  
toadd  <- mapply (time_dif, st_time[2:length(st_time)], rep(st_time[1],length(st_time) - 1))

# round up
toadd  <- ceiling(toadd/10)*10



# add time

addtime <-  function (x, y) {
         x[, "Time"]  <- x[, "Time"] + y
  
        x
}


#add time to each of the elments of the list of interrupted sessions
prova     <-  mapply ( addtime,
              RAT24[2:length(RAT24)],
              toadd,
              SIMPLIFY = FALSE
     )

       
RAT24_int <- Reduce(function(...) merge(..., all=T),   prova )


RAT24_int <- rbind(RAT24$A, RAT24_int)

write.csv (RAT24_int, file = "RAT24_int.csv", row.names = F)

tail(RAT24$A$Time)
head(RAT24_int$Time)



rm(list = ls()[!ls() %in% "RAT24_int"])
