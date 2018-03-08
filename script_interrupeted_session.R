# load packages and scripts
source("J:/EEG data/EEG_R/script_start.R")

setwd(choose.dir())
dirs <- basename(list.dirs())
file <- list.files(include.dirs=FALSE)
file <- file[!file %in% dirs]

nread <- file[grepl("*pdf|*lnk|*txt|Doses.csv|RData", file)]

file <- file[!file %in% nread]


# list of files to import
RAT <- pblapply(file, function (x) read.csv( x , header = TRUE, sep = "," ))

names(RAT) <- LETTERS[1: length(RAT)]

# max(RAT_A$Time)

# starting times
stl <- c("180301_150957", "180301_153608")

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
              RAT[2:length(RAT)],
              toadd,
              SIMPLIFY = FALSE
     )

       
RAT_int <- Reduce(function(...) merge(..., all=T),   prova )


RAT_int <- rbind(RAT$A, RAT_int)



tail(RAT$A$Time)
head(RAT$B$Time)
head(RAT_int$Time)
plot(unique(RAT_int$Time), seq_along(unique(RAT_int$Time)), type = "l")

write.csv (RAT_int, file = "RAT_int.csv", row.names = F)
rm(list = ls()[!ls() %in% "RAT_int"])
