# install.packages("multcomp")
# install.packages("nmle")

library(multcomp)
library(nlme)
library(purrr)
library(stringr)

tbdrug <- "methylphenidate"

# setwd("C:\\Users\\zanettinic\\Desktop\\Analysis")

prism <- forprisms %>% 
  dplyr::filter(channel == "EEG_FRONT" & 
                  intervals_sec %in% int)

mydb <- dbConnect(RSQLite::SQLite(), "J:/EEG data/EEG_R/my-db.sqlite")

dbWriteTable(mydb, "allfront", prism)
dbDisconnect(mydb)

# prismg <- forprismg %>% 
#   dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int)
# 
# prism$drug_dose <- as.factor(prism$drug_dose)

# 
# prism$drug_dose

# 



# Recode ----------------------------

doses <- as.character(unique(prism$drug_dose))
comp <- LETTERS [seq_along(doses)]

newnames <- setNames(comp, doses)


prism[, "comp"] <- newnames[prism$drug_dose]
prism$comp <- as.factor(prism$comp)


# ANOVA ----------------------------

analisi <- function (x) {
  lme(PSD_perc ~ comp, data=x, random = ~1|subject)
}

# repmeasure <- lme(PSD_perc ~ comp, data=prism, random = ~1|subject)

# anova(repmeasure)

repmesure<- by(prism, prism$Bands, analisi)

anova_output <- map(repmesure, anova)

anova_output <- do.call("rbind", anova_output)


# We don't care about the intercept
anova_output <- anova_output[anova_output$numDF > 1, ]

anova_output
write.csv(anova_output, 
          file = paste0("J:\\EEG data\\Claudio output files\\for prism\\Updated\\Analysis\\", tbdrug,"_ANOVA.csv"))


#Post-hoc part------------------------------

# summary(glht(repmeasure, linfct=mcp(comp = "Dunnett"))

calc_posthocs <- function (x) {
  
  all <- summary(glht(x, linfct=mcp(comp = "Dunnett")))
  

  posthocs <- as.data.frame(all$test[3:6])
  posthocs["sign"] <- "no"
  posthocs$sign[which(posthocs$pvalues <= 0.05)] <- "yes"
  
  posthocs
}



posthocs <-  map(repmesure, calc_posthocs)


posthocs <- do.call("rbind", posthocs)

posthocs
write.csv(anova_output,
          file = paste0("J:\\EEG data\\Claudio output files\\for prism\\Updated\\Analysis\\", tbdrug,"_posthocs.csv"))



dbListTables(mydb)

