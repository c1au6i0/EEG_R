install.packages("multcomp")
install.packages("nmle")

prism <- forprisms %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int)


prismg <- forprismg %>% 
  dplyr::filter(channel == "EEG_FRONT" & intervals_sec %in% int)

prism$drug_dose <- as.factor(prism$drug_dose)

library(multcomp)
library(nlme)


analisi <- function (x) {
  lme(PSD_perc ~ drug_dose, data=x, random = ~1|subject)
}

repmesure<- by(prism, prism$Bands, analisi)

anova_output <- map(repmesure, anova)



calc_posthocs <- function (x) {
  
  posthocs <- summary(glht(x, linfct=mcp(drug_dose = "Tukey")))
  
  posthocs <- as.data.frame(posthocs$test[3:6])
  posthocs["sign"] <- "no"
  posthocs$sign[which(posthocs$pvalues <= 0.05)] <- "yes"
  
  to_extr <- str_detect(row.names(posthocs), "[b]")
  
  basel_posthoc <-posthocs[to_extr,]
  
  basel_posthoc
  
}


map(repmesure, calc_posthocs)



prism$drug_dose <- as.factor(prism$drug_dose)
fitp <- lme(PSD_perc ~ drug_dose, data=prism, random = ~1|subject)
anova(fitp)

posthocs <- summary(glht(fitp, linfct=mcp(drug_dose = "Tukey")))



posthocs <- as.data.frame(posthocs$test[3:6])
posthocs["sign"] <- "no"
posthocs$sign[which(posthocs$pvalues <= 0.05)] <- "yes"

to_extr <- str_detect(row.names(posthocs), "[b]")

basel_posthoc <-posthocs[to_extr,]

basel_posthoc

