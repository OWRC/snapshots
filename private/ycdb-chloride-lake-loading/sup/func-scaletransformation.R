

scale.transformation <- function(df, fit) {
  #################################
  # from https://stackoverflow.com/questions/49137824/ggplot-scale-transformation-inaccurate-for-stat-function
  x <- rlnorm(1000, mean = fit$estimate[[1]], sd = fit$estimate[[2]])
  
  ## generate sequence of x values for the curve.
  xx <- 10^seq(min(log10(x)), max(log10(x)), length = 1000)
  ## Calculated the density for each xx value.
  ## Here, density is based on the lognormal distribution.
  pdf <- dlnorm(xx,  fit$estimate[[1]], fit$estimate[[2]])
  
  ## Repeat for log(xx).
  xx_ln <- log(xx)
  ## This density is based on the normal distribution.
  pdf_norm <- dnorm(xx_ln,  fit$estimate[[1]], fit$estimate[[2]])
  
  ## As a reminder, the pdf's for the distributions are different:
  head(cbind(pdf, pdf_norm))
  
  ### When looking at the data on a log10-scale, it will also have a different pdf. The function and code below transforms the normal pdf into a pdf for the log10-scale.
  
  ## Function: numerical integration stuff for log10 distribution plots
  ## essentially transforms pdf_norm to log10 base.
  ## step_size = Riemann sum-- step size to integrate over.
  ## x_10 = x values after a log10-transformation
  ## pdf_norm == pdf values for normal distribution (see above)
  num_int <- function(df){
    df$step_size <- c(diff(df$xx_10), NA)
    int <- sum(df$step_size * df$pdf_norm, na.rm = T)
    return(data.frame(int))
  }
  
  ## to complete the numerical integration, need log10(values)
  xx_10 <- log10(xx)
  curve_df <- data.frame(xx, xx_10, pdf, pdf_norm)
  int <- num_int(curve_df)
  curve_df$pdf_10 <- curve_df$pdf_norm / as.numeric(int)
  
  ## replace Inf rows with NA
  ## (not necessary with the example code)
  curve_df %>%
    mutate(pdf = replace(pdf, pdf == Inf, NA),
           pdf_norm = replace(pdf_norm, pdf_norm == Inf, NA),
           pdf_10 = replace(pdf_10, pdf_10 == Inf, NA))
}
