# For windows unquote
# source("J:/EEG data/EEG_R/Scripts/start.R")

source("/Users/NCCU/Documents/EEG_R/script_start.R")


# SET Directory to analyze and list of files ---- 
f_here <- dlgDir()$res


setwd(f_here)

# mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/PSD1_examples.sqlite")
mydb <- dbConnect(RSQLite::SQLite(), "/Users/NCCU/Documents/EEG_R/PSD1_examples.sqlite")


dbListTables(mydb)
front <- unlist(as.data.frame(tbl(mydb,    "RAT24_2017-06-27_Ketamine_FCumul_1_10_0.5_30_30_i.v.txt"                 )))



# min start
st <- 93.55
#snipet lenghtn in min
lgsn <- 0.05


y <- front[ (st*60*2000):(st*60*2000 + lgsn* 60 * 2000)]

x <- seq_along(y)/2000

plot(x, y, type = "l",
     
     xlab = "sec",
     ylab = "microV",
     ylim = c(-200, 200)
)



