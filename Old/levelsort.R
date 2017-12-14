# Function to sort levels of a DF factor. 
levelsort <- function(x) {
  factor(   x, levels =   sort(as.character(levels(x))) )
} 
