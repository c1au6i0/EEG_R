# 06 01 2018
# This is for import reshape and summarize some of locomotor activity data


require(readxl)
require(tidyr)


sheets <- c(2,3,4)

# SET Directory to analyze and list of files ---- 
f_here <- dlgDir()$res
setwd(f_here)
files <- list.files(include.dirs=FALSE)

# Get excel files
toimp <-  files[grepl("*xls", files)]

# filel <- dlgOpen()$res

# Function to import data

imp_loc <- function (filel, sheets) {
  singexp <- map(sheets, read_xls, path = filel)
  singexp[[1]][, "Experiment"] <- singexp[[2]][1, 1]
  
  singexp[[1]][, "Date"] <-  singexp[[3]][1, 9]
  
  #single experiment collapsed together
  singexp_c <- singexp[[1]]
  
  singexp_c[, "Computer"] <- str_extract(filel, "COMP[1-4]")
  
  singexp_c
}


# Data imported and saved in all.xls
all <-  map_df(toimp, imp_loc, sheets = sheets)

write.csv(all, file = "all.csv", row.names = F)

# Define Drug and Dose (this is going to be a pain)

all[, "Drug"] <- NA
all[, "Dose"] <- NA
# all$Date[all$Date == "4/27/2005"] <- "12/16/2014"
# all$Date[all$Date == "10/22/2007"] <- "12/16/2014"
# all$Date[all$Date == "10/25/2007"] <- "12/16/2014"

library(tidyverse)

all <-  read_xlsx(dlg_open()$res, sheet = 1)

all <- rename(all, "Block_No" = 'Block No')
all <- rename(all, 'Stereotypic_Counts' = 'Stereotypic Counts')
all<- rename(all, 'Vertical_Counts' = 'Vertical Counts')


stereotipies <- all %>% group_by(Drug, Dose, Block_No) %>% 
          summarise(avg = mean(Stereotypic_Counts),
                    stdev =sd(Stereotypic_Counts),
                    subj = n()
 )

verticalc <- all %>% group_by(Drug, Dose, Block_No) %>% 
  summarise(avg = mean(Vertical_Counts),
            stdev =sd(Vertical_Counts),
            subj = n()
  )


setwd(dlg_dir()$res)

write.csv(file = "stereotipies.csv", stereotipies, row.names = F)
write.csv(file = "verticalc .csv", verticalc , row.names = F)

glimpse(pr)
pr
warnings()
