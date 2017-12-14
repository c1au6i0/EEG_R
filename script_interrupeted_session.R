# load packages and scripts
source("J:/EEG data/EEG_R/start.R")

setwd(choose.dir())
dirs <- basename(list.dirs())
file <- list.files(include.dirs=FALSE)
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv|RData", file)]

file <- file[!file %in% nread]


# list of files to import
RAT19 <- pblapply(file, function (x) read.csv( x , header = TRUE, sep = "," ))

names(RAT19) <- LETTERS[1: length(RAT19)]

# max(RAT19_A$Time)

# starting times
stl <- c("170825_144917", "170825_163323")

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
              RAT19[2:length(RAT19)],
              toadd,
              SIMPLIFY = FALSE
     )

       
RAT19_int <- Reduce(function(...) merge(..., all=T),   prova )


RAT19_int <- rbind(RAT19$A, RAT19_int)

write.csv (RAT19_int, file = "RAT20_int.csv", row.names = F)

tail(RAT19$A$Time)
head(RAT19_int$Time)



rm(list = ls()[!ls() %in% "RAT19_int"])
