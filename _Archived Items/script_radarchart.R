

source("J:/EEG data/EEG_R/script_start.R")



all <- read.csv("J:\\EEG data\\Claudio output files\\for prism\\PSD1\\Frontal mean\\allforstellar.csv", 
                sep = ",", stringsAsFactors = F, row.names = 1 )

row.names(all)[5] <- "methylphenidate"

order_col <- c("Theta", "Delta", "Gamma", "Beta", "Alpha")

all <- all[, order_col]

# Standard --------------------------------------------------------------------------------------
tokeep <- c(1, 2, 3, 4, 5)

standard <- all[tokeep,]
standard["axmax",] <- 110
standard["axmin",] <- 70

# pty = 32 is for no point.

c_cocaine <- rgb(225, 193 ,0, max = 255)
c_methylphenidate <-rgb(68, 114, 196, max = 255)

radarchart2(standard,
    
           #Grid and axis
           axistype = 1,
           cglcol="black",
           cglty=1, 
           axislabcol="black", 
           caxislabels= seq(70,110,10),
           cglwd= 1,
           calcex = 1.2,
           
           #labels
           vlcex=1.5,
           
           # #Polygons
           # pcol=colors_border, 
           # pfcol=colors_border , 
           # plwd=4 ,
           # plty=1,
           
           
           #symbols and lines
           plwd = c(3, 4, 4),	
           plty = c(5, 1, 1),
           pty = c(31, 16, 16),
           cex = 3,
           pcol = c("black", c_cocaine, c_methylphenidate )
           )

# this to scale the coordinates
n <- 5
seg <-  4
centerzero <- FALSE
theta <- seq(90, 450, length = n + 1) * pi/180
theta <- theta[1:n]
xx <- cos(theta)
yy <- sin(theta)
CGap <- ifelse(centerzero, 0, 1)

#error bar cocaine

data <- standard

errdown <- standard["cocaine", ] - all["err_cocaine",]
errup <-  standard["cocaine", ] + all["err_cocaine",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_cocaine,
          lwd = 4
          )


#error bar methylphenidate

data <- standard

errdown <- standard["methylphenidate", ] - all["err_methylphenidate",]
errup <-  standard["methylphenidate", ] + all["err_methylphenidate",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_methylphenidate,
          lwd = 4
)

# Atypical --------------------------------------------------------------------------------------

# 100, cocaine, mJBF1048, modafinil, JHW007
tokeep <- c(1, 2, 3, 4, 6, 7, 8)

atypical <- all[tokeep,]
atypical["axmax",] <- 110
atypical["axmin",] <- 70

# pty = 32 is for no point.

c_cocaine <- rgb(225, 193 ,0, max = 255)
c_mJBF1048 <- rgb(255, 0, 250, max = 255)
c_modafinil <-rgb(96, 96, 96, max = 255)
c_JHW007 <-rgb(148, 100, 31, max = 255)

radarchart2(atypical,
            
            #Grid and axis
            axistype = 1,
            cglcol="black",
            cglty=1, 
            axislabcol="black", 
            caxislabels= seq(70,110,10),
            cglwd= 1,
            calcex = 1.2,
            
            #labels
            vlcex=1.5,

            #symbols and lines
            
            # 100%, "cocaine" "mJBF1048", "modafinil", "JHW007"
            plwd = c(3, 3, 4, 4, 4),	
            plty = c(5, 1, 1, 1, 1),
            pty = c(31, 31, 16, 16, 15),
            cex = 3,
            pcol = c("black", c_cocaine, c_mJBF1048, c_modafinil, c_JHW007 )
)

# this to scale the coordinates
n <- 5
seg <-  4
centerzero <- FALSE
theta <- seq(90, 450, length = n + 1) * pi/180
theta <- theta[1:n]
xx <- cos(theta)
yy <- sin(theta)
CGap <- ifelse(centerzero, 0, 1)

#error bar "mJBF1048"

data <- atypical

errdown <- atypical["mJBF1048", ] - all["err_mJBF1048",]
errup <-  atypical["mJBF1048", ] + all["err_mJBF1048",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_mJBF1048,
          lwd = 4
)


#error bar modafinil

data <- atypical

errdown <- atypical["modafinil", ] - all["err_modafinil",]
errup <-  atypical["modafinil", ] + all["err_modafinil",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_modafinil,
          lwd = 4
)

#error bar JHW007

data <- atypical

