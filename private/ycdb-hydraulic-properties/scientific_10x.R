
# modified from https://github.com/jpshanno/ecoflux/blob/master/R/Helper_Functions.R


scientific_10x <- function(v1, digits = 1) {

  x <- sprintf(paste0("%.", digits, "e"), v1)
  
  x <- gsub("^(.*)e", "'\\1'e", x)
  
  longestExponent <- max(sapply(gregexpr("\\d{1,}$", x), attr, 'match.length'))
  zeroTrimmed <- ifelse(longestExponent > 2,
                        paste0("\\1", paste(rep("~", times = longestExponent-1), collapse = "")),
                        "\\1")
  x <- gsub("(e[+|-])[0]", zeroTrimmed, x)
  
  x <- gsub("e", "~x~10^", x)
  
  if(any(grepl("\\^\\-", x))){
    x <- gsub("\\^\\+", "\\^~~", x)
  } else {
    x <- gsub("\\^\\+", "\\^", x)
  }

  parse(text=x)
} 


