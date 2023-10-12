


library(odbc)
library(ggplot2)
library(dplyr)
library(scales)
library(MASS)
library(rgdal)

con <- dbConnect(odbc(), Driver = "SQL Server", Server = "sqlserver2k16", 
                 Database = "OAK_20160831_MASTER", UID = "sql-webmm", PWD = "fv62Aq31", 
                 Port = 1433)






create.histogram.with.modelled.distribution <- function(df) {
  # ## pick by location
  # # ormgp.region <- readOGR("E:/Sync/@dev/web_ormgp/sHydroNet/shp/ORMGP-region.geojson",verbose = FALSE)
  # coordinates(df) <- ~ LONG + LAT
  # proj4string(df) <- proj4string(ormgp.region)      
  # 
  # dft <- df@data
  # dft$LNG=df@coords[,1]
  # dft$LAT=df@coords[,2]
  # 
  # df <- dft[complete.cases(over(df, ormgp.region)),]
  
  
  
  # average by location
  df <- df %>%
    group_by(LOC_ID) %>%
    summarise(VALUE=max(VALUE, na.rm=TRUE))
  
  
  fit <- fitdistr(df$VALUE, "lognormal")
  med = median(df$VALUE)
  p5 = qlnorm(.05, mean = fit$estimate[[1]], sd = fit$estimate[[2]])
  p95 = qlnorm(.95, mean = fit$estimate[[1]], sd = fit$estimate[[2]])
  # print(fit$estimate[[1]])
  # print(fit$estimate[[2]])
  
  
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
  curve_df <- curve_df %>%
    mutate(pdf = replace(pdf, pdf == Inf, NA),
           pdf_norm = replace(pdf_norm, pdf_norm == Inf, NA),
           pdf_10 = replace(pdf_10, pdf_10 == Inf, NA))
  
  ###########################
  
  summary <- paste0('mean(sd) = ', round(exp(fit$estimate[[1]]),1), '(', round(exp(fit$estimate[[2]]),1), ') mg/L\nn = ',format(nrow(df),big.mark=",",scientific=FALSE)) #; p5 ', round(p5,1), '; p95 ', round(p95,1) )
  ggplot() +
    theme(axis.text.y = element_blank()) +
    geom_histogram(data=df,aes(x=VALUE, y = ..density..), colour = 1, fill = "white") +
    geom_line(data = curve_df, aes(xx, pdf_10), col="darkred", size = I(1.2), linetype = 1) +
    
    # geom_rect(aes(xmin=x0, xmax=x1, ymin=0, ymax=.6), color="transparent", fill="orange", alpha=0.3) +
    
    # geom_vline(xintercept = med, linetype="dotted", show_guide=TRUE) +
    # # annotate("text",x=med,y=.4, fill = "green",label=paste0(round(med,1)," mg/L")) +
    # geom_label(aes(x=med,y=.4,label=paste0(round(med,1)," mg/L")), fill = "white") +
    geom_label(aes(x=1000,y=.4,label=summary), fill = "white") +
    scale_x_log10(labels = comma, limits = c(.1,NA)) + 
    coord_cartesian(ylim=c(NA,.55)) +
    labs(x=paste0('Maximum chloride concentration (mg/L)')) #, title = summary)  
}






# q <- "SELECT L.LOC_ID, INT_ID, SAM_ID, NAME, 
# INTERVAL_NAME, ALTERNATE_INTERVAL_NAME, READING_GROUP_NAME, 
# INT_TYPE, PARAMETER, VALUE, UNIT, QUALIFIER, MDL, UNCERTAINTY, 
# SCREEN_GEOL_UNIT, SAMPLE_DATE, RD_NAME_CODE
# FROM V_GEN_LAB AS L
# JOIN R_READING_GROUP_CODE AS G ON G.READING_GROUP_CODE = L.GROUP_CODE
# JOIN (SELECT * FROM D_INTERVAL_FORM_ASSIGN_FINAL
#       JOIN V_SYS_GEOL_UNIT_SHALLOW ON ASSIGNED_UNIT = GEOL_UNIT_CODE) AS Z ON L.INT_ID = Z.INT_ID
# WHERE PARAMETER LIKE 'Chloride'
# AND UNIT LIKE 'mg/L'
# AND VALUE > 0.1
# AND VALUE < 20000"