errdown <- atypical["JHW007", ] - all["err_JHW007",]
errup <-  atypical["JHW007", ] + all["err_JHW007",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_JHW007,
          lwd = 4
)

# Controls --------------------------------------------------------------------------------------

# 100, cocaine, "heroin", "morphine", "ketamine"  
tokeep <- c(1, 2, 3, 4, 9, 10, 11)

control <- all[tokeep,]
control["axmax",] <- 160
control["axmin",] <- 50

# pty = 32 is for no point.

c_cocaine <- rgb(225, 193 ,0, max = 255)
c_heroin <- rgb(249, 64, 64, max = 255)
c_morphine <-rgb(0, 204, 0, max = 255)
c_ketamine <- rgb(96, 96, 96, max = 255)

radarchart2(control,
            
            #Grid and axis
            axistype = 1,
            cglcol="black",
            cglty=1, 
            axislabcol="black", 
            seg = 11,
            caxislabels= seq(50,160,10),
            cglwd= 1,
            calcex = 1.2,
            
            #labels
            vlcex=1.5,
            
            #symbols and lines
            
            # 100%, "cocaine" "mJBF1048", "modafinil", "JHW007"
            plwd = c(3, 3, 4, 4, 4),	
            plty = c(5, 1, 1, 1, 1),
            pty = c(31, 31, 16, 16, 15),
            cex = 3,
            pcol = c("black", c_cocaine, c_heroin, c_morphine, c_ketamine )
)

# this to scale the coordinates
n <- 5
seg <-  11
centerzero <- FALSE
theta <- seq(90, 450, length = n + 1) * pi/180
theta <- theta[1:n]
xx <- cos(theta)
yy <- sin(theta)
CGap <- ifelse(centerzero, 0, 1)

#error bar "heroin"

data <- control

errdown <- control["heroin", ] - all["err_heroin",]
errup <-  control["heroin", ] + all["err_heroin",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_heroin,
          lwd = 4
)


#error bar morphine

data <- control

errdown <- control["morphine", ] - all["err_morphine",]
errup <-  control["morphine", ] + all["err_morphine",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_morphine,
          lwd = 4
)

#error bar ketamine

data <- control

errdown <- control["ketamine", ] - all["err_ketamine",]
errup <-  control["ketamine", ] + all["err_ketamine",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_ketamine,
          lwd = 4
)





# Antagonism --------------------------------------------------------------------------------------

row.names(all)[12] <- "morphine_naltrex"
row.names(all)[21] <- "err_morphine_naltrex"

# 100, cocaine, "morphine", "morphine_naltrex" 
tokeep <- c(1, 2, 3, 4, 10, 12)

antagonism <- all[tokeep,]
antagonism["axmax",] <- 160
antagonism["axmin",] <- 50

# pty = 32 is for no point.

c_cocaine <- rgb(225, 193 ,0, max = 255)
c_morphine <-rgb(0, 204, 0, max = 255)
c_morphine_naltrex <-"black"

radarchart2(antagonism,
            
            #Grid and axis
            axistype = 1,
            cglcol="black",
            cglty=1, 
            axislabcol="black", 
            seg = 11,
            caxislabels= seq(50,160,10),
            cglwd= 1,
            calcex = 1.2,
            
            #labels
            vlcex=1.5,
            
            #symbols and lines
            
            # 100, cocaine, "morphine", "Morphine+0.032Naltrex" 
            plwd = c(3, 3, 4, 2),	
            plty = c(5, 1, 1, 1),
            pty = c(31, 31, 16, 1),
            cex = 3,
            pcol = c("black", c_cocaine, c_morphine, c_morphine_naltrex ),
            lwd = c(3, 3, 4, 2)
)

# this to scale the coordinates
n <- 5
seg <-  11
centerzero <- FALSE
theta <- seq(90, 450, length = n + 1) * pi/180
theta <- theta[1:n]
xx <- cos(theta)
yy <- sin(theta)
CGap <- ifelse(centerzero, 0, 1)

#error bar morphine

data <- antagonism

errdown <- antagonism["morphine", ] - all["err_morphine",]
errup <-  antagonism["morphine", ] + all["err_morphine",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_morphine,
          lwd = 4
)

#error morphine+naltrex

data <- antagonism

errdown <- antagonism["morphine_naltrex", ] - all["err_morphine_naltrex",]
errup <-  antagonism["morphine_naltrex", ] + all["err_morphine_naltrex",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_morphine_naltrex,
          lwd = 4
)
errdown


antagonism["morphine_naltrex", ]

raw.names(antagonism)
