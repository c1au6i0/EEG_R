

# load packages and scripts
if (Sys.info()["sysname"] != "Windows" ) {
  source("/Users/NCCU/Documents/EEG/EEG_R/script_start.R") } else {
    source("J:/EEG data/EEG_R/script_start.R")
  }  




all <- read.csv(dlgOpen()$res, 
                sep = ",", stringsAsFactors = F, row.names = 1 )

# row.names(all)[5] <- "methylphenidate"

order_col <- c("Theta", "Delta", "Gamma", "Beta", "Alpha")

all <- all[, order_col]

# standardcomb --------------------------------------------------------------------------------------
tokeep <- 1:5

standardcomb <- all[tokeep,]
standardcomb["axmax",] <- 110
standardcomb["axmin",] <- 70

# pty = 32 is for no point.

c_cocaine <- rgb(225, 193 ,0, max = 255)
c_jhwcombo <- 'black'

radarchart2(standardcomb,
    
           #Grid and axis
           axistype = 1,
           cglcol="grey",
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
           pty = c(31, 16, 5),
           cex = 3,
           pcol = c("black", c_cocaine, c_jhwcombo )
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

data <- standardcomb

errdown <- standardcomb["cocaine", ] - all["err_cocaine",]
errup <-  standardcomb["cocaine", ] + all["err_cocaine",]

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

data <- standardcomb

errdown <- standardcomb["cocaine+10JHW007", ] - all["err_cocaine+10JHW007",]
errup <-  standardcomb["cocaine+10JHW007", ] + all["err_cocaine+10JHW007",]

scaledwn <- CGap/(seg + CGap) + (errdown - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
scaleup  <- CGap/(seg + CGap) + (errup - data[2, ])/(data[1, ] - data[2, ]) * seg/(seg + CGap)
segments( as.double(xx * scaleup),
          as.double(yy * scaleup),
          as.double(xx * scaledwn),
          as.double(yy * scaledwn),
          col = c_jhwcombo,
          lwd = 4
)
