# fill provided from CVC, modified be M.Marchildon

# # Set working directory, and save all files here
# # It's faster to work off C drive for large data sets but you'll need to remember to back-up manually
# setwd("C:/Users/X/Municipal Wells")
# #


#   1. Packages and functions ####

# Run this if tidyverse (or other packages) not already installed:
# install.packages(c("tidyverse", "readxl", "writexl", ""lubridate", "scales", "cowplot", "mgcv", "NADA, "lattice"))

# Load your packages
library(tidyverse)
library(readxl) #Read Excel files
library(writexl) #Write Excel files
library(lubridate) #Manipulate dates
library(scales) #More figure customization
library(cowplot) #Overlaying figures
library(mgcv) # GAMs
library(stringr)


RunCVCscript <- function(dftem, dfloc, nowyear=2023, endyear=2040) {
  
  # From the Bottom of the Heap: https://fromthebottomoftheheap.net/
  Deriv <- function(mod, n = 200, eps = 1e-7, newdata, term) {
    if(inherits(mod, "gamm"))
      mod <- mod$gam
    m.terms <- attr(terms(mod), "term.labels")
    if(missing(newdata)) {
      newD <- sapply(model.frame(mod)[, m.terms, drop = FALSE],
                     function(x) seq(min(x), max(x), length = n))
      names(newD) <- m.terms
    } else {
      newD <- newdata
    }
    X0 <- predict(mod, data.frame(newD), type = "lpmatrix")
    newD <- newD + eps
    X1 <- predict(mod, data.frame(newD), type = "lpmatrix")
    Xp <- (X1 - X0) / eps
    Xp.r <- NROW(Xp)
    Xp.c <- NCOL(Xp)
    ## dims of bs
    bs.dims <- sapply(mod$smooth, "[[", "bs.dim") - 1
    ## number of smooth terms
    t.labs <- attr(mod$terms, "term.labels")
    ## match the term with the the terms in the model
    if(!missing(term)) {
      want <- grep(term, t.labs)
      if(!identical(length(want), length(term)))
        stop("One or more 'term's not found in model!")
      t.labs <- t.labs[want]
    }
    nt <- length(t.labs)
    ## list to hold the derivatives
    lD <- vector(mode = "list", length = nt)
    names(lD) <- t.labs
    for(i in seq_len(nt)) {
      Xi <- Xp * 0
      want <- grep(t.labs[i], colnames(X1))
      Xi[, want] <- Xp[, want]
      df <- Xi %*% coef(mod)
      df.sd <- rowSums(Xi %*% mod$Vp * Xi)^.5
      lD[[i]] <- list(deriv = df, se.deriv = df.sd)
    }
    class(lD) <- "Deriv"
    lD$gamModel <- mod
    lD$eps <- eps
    lD$eval <- newD - eps
    lD ##return
  }
  
  confint.Deriv <- function(object, term, alpha = 0.10, ...) {
    l <- length(object) - 3
    term.labs <- names(object[seq_len(l)])
    if(missing(term)) {
      term <- term.labs
    } else { ## how many attempts to get this right!?!?
      ##term <- match(term, term.labs)
      ##term <- term[match(term, term.labs)]
      term <- term.labs[match(term, term.labs)]
    }
    if(any(miss <- is.na(term)))
      stop(paste("'term'", term[miss], "not a valid model term."))
    res <- vector(mode = "list", length = length(term))
    names(res) <- term
    residual.df <- df.residual(object$gamModel)
    tVal <- qt(1 - (alpha/2), residual.df)
    ##for(i in term.labs[term]) {
    for(i in term) {
      upr <- object[[i]]$deriv + tVal * object[[i]]$se.deriv
      lwr <- object[[i]]$deriv - tVal * object[[i]]$se.deriv
      res[[i]] <- list(upper = drop(upr), lower = drop(lwr))
    }
    res$alpha = alpha
    res
  }
  
  signifD <- function(x, d, upper, lower, eval = 0) {
    miss <- upper > eval & lower < eval
    incr <- decr <- x
    want <- d > eval
    incr[!want | miss] <- NA
    want <- d < eval
    decr[!want | miss] <- NA
    list(incr = incr, decr = decr)
  }
  
  plot.Deriv <- function(x, alpha = 0.10, polygon = TRUE,
                         sizer = FALSE, term,
                         eval = 0, lwd = 3,
                         col = "lightgrey", border = col,
                         ylab, xlab, main, ...) {
    l <- length(x) - 3
    ## get terms and check specified (if any) are in model
    term.labs <- names(x[seq_len(l)])
    if(missing(term)) {
      term <- term.labs
    } else {
      term <- term.labs[match(term, term.labs)]
    }
    if(any(miss <- is.na(term)))
      stop(paste("'term'", term[miss], "not a valid model term."))
    if(all(miss))
      stop("All terms in 'term' not found in model.")
    l <- sum(!miss)
    nplt <- n2mfrow(l)
    tVal <- qt(1 - (alpha/2), df.residual(x$gamModel))
    if(missing(ylab))
      ylab <- expression(italic(hat(f)*"'"*(x)))
    if(missing(xlab)) {
      xlab <- attr(terms(x$gamModel), "term.labels")
      names(xlab) <- xlab
    }
    if (missing(main)) {
      main <- term
      names(main) <- term
    }
    ## compute confidence interval
    CI <- confint(x, term = term)
    ## plots
    layout(matrix(seq_len(l), nrow = nplt[1], ncol = nplt[2]))
    for(i in term) {
      upr <- CI[[i]]$upper
      lwr <- CI[[i]]$lower
      ylim <- range(upr, lwr)
      plot(x$eval[,i], x[[i]]$deriv, type = "n",
           ylim = ylim, ylab = ylab, xlab = xlab[i], main = main[i], ...)
      if(isTRUE(polygon)) {
        polygon(c(x$eval[,i], rev(x$eval[,i])),
                c(upr, rev(lwr)), col = col, border = border)
      } else {
        lines(x$eval[,i], upr, lty = "dashed")
        lines(x$eval[,i], lwr, lty = "dashed")
      }
      abline(h = 0, ...)
      if(isTRUE(sizer)) {
        lines(x$eval[,i], x[[i]]$deriv, lwd = 1)
        S <- signifD(x[[i]]$deriv, x[[i]]$deriv, upr, lwr,
                     eval = eval)
        lines(x$eval[,i], S$incr, lwd = lwd, col = "red")
        lines(x$eval[,i], S$decr, lwd = lwd, col = "springgreen4")
      } else {
        lines(x$eval[,i], x[[i]]$deriv, lwd = 2)
      }
    }
    layout(1)
    invisible(x)
  }
  
  #
  
  #   2. Read data and do additional prep ####
  
  
  # # --- --- Read data -  probably include a function here for filtering relevant data
  # Wells <- read.csv("dat/dta_ORMGP_SampleData_20240117.csv") %>%
  #   as_tibble()  %>%
  #   mutate(Time = Year + (Month - 1)*0.09)
  # #


  # --- --- Read data -  probably include a function here for filtering relevant data
  Wells <- dftem %>%
    as_tibble()  %>%
    mutate(Time = Year + (Month - 1)*0.09)
  #
  
  # --- --- Check for data gaps and identify start date for analysis
  
  # Wells with no data in any of the parameter kills the function ahead, so remove them
  Start.Exclude <- Wells %>%
    filter(!is.na(Value)) %>%
    select(Muni, Well, Parameter) %>%
    distinct() %>%
    group_by(Muni, Well) %>%
    count() %>%
    filter(n < 3) %>%
    mutate(Chloride = 1,
           Sodium = 1,
           Nitrate = 1) %>%
    pivot_longer(c("Chloride", "Sodium", "Nitrate"), names_to = "Parameter", values_to = "X") %>%
    select(-c(n, X)) %>%
    anti_join(.,
              Wells %>%
                filter(!is.na(Value)) %>%
                select(Muni, Well, Parameter) %>%
                distinct() %>%
                group_by(Muni, Well) %>%
                count() %>%
                filter(n < 3) %>%
                left_join(Wells %>%
                            select(Muni, Well, Parameter) %>%
                            distinct())) %>%
    ungroup()
  
  # The sample dataset only has wells missing nitrate, none missing chloride or sodium
  Exclude.Cl <- Start.Exclude %>% filter(Parameter == "Chloride") %>% select(-Parameter)
  Exclude.Na <- Start.Exclude %>% filter(Parameter == "Sodium") %>% select(-Parameter)
  Exclude.Ni <- Start.Exclude %>% filter(Parameter == "Nitrate") %>% select(-Parameter)
  

  # Pull names of complete wells
  Well.Names <- Wells %>%
    # Remove wells identified above
    anti_join(., Start.Exclude %>% select(-Parameter)) %>%
    select(Muni, Well) %>%
    distinct() %>%
    pull()
  
  # Pull out wells missing chloride data
  Well.Names.No_Cl <- Wells %>%
    inner_join(., Exclude.Cl) %>%
    select(Muni, Well) %>%
    distinct() %>%
    pull()
  
  # Pull out wells missing sodium data
  Well.Names.No_Na <- Wells %>%
    inner_join(., Exclude.Na) %>%
    select(Muni, Well) %>%
    distinct() %>%
    pull()
  
  # Pull out wells missing nitrate data
  Well.Names.No_Ni <- Wells %>%
    inner_join(., Exclude.Ni) %>%
    select(Muni, Well) %>%
    distinct() %>%
    pull()
  
  
  # Loops to figure out data gaps
  Data.Gaps <- Well.Names %>%
    map_dfr(
      function(Well.Names) {
        
        Wells.Wide = Wells %>%
          select(-Month) %>%
          pivot_wider(names_from = "Parameter", values_from = "Value", values_fn = mean)
        
        Start.Cl = Wells.Wide %>% filter(!is.na(Chloride) & Well == Well.Names) %>%
          select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)
        Start.Na = Wells.Wide %>% filter(!is.na(Sodium) & Well == Well.Names) %>%
          select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)
        Start.Ni = Wells.Wide %>% filter(!is.na(Nitrate) & Well == Well.Names) %>%
          select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)
        
        dat = bind_rows(Wells.Wide %>%
                          filter(!is.na(Chloride) & Well == Well.Names) %>%
                          select(Well, Year) %>%
                          distinct() %>%
                          mutate(Presence = 1) %>%
                          full_join(tibble(Year = 1950:nowyear)) %>%
                          arrange(Year) %>%
                          filter(Year %in% c(Start.Cl:nowyear)) %>%
                          mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                 Well = Well.Names,
                                 Parameter = "Chloride") %>%
                          pivot_wider(names_from = "Year", values_from = "Presence") %>%
                          unite(col = "Years", 3:ncol(.), sep = ","),
                        Wells.Wide %>%
                          filter(!is.na(Sodium) & Well == Well.Names) %>%
                          select(Well, Year) %>%
                          distinct() %>%
                          mutate(Presence = 1) %>%
                          full_join(tibble(Year = 1950:nowyear)) %>%
                          arrange(Year) %>%
                          filter(Year %in% c(Start.Na:nowyear)) %>%
                          mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                 Well = Well.Names,
                                 Parameter = "Sodium") %>%
                          pivot_wider(names_from = "Year", values_from = "Presence") %>%
                          unite(col = "Years", 3:ncol(.), sep = ","),
                        Wells.Wide %>%
                          filter(!is.na(Nitrate) & Well == Well.Names) %>%
                          select(Well, Year) %>%
                          distinct() %>%
                          mutate(Presence = 1) %>%
                          full_join(tibble(Year = 1950:nowyear)) %>%
                          arrange(Year) %>%
                          filter(Year %in% c(Start.Ni:nowyear)) %>%
                          mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                 Well = Well.Names,
                                 Parameter = "Nitrate") %>%
                          pivot_wider(names_from = "Year", values_from = "Presence") %>%
                          unite(col = "Years", 3:ncol(.), sep = ",")) %>%
          inner_join(., Wells %>% select(Muni, Well, Parameter) %>% distinct()) %>%
          select(Muni, Well, Parameter, Years) %>%
          arrange(Muni, Parameter, Well)
        
        
      }
    )
  
  Data.Gaps.No_Cl <- Well.Names.No_Cl %>%
    map_dfr(
      function(Well.Names.No_Cl) {
        
        Wells.Wide = Wells %>%
          inner_join(., Exclude.Cl) %>%
          select(-Month) %>%
          pivot_wider(names_from = "Parameter", values_from = "Value", values_fn = mean)

        if ('Nitrate' %in% colnames(Wells.Wide) & 'Sodium' %in% colnames(Wells.Wide)) {        
          Start.Na = Wells.Wide %>% filter(!is.na(Sodium) & Well == Well.Names.No_Cl) %>%
            select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)

          Start.Ni = Wells.Wide %>% filter(!is.na(Nitrate) & Well == Well.Names.No_Cl) %>%
            select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)
          
          if (length(Start.Na)>0 & length(Start.Ni)>0) {
            dat = bind_rows(Wells.Wide %>%
                              filter(!is.na(Sodium) & Well == Well.Names.No_Cl) %>%
                              select(Well, Year) %>%
                              distinct() %>%
                              mutate(Presence = 1) %>%
                              full_join(tibble(Year = 1950:nowyear)) %>%
                              arrange(Year) %>%
                              filter(Year %in% c(Start.Na:nowyear)) %>%
                              mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                    Well = Well.Names.No_Cl,
                                    Parameter = "Sodium") %>%
                              pivot_wider(names_from = "Year", values_from = "Presence") %>%
                              unite(col = "Years", 3:ncol(.), sep = ","),
                            Wells.Wide %>%
                              filter(!is.na(Nitrate) & Well == Well.Names.No_Cl) %>%
                              select(Well, Year) %>%
                              distinct() %>%
                              mutate(Presence = 1) %>%
                              full_join(tibble(Year = 1950:nowyear)) %>%
                              arrange(Year) %>%
                              filter(Year %in% c(Start.Ni:nowyear)) %>%
                              mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                    Well = Well.Names.No_Cl,
                                    Parameter = "Nitrate") %>%
                              pivot_wider(names_from = "Year", values_from = "Presence") %>%
                              unite(col = "Years", 3:ncol(.), sep = ",")) %>%
              inner_join(., Wells %>% select(Muni, Well, Parameter) %>% distinct()) %>%
              select(Muni, Well, Parameter, Years) %>%
              arrange(Muni, Parameter, Well)
          }
        }        
      }
    )
  
  Data.Gaps.No_Na <- Well.Names.No_Na %>%
    map_dfr(
      function(Well.Names.No_Na) {
        
        Wells.Wide = Wells %>%
          inner_join(., Exclude.Na) %>%
          select(-Month) %>%
          pivot_wider(names_from = "Parameter", values_from = "Value", values_fn = mean)

        if ('Chloride' %in% colnames(Wells.Wide) & 'Nitrate' %in% colnames(Wells.Wide)) {        
          Start.Cl = Wells.Wide %>% filter(!is.na(Chloride) & Well == Well.Names.No_Na) %>%
            select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)

          Start.Ni = Wells.Wide %>% filter(!is.na(Nitrate) & Well == Well.Names.No_Na) %>%
            select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)

          if (length(Start.Cl)>0 & length(Start.Ni)>0) {
            dat = bind_rows(Wells.Wide %>%
                              filter(!is.na(Chloride) & Well == Well.Names.No_Na) %>%
                              select(Well, Year) %>%
                              distinct() %>%
                              mutate(Presence = 1) %>%
                              full_join(tibble(Year = 1950:nowyear)) %>%
                              arrange(Year) %>%
                              filter(Year %in% c(Start.Cl:nowyear)) %>%
                              mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                    Well = Well.Names.No_Na,
                                    Parameter = "Chloride") %>%
                              pivot_wider(names_from = "Year", values_from = "Presence") %>%
                              unite(col = "Years", 3:ncol(.), sep = ","),
                            Wells.Wide %>%
                              filter(!is.na(Nitrate) & Well == Well.Names.No_Na) %>%
                              select(Well, Year) %>%
                              distinct() %>%
                              mutate(Presence = 1) %>%
                              full_join(tibble(Year = 1950:nowyear)) %>%
                              arrange(Year) %>%
                              filter(Year %in% c(Start.Ni:nowyear)) %>%
                              mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                    Well = Well.Names.No_Na,
                                    Parameter = "Nitrate") %>%
                              pivot_wider(names_from = "Year", values_from = "Presence") %>%
                              unite(col = "Years", 3:ncol(.), sep = ",")) %>%
              inner_join(., Wells %>% select(Muni, Well, Parameter) %>% distinct()) %>%
              select(Muni, Well, Parameter, Years) %>%
              arrange(Muni, Parameter, Well)
          }
        }
      }
    )
  
  Data.Gaps.No_Ni <- Well.Names.No_Ni %>%
    map_dfr(
      function(Well.Names.No_Ni) {
        
        Wells.Wide = Wells %>%
          inner_join(., Exclude.Ni) %>%
          select(-Month) %>%
          pivot_wider(names_from = "Parameter", values_from = "Value", values_fn = mean)

        if ('Sodium' %in% colnames(Wells.Wide) & 'Chloride' %in% colnames(Wells.Wide)) {        
          Start.Cl = Wells.Wide %>% filter(!is.na(Chloride) & Well == Well.Names.No_Ni) %>%
            select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)

          Start.Na = Wells.Wide %>% filter(!is.na(Sodium) & Well == Well.Names.No_Ni) %>%
            select(Year) %>% arrange(Year) %>% slice(1) %>% pull(Year)

          if (length(Start.Cl)>0 & length(Start.Na)>0) {            
            dat = bind_rows(Wells.Wide %>%
                              filter(!is.na(Chloride) & Well == Well.Names.No_Ni) %>%
                              select(Well, Year) %>%
                              distinct() %>%
                              mutate(Presence = 1) %>%
                              full_join(tibble(Year = 1950:nowyear)) %>%
                              arrange(Year) %>%
                              filter(Year %in% c(Start.Cl:nowyear)) %>%
                              mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                    Well = Well.Names.No_Ni,
                                    Parameter = "Chloride") %>%
                              pivot_wider(names_from = "Year", values_from = "Presence") %>%
                              unite(col = "Years", 3:ncol(.), sep = ","),
                            Wells.Wide %>%
                              filter(!is.na(Sodium) & Well == Well.Names.No_Ni) %>%
                              select(Well, Year) %>%
                              distinct() %>%
                              mutate(Presence = 1) %>%
                              full_join(tibble(Year = 1950:nowyear)) %>%
                              arrange(Year) %>%
                              filter(Year %in% c(Start.Na:nowyear)) %>%
                              mutate(Presence = ifelse(is.na(Presence), "_", Year),
                                    Well = Well.Names.No_Ni,
                                    Parameter = "Sodium") %>%
                              pivot_wider(names_from = "Year", values_from = "Presence") %>%
                              unite(col = "Years", 3:ncol(.), sep = ",")) %>%
              inner_join(., Wells %>% select(Muni, Well, Parameter) %>% distinct()) %>%
              select(Muni, Well, Parameter, Years) %>%
              arrange(Muni, Parameter, Well)
          }
        }        
      }
    )
  
  #
  
  # --- --- Generate start dates
  if (nrow(Data.Gaps)>0) {
    Start.Dates <- bind_rows(
      # These sites have data gaps of 3+ years; find the start date
      Data.Gaps %>%
        filter(str_detect(Years, "[:punct:]{7,}(?=\\d{4})")) %>%
        mutate(Period = str_extract_all(Years, "\\d{4}[:punct:]{7,}\\d{4}")) %>%
        select(-Years) %>%
        unnest(Period) %>%
        arrange(Muni, Well, Parameter, Period) %>%
        mutate(Start = str_extract(Period, "\\d{4}$")),
      # For all other sites, use the first date
      bind_rows(Data.Gaps,
                Data.Gaps.No_Cl,
                Data.Gaps.No_Na,
                Data.Gaps.No_Ni) %>%
        mutate(Start = str_extract(Years, "^\\d{4}")) %>%
        select(-Years)) %>%
      arrange(Muni, Well, Parameter, Start) %>%
      group_by(Muni, Well, Parameter) %>%
      slice_tail(n = 1) %>%
      ungroup() %>%
      mutate(Start = as.numeric(Start)) #%>%
      # print(n = 50)

  
    
    #
    
    # --- --- Specify which k is appropriate for each well
    
    # These sites have data points all the same value
    K.Exclude <- Wells %>%
      select(Muni, Well, Parameter, Value) %>%
      distinct() %>%
      group_by(Muni, Well, Parameter) %>%
      count() %>%
      ungroup() %>%
      filter(n == 1) %>%
      select(-n)
    
    # Determine K based on sample size
    Wells.K <- Wells %>%
      left_join(Start.Dates) %>%
      filter(Year >= Start) %>%
      select(Muni, Well, Date, Parameter) %>%
      distinct() %>%
      group_by(Muni, Well, Parameter) %>%
      count() %>%
      ungroup() %>%
      full_join(K.Exclude %>% mutate(K = 0)) %>%
      mutate(K = case_when(is.na(K) & n >= 9 ~ 5,
                          is.na(K) & n %in% 6:8 ~ 3,
                          is.na(K) & n < 5 ~ 0,
                          TRUE ~ K),
            K = ifelse(K == 0, NA, K)) %>%
      select(-n)
    
    #
    
    # --- --- These are wells that can be used for seasonal analysis
    Wells.Select <- Wells %>%
                      filter(!is.na(Value)) %>%
                      select(Muni, Well, Year, Month, Parameter) %>%
                      distinct() %>%
                      group_by(Muni, Well, Year, Parameter) %>%
                      summarise(Months = n()) %>%
                      ungroup() %>%
                      full_join(Start.Dates) %>%
                      filter(Year >= Start & Months >= 10) %>%
                      select(-c(Period, Start)) %>%
                      arrange(Year, Muni, Well, Parameter) %>%
                      group_by(Muni, Well, Parameter, Months) 
    
    if (nrow(Wells.Select)>0 & length(unique(Wells.Select %>% pull(Months)))==3) { 
      Wells.Seasonal <- inner_join(Wells.Select %>%
                                    slice_head(n = 1) %>%
                                    ungroup() %>%
                                    mutate(First_10 = ifelse(Months == 10, Year, NA),
                                            First_11 = ifelse(Months == 11, Year, NA),
                                            First_12 = ifelse(Months == 12, Year, NA)) %>%
                                    select(-c(Year, Months)) %>%
                                    pivot_longer(c("First_10", "First_11", "First_12"), names_to = "First", values_to = "First_Year") %>%
                                    filter(!is.na(First_Year)) %>%
                                    pivot_wider(names_from = "First", values_from = "First_Year") %>%
                                    mutate(First = case_when(!is.na(First_10) & is.na(First_11) & is.na(First_12) ~ First_10,
                                                              !is.na(First_11) & is.na(First_10) & is.na(First_12) ~ First_11,
                                                              !is.na(First_12) & is.na(First_11) & is.na(First_10) ~ First_12,
                                                              !is.na(First_12) & !is.na(First_11) & (First_12 - First_11) <= 2 ~ First_12,
                                                              !is.na(First_12) & !is.na(First_11) & (First_12 - First_11) > 2 ~ First_11,
                                                              !is.na(First_12) & is.na(First_11) & !is.na(First_10) & (First_12 - First_10) <= 2 ~ First_12,
                                                              is.na(First_12) & !is.na(First_11) & !is.na(First_10) & (First_11 - First_10) <= 2 ~ First_11,
                                                              is.na(First_12) & !is.na(First_11) & !is.na(First_10) & (First_11 - First_10) > 2 ~ First_10)) %>%
                                    select(Muni, Well, Parameter, First),
                                  Wells.Select %>%
                                    slice_tail(n = 1) %>%
                                    ungroup() %>%
                                    mutate(Last_10 = ifelse(Months == 10, Year, NA),
                                            Last_11 = ifelse(Months == 11, Year, NA),
                                            Last_12 = ifelse(Months == 12, Year, NA)) %>%
                                    select(-c(Year, Months)) %>%
                                    pivot_longer(c("Last_10", "Last_11", "Last_12"), names_to = "Last", values_to = "Last_Year") %>%
                                    filter(!is.na(Last_Year)) %>%
                                    pivot_wider(names_from = "Last", values_from = "Last_Year") %>%
                                    rowwise() %>%
                                    mutate(Latest_Year = max(Last_10, Last_11, Last_12, na.rm = TRUE)) %>%
                                    filter(Latest_Year >= 2020) %>%
                                    ungroup() %>%
                                    mutate(Last = case_when(!is.na(Last_12) & Last_12 == Latest_Year ~ Last_12,
                                                            (is.na(Last_12) | Last_12 < Latest_Year) & Last_11 == Latest_Year ~ Last_11,
                                                            !is.na(Last_12) & !is.na(Last_11) & !is.na(Last_10) & (Latest_Year - Last_12) <= 2 ~ Last_12)) %>%
                                    select(Muni, Well, Parameter, Last)) #%>%
      # print(n = 50)    
    } else {
      Wells.Seasonal <- data.frame(Muni=character(),
                                  Well=character(),
                                  Parameter=character())
    }

    
    
    #
    
    # ~~~~~~~~~~~~~~   FIGURES    ~~~~~~~~~~~~~  ####
    #   1: Sampling Frequency ####
    
    # # Check sampling frequency & which wells are of concern
    # 
    # overview = function(data, muni) {
    #   
    #   Wells.New <- data %>%
    #     mutate(Parameter = paste(Parameter, "(mg/L)"),
    #            Parameter = as.factor(fct_relevel(Parameter, "Chloride (mg/L)", "Sodium (mg/L)", "Nitrate (mg/L)")))
    #   
    #   integer_breaks <- function(n = 4, ...) {
    #     fxn <- function(x) {
    #       breaks <- floor(pretty(x, n, ...))
    #       names(breaks) <- attr(breaks, "labels")
    #       breaks
    #     }
    #     return(fxn)
    #   }
    #   
    #   
    #   XHalf = tibble(Parameter = c("Chloride (mg/L)", "Sodium (mg/L)", "Nitrate (mg/L)"),
    #                  Value = c(125, 100, 5)) %>%
    #     mutate(Parameter = as.factor(fct_relevel(Parameter, "Chloride (mg/L)", "Sodium (mg/L)", "Nitrate (mg/L)")))
    #   
    #   XMAC = XHalf %>% mutate(Value = Value * 2)
    #   
    #   Report = tibble(Parameter = c("Chloride (mg/L)", "Sodium (mg/L)", "Nitrate (mg/L)"),
    #                   Value = c(NA, 20, NA)) %>%
    #     mutate(Parameter = as.factor(fct_relevel(Parameter, "Chloride (mg/L)", "Sodium (mg/L)", "Nitrate (mg/L)")))
    #   
    #   
    #   ggplot(Wells.New %>% filter(Muni == muni), aes(Time, Value, colour = Parameter)) +
    #     geom_point(data = XMAC, aes(-Inf, Value + Value/10), alpha = 0) +
    #     geom_point(alpha = 0.6) +
    #     # Reporting Threshold
    #     geom_hline(data = Report, aes(yintercept = Value), linetype = "dotted", linewidth = 1, colour = "grey50") +
    #     geom_text(data = Report, aes(-Inf, Value + Value/25, label = " Reporting Threshold"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
    #     # Half MAC
    #     geom_hline(data = XHalf, aes(yintercept = Value), linetype = "dashed", linewidth = 1, colour = "grey50") +
    #     geom_text(data = XHalf, aes(-Inf, Value + Value/25, label = " Half MAC"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
    #     # MAC
    #     geom_hline(data = XMAC, aes(yintercept = Value), linetype = "dashed", linewidth = 1, colour = "grey40") +
    #     geom_text(data = XMAC, aes(-Inf, Value + Value/50, label = " Maximum Acceptable Concentration"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
    #     # Start Date
    #     #  geom_vline(data = Start.Dates %>% mutate(Parameter = paste(Parameter, "(mg/L)")) %>% filter(Muni == muni), aes(xintercept = Start), linetype = "solid", linewidth = 0.5, colour = "grey40") +
    #     # scale_x_continuous(breaks = integer_breaks(), name = NULL) +
    #     scale_x_continuous(breaks = integer_breaks(), name = NULL) +
    #     scale_y_continuous(name = NULL) +
    #     scale_colour_manual(values = c("#007DA5", "#FF5100", "#6F9119"), name = NULL) +
    #     expand_limits(y = 0) +
    #     theme_bw() +
    #     ggtitle(muni) + 
    #     theme(plot.title = element_text(hjust = 0.5),
    #           strip.background = element_blank(),
    #           strip.text = element_text(size = 12),
    #           axis.text = element_text(size = 10),
    #           panel.spacing = unit(1, "lines"),
    #           plot.margin = margin(8, 10, 3, 3),
    #           strip.placement = "outside",
    #           legend.position = "bottom") +
    #     facet_grid(Parameter ~ Well, scales = "free", switch = "y")
    #   
    # }
    # 
    # # Split up wells to be 2-5 wells per figure
    # overview(data = Wells %>% filter(!Well %in% c("Davidson 1", "Davidson 2")), muni = "Acton") + ggtitle("Acton Part 1")
    # overview(data = Wells %>% filter(Well %in% c("Davidson 1", "Davidson 2")), muni = "Acton") + ggtitle("Acton Part 2")
    # overview(data = Wells %>% mutate(Time = ifelse(Well == "Well 6", 2020, Time)), muni = "Caledon East")
    # overview(data = Wells, muni = "Erin")
    # overview(data = Wells %>% filter(str_detect(Well, "Cedar")), muni = "Georgetown") + ggtitle("Georgetown Part 1")
    # overview(data = Wells %>% filter(!str_detect(Well, "Cedar")), muni = "Georgetown") + ggtitle("Georgetown Part 2")
    # overview(data = Wells, muni = "King City")
    # overview(data = Wells, muni = "Kleinburg")
    # overview(data = Wells %>% filter(!str_detect(Well, "Island")), muni = "Mono")
    # overview(data = Wells %>% filter(str_detect(Well, "Island")), muni = "Mono")
    # overview(data = Wells %>% filter(Well %in% c("Well 2A", "Well 5", "Well 5A", "Well 6", "Well 7")), muni = "Orangeville") + ggtitle("Orangeville Part 1")
    # overview(data = Wells %>% filter(Well %in% c("Well 8B", "Well 8C", "Well 9A", "Well 9B")), muni = "Orangeville") + ggtitle("Orangeville Part 2")
    # overview(data = Wells %>% filter(Well %in% c("Well 10", "Well 11", "Well 12")), muni = "Orangeville") + ggtitle("Orangeville Part 3")
    # overview(data = Wells, muni = "Palgrave")
    # overview(data = Wells %>% filter(Well %in% c("Alton 3", "Caledon Village 3", "Caledon Village 3B", "Caledon Village 4")), muni = "Peel") + ggtitle("Peel Part 1")
    # overview(data = Wells %>% filter(!Well %in% c("Alton 3", "Caledon Village 3", "Caledon Village 3B", "Caledon Village 4")), muni = "Peel") + ggtitle("Peel Part 2")
    # overview(data = Wells, muni = "Stouffville")
    # overview(data = Wells, muni = "Uxville")
    
    #
    
    # Get current(/last) value 
    current.WQ <- function(muni,well_id,para) {
      
      # a <- Wells %>% 
      #   filter(Muni == muni & Well == well_id & Parameter == para) %>%
      #   mutate(Date = as.Date(Date)) %>%
      #   slice(which.max(Date)) %>%
      #   select(Value)
      meds <- Wells %>% 
        filter(Muni == muni & Well == well_id & Parameter == para) %>%
        group_by(Year) %>%
        summarize(v=median(Value))
      a0 <- first(meds, order_by=meds$Year)$v
      a1 <- last(meds, order_by=meds$Year)$v
      
      if (para=="Nitrate") dfloc$NO3.current[dfloc$Well==well_id] <<- a1
      if (para=="Chloride") dfloc$Cl.current[dfloc$Well==well_id] <<- a1
      if (para=="Sodium") dfloc$Na.current[dfloc$Well==well_id] <<- a1
      if (para=="Nitrate") dfloc$NO3.first[dfloc$Well==well_id] <<- a0
      if (para=="Chloride") dfloc$Cl.first[dfloc$Well==well_id] <<- a0
      if (para=="Sodium") dfloc$Na.first[dfloc$Well==well_id] <<- a0
      
    } 
    
    current.trending.WQ <- function(well_id, para, df) {
      
      df2 <- df %>%
        group_by(date) %>%
        summarise(deriv=median(deriv,na.rm=T),sig.incr=median(sig.incr,na.rm=T),sig.decr=median(sig.decr,na.rm=T)) %>%
        ungroup()
      t1 <- last(df2, order_by=df2$date)$deriv
      sig <- 0
      if (t1 > 0 & !is.na(last(df2, order_by=df2$date)$sig.incr)) sig <- 1
      if (t1 < 0 & !is.na(last(df2, order_by=df2$date)$sig.decr)) sig <- 1
      
      if (para=="Nitrate") {
        dfloc$NO3.cur.trnd[dfloc$Well==well_id] <<- t1
        dfloc$NO3.cur.trnd.sig[dfloc$Well==well_id] <<- sig
      }
      if (para=="Chloride") {
        dfloc$Cl.cur.trnd[dfloc$Well==well_id] <<- t1
        dfloc$Cl.cur.trnd.sig[dfloc$Well==well_id] <<- sig  
      }
      if (para=="Sodium") {
        dfloc$Na.cur.trnd[dfloc$Well==well_id] <<- t1
        dfloc$Na.cur.trnd.sig[dfloc$Well==well_id] <<- sig
      }
    }
    
    #   2a: GAM Trend Analyses ####
    neat_K5_K3 = function(muni, well_id, para) {
      
      ctrl <- list(niterEM = 0, optimMethod = "L-BFGS-B") # msVerbose = TRUE,
      Term <- "Time"
      
      # Generate x limits
      Start = Start.Dates %>% filter(Muni == muni, Well == well_id, Parameter == para) %>% pull(Start)
      First_Point = Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% arrange(Year) %>% slice(1) %>% pull(Year)
      Year_Range = nowyear-1 - First_Point
      Xmin = ifelse(Year_Range < 10, Start, floor(First_Point/5)*5)
      By = case_when((nowyear-1 - Xmin) %in% 20:29 ~ 5,
                    (nowyear-1 - Xmin) > 29 ~ 10,
                    (nowyear-1 - Xmin) < 20 ~ 2)
      
      # Specify k
      K = Wells.K %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% pull(K)
      
      # Generate y limits
      Ymin = ifelse(para == "Chloride", floor((Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% summarise(Min = min(Value)) %>% pull(Min))/10)*10, 0)
      Division = case_when(para == "Nitrate" ~ 0.5,
                          para == "Chloride" ~ 15,
                          para == "Sodium" ~ 10)
      Max = ceiling((Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% summarise(Max = max(Value)) %>% pull(Max))/Division)*Division
      n = nrow(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para))

      # Maximum Allowable Concentration
      MAC = case_when(para == "Nitrate" ~ 10,
                      para == "Chloride" ~ 250,
                      para == "Sodium" ~ 200)
      
      # Padding between label and line
      Label.Space = ifelse(para == "Nitrate", 0.26, 4)
      
      Report.Line = ifelse(para == "Sodium", "dotted", "blank")
      Report.Text = ifelse(para == "Sodium", "Reporting Threshold", NA)
      

      
      
      # Modelling
      GAM.Model <- gamm(Value ~ s(Time, k = K), # cc = cyclic cubic
                        data = Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start), correlation = corARMA(form = ~ 1|Time, p = 1))
      
      Well_Name = Wells %>% filter(Muni == muni & Well == well_id) %>% select(Well) %>% distinct() %>% pull(Well)
      
      want.New <- seq(1, nrow(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start)), length.out = 200)
      pdat.New <- with(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start), data.frame(Time = Time[want.New]))
      p.GAM.Model <- predict(GAM.Model$gam, newdata = pdat.New, type = "terms",  se.fit = TRUE)
      pdat.GAM.Model <- transform(pdat.New, p.GAM.Model = p.GAM.Model$fit[,1], se2 = p.GAM.Model$se.fit[,1])
      df.res.GAM.Model <- df.residual(GAM.Model$gam)
      crit.t.GAM.Model <- qt(0.025, df.res.GAM.Model, lower.tail = FALSE)
      pdat.GAM.Model <- transform(pdat.GAM.Model,
                                  upper = p.GAM.Model + (crit.t.GAM.Model * se2),
                                  lower = p.GAM.Model - (crit.t.GAM.Model * se2))
      d.GAM.Model <- Deriv(GAM.Model)
      dci.GAM.Model <- confint(d.GAM.Model, term = Term)
      dsig.GAM.Model <- signifD(pdat.GAM.Model$p.GAM.Model, d = d.GAM.Model[[Term]]$deriv,
                                + dci.GAM.Model[[Term]]$upper, dci.GAM.Model[[Term]]$lower)
      
      current.WQ(muni,well_id,para)
      current.trending.WQ(well_id,para,data.frame(date=as.integer(d.GAM.Model$eval),deriv=d.GAM.Model$Time$deriv,sig.incr=dsig.GAM.Model$incr,sig.decr=dsig.GAM.Model$decr))
      
      ggplot(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para), aes(Time, Value)) +
        geom_point(colour = "grey50", alpha = 0.6) +
        geom_line(pdat.GAM.Model, mapping = (aes(y = (coef(GAM.Model$gam)[1]) + p.GAM.Model))) +
        geom_line(pdat.GAM.Model, mapping = (aes(y = (coef(GAM.Model$gam)[1]) + upper)), lty = "dashed") +
        geom_line(pdat.GAM.Model, mapping = (aes(y = (coef(GAM.Model$gam)[1]) + lower)), lty = "dashed") +
        geom_line(pdat.GAM.Model, mapping = (aes(y = (coef(GAM.Model$gam)[1]) + (unlist(dsig.GAM.Model$incr)), colour = "Increasing")), linewidth = 1.3) +
        geom_line(pdat.GAM.Model, mapping = (aes(y = (coef(GAM.Model$gam)[1]) + (unlist(dsig.GAM.Model$decr)), colour = "Decreasing")), linewidth = 1.3) +
        # Reporting
        geom_hline(aes(yintercept = 20), linewidth = 1, linetype = Report.Line, colour = "grey50") +
        geom_text(aes(Xmin, 21, label = Report.Text), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
        # Half MAC
        geom_hline(aes(yintercept = MAC/2), linetype = "dashed", linewidth = 1, colour = "grey50") +
        geom_text(aes(Xmin, MAC/2 + Label.Space, label = "Half MAC"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
        # MAC
        geom_hline(aes(yintercept = MAC), linetype = "dashed", linewidth = 1, colour = "grey40") +
        geom_text(aes(Xmin, MAC + Label.Space, label = "Maximum Acceptable Concentration"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
        scale_colour_manual(values = c("Decreasing" = "#259955", "Increasing" = "#ed5134"), name = NULL) +
        scale_x_continuous(breaks = seq(Xmin, nowyear-1, by = By), limits = c(Xmin, nowyear-1), name = NULL) +
        scale_y_continuous(name = paste0(para, " (mg/L)"), limits = c(Ymin, Max), expand = c(0, 0)) +
        theme_bw() +
        # ggtitle(Well_Name,subtitle=paste0("Annual (n = ",n,")")) + 
        ggtitle(Well_Name,subtitle="Annual") + 
        theme(plot.title = element_text(size = 11),
              plot.subtitle = element_text(size = 9),
              axis.text.y = element_text(size = 10),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 10),
              axis.title = element_text(size = 11),
              legend.text = element_text(size = 9),
              legend.position = "bottom")
      
    }
    
    # Test
    # neat_K5_K3(muni = "Orangeville" , well_id = "Well 5", para = "Nitrate")
    # dfloc[dfloc$Well=="Well 5",]
    # neat_K5_K3(muni = "Acton" , well_id = "Davidson 1", para = "Chloride")
    # neat_K5_K3(muni = "Peel", well_id = "Inglewood 4", para = "Sodium")
    # neat_K5_K3(muni = "Peel", well_id = "Caledon Village 3", para = "Nitrate")
    
    # # Suggested size
    # neat_K5_K3(muni = "Orangeville", well_id = "Well 6", para = "Chloride") %>%
    #   ggsave(path = "dat/Report Figures",
    #          file = "Example Annual.png",
    #          width = 13,
    #          height = 9,
    #          dpi = 300,
    #          units = "cm")
    
    
    #
    
    #   2b: Seasonal GAM Trend Analyses ####
    if (nrow(Wells.Seasonal)>0) {
      Wells.S <- Wells.Seasonal %>%
        pivot_longer(c(First, Last), names_to = "Position", values_to = "Year") %>%
        full_join(Wells)
      
      
      neat_S = function(muni, well_id, para) {
        
        knots <- list(month = c(0.5, seq(1, 12, length = 10), 12.5))
        ctrl.s <- list(niterEM = 0, optimMethod="L-BFGS-B", maxIter = 100, msMaxIter = 100)
        
        Sample = Wells.S %>% filter(Muni == muni & Well == well_id & !is.na(Position) & Parameter == para) %>% nrow()
        
        Well_Name = Wells.S %>% filter(Muni == muni & Well == well_id) %>% select(Well) %>% distinct() %>% pull(Well)
        
        First_Year = Wells.S %>% filter(Muni == muni & Well == well_id & !is.na(Position) & Parameter == para) %>% summarise(min(Year)) %>% pull()
        Last_Year = Wells.S %>% filter(Muni == muni & Well == well_id & !is.na(Position) & Parameter == para) %>% summarise(max(Year)) %>% pull()
        n = nrow(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para))

        # Specify k
        K1 = Wells.K %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% pull(K)
        K1 = ifelse(Last_Year - First_Year < 5, 4, K1)
        K2 = case_when(Sample ==  24 ~ 12,
                      Sample %in% 22:23 ~ 11,
                      TRUE ~ 10)
        
        # Generate y limits
        Ymin = ifelse(para == "Chloride", floor((Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% summarise(Min = min(Value)) %>% pull(Min))/10)*10, 0)
        Division = case_when(para == "Nitrate" ~ 0.5,
                            para == "Chloride" ~ 15,
                            para == "Sodium" ~ 10)
        Max = ceiling((Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% summarise(Max = max(Value)) %>% pull(Max))/Division)*Division
        
        # Maximum Allowable Concentration
        MAC = case_when(para == "Nitrate" ~ 10,
                        para == "Chloride" ~ 250,
                        para == "Sodium" ~ 200)
        
        # Padding between label and line
        Label.Space = ifelse(para == "Nitrate", 0.26, 4)
        
        Report.Line = ifelse(para == "Sodium", "dotted", "blank")
        Report.Text = ifelse(para == "Sodium", "Reporting Threshold", NA)
        
        
        # Modelling
        pdat.s <- with(Wells.S %>% filter(Muni == muni & Well == well_id & Parameter == para),
                      data.frame(Year = rep(c(First_Year, Last_Year), each = 100), # identify first and last whole years
                                  Month = rep(seq(1, 12, length = 100), times = 2))) #times=2 because looking at two years. if you add more years, must make sure this number matches.
        
        GAM.S.Model <- gamm(Value ~ s(Year, bs = "cr", k = K1) + s(Month, bs = "cc", k = K2) + ti(Year, Month, bs = c("cr","cc"), k = c(K1, K2)),
                            data = Wells.S %>% filter(Muni == muni & Well == well_id & Parameter == para & Year < nowyear), method = "ML",
                            control = ctrl.s, knots = knots, correlation = corARMA(form = ~ 1 | Year, p = 1))
        
        pred.New.S <- predict(GAM.S.Model$gam, newdata = pdat.s, se.fit = TRUE)
        crit.New.S <- qt(0.975, df = df.residual(GAM.S.Model$gam)) # ~95% interval critical t
        pdat.New.S <- transform(pdat.s, fitted = pred.New.S$fit, se = pred.New.S$se.fit, fYear = as.factor(Year))
        pdat.New.S <- transform(pdat.New.S,
                                upper = fitted + (crit.New.S * se),
                                lower = fitted - (crit.New.S * se))
        
        
        
        ggplot(pdat.New.S, aes(x = Month, y = fitted, group = fYear)) +
          geom_ribbon(mapping = aes(ymin = lower, ymax = upper,
                                    fill = fYear), alpha = 0.2) + # confidence band
          geom_point(data = Wells.S %>% filter(Muni == muni & Well == well_id & Parameter == para & Year %in% c(First_Year, Last_Year)) %>% mutate(fYear = as.factor(Year)),
                    aes(x = Month, y = Value, colour = fYear), alpha = 0.6) +
          geom_line(aes(colour = fYear), linewidth = 1.3) +    # predicted values
          # Reporting
          geom_hline(aes(yintercept = 20), linewidth = 1, linetype = Report.Line, colour = "grey50") +
          geom_text(aes(1, 21, label = Report.Text), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
          # Half MAC
          geom_hline(aes(yintercept = MAC/2), linetype = "dashed", linewidth = 1, colour = "grey50") +
          geom_text(aes(1, MAC/2 + Label.Space, label = "Half MAC"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
          # MAC
          geom_hline(aes(yintercept = MAC), linetype = "dashed", linewidth = 1, colour = "grey40") +
          geom_text(aes(1, MAC + Label.Space, label = "Maximum Acceptable Concentration"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
          scale_fill_manual(values = c("#648FFF", "#FE6100"), name = NULL) +
          scale_colour_manual(values = c("#648FFF", "#FE6100"), name = NULL) +
          scale_x_continuous(breaks = 1:12,   # tweak where the x-axis ticks are
                            labels = month.abb, # & with what labels
                            minor_breaks = NULL,
                            name = NULL) +
          scale_y_continuous(name = paste0(para, " (mg/L)"), limits = c(Ymin, Max), expand = c(0, 0)) +
          theme_bw() +
          # ggtitle(Well_Name,subtitle=paste0("Monthly (n = ",n,")")) +  
          ggtitle(Well_Name,subtitle="Monthly") +  
          theme(plot.title = element_text(size = 11),
                plot.subtitle = element_text(size = 9),
                axis.text.y = element_text(size = 10),
                axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 10),
                axis.title = element_text(size = 11),
                legend.text = element_text(size = 9),
                legend.position = "bottom")
      }    
    }


    
    # Test
    # neat_S(muni = "Acton", well_id = "Davidson 1", para = "Nitrate")
    # neat_S(muni = "Orangeville", well_id = "Well 9B", para = "Chloride")
    
    #
    
    #   2c: Predictions (GAM & LM) ####
    ODWQS.status <- function(lm1,gam1,limit) {
      o<-0
      if (predict(lm1, data.frame(Year = c(endyear)))>=limit) o=o+1
      if (predict(gam1$gam, data.frame(Year = c(endyear)))>=limit) o=o+1
      return(o)
    }
    
    future.trending.WQ <- function(well_id, para, df) {
      
      df2 <- df %>%
        group_by(date) %>%
        summarise(deriv=median(deriv,na.rm=T),sig.incr=median(sig.incr,na.rm=T),sig.decr=median(sig.decr,na.rm=T)) %>%
        ungroup()
      t1 <- last(df2, order_by=df2$date)$deriv
      sig <- 0
      if (t1 > 0 & !is.na(last(df2, order_by=df2$date)$sig.incr)) sig <- 1
      if (t1 < 0 & !is.na(last(df2, order_by=df2$date)$sig.decr)) sig <- 1
      
      if (para=="Nitrate") {
        dfloc$NO3.fut.trnd[dfloc$Well==well_id] <<- t1
        dfloc$NO3.fut.trnd.sig[dfloc$Well==well_id] <<- sig
      }
      if (para=="Chloride") {
        dfloc$Cl.fut.trnd[dfloc$Well==well_id] <<- t1
        dfloc$Cl.fut.trnd.sig[dfloc$Well==well_id] <<- sig  
      }
      if (para=="Sodium") {
        dfloc$Na.fut.trnd[dfloc$Well==well_id] <<- t1
        dfloc$Na.fut.trnd.sig[dfloc$Well==well_id] <<- sig
      }
    }

    
    neat_K5_LM.P = function(muni, well_id, para) {
      
      ctrl <- list(niterEM = 0, optimMethod = "L-BFGS-B") # msVerbose = TRUE,
      Term <- "Year"
      
      Well_Name = Wells %>% filter(Muni == muni & Well == well_id) %>% select(Well) %>% distinct() %>% pull(Well)
      
      # Generate x limits
      Start = Start.Dates %>% filter(Muni == muni, Well == well_id, Parameter == para) %>% pull(Start)
      Xmin = floor(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% arrange(Year) %>% slice(1) %>% pull(Year)/5)*5
      By = case_when((nowyear-1 - Xmin) > 29 ~ 15,
                    (nowyear-1 - Xmin) < 29 ~ 10)
      
      # Specify k
      K = Wells.K %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% pull(K)
      # Kmax = length(unique(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start) %>% pull(Year)))
      # if (K>Kmax) K=Kmax
      Bucket5 = round((nowyear-1 - Start)/(K - 1), 0)
      n = nrow(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para))
      
      # Maximum Allowable Concentration
      MAC = case_when(para == "Nitrate" ~ 10,
                      para == "Chloride" ~ 250,
                      para == "Sodium" ~ 200)
      
      # Padding between label and line
      Label.Space = ifelse(para == "Nitrate", 0.26, 4)
      
      Report.Line = ifelse(para == "Sodium", "dotted", "blank")
      Report.Text = ifelse(para == "Sodium", "Reporting Threshold", NA)
      
      # Modelling
      Projection <- expand.grid(Year=seq(floor(Start/5)*5, endyear, 5))
      
      GAM.Model <- gamm(Value ~ s(Year, k = K), # cc = cyclic cubic
                        data = Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start), correlation = corARMA(form = ~ 1|Year, p = 1))
      
      LM.Model <- lm(Value ~ Year, data = Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start))
      
      if (para=="Nitrate") {
        dfloc$NO3.status[dfloc$Well==well_id] <<- ODWQS.status(LM.Model,GAM.Model,10)
        dfloc$NO3.pred.LM[dfloc$Well==well_id] <<- predict(LM.Model, data.frame(Year = c(endyear)))
        dfloc$NO3.pred.GAM[dfloc$Well==well_id] <<- predict(GAM.Model$gam, data.frame(Year = c(endyear)))
      }
      if (para=="Chloride") {
        dfloc$Cl.status[dfloc$Well==well_id] <<- ODWQS.status(LM.Model,GAM.Model,250)
        dfloc$Cl.pred.LM[dfloc$Well==well_id] <<- predict(LM.Model, data.frame(Year = c(endyear)))
        dfloc$Cl.pred.GAM[dfloc$Well==well_id] <<- predict(GAM.Model$gam, data.frame(Year = c(endyear)))      
      }
      if (para=="Sodium") {
        dfloc$Na.status[dfloc$Well==well_id] <<- ODWQS.status(LM.Model,GAM.Model,200)
        dfloc$Na.pred.LM[dfloc$Well==well_id] <<- predict(LM.Model, data.frame(Year = c(endyear)))
        dfloc$Na.pred.GAM[dfloc$Well==well_id] <<- predict(GAM.Model$gam, data.frame(Year = c(endyear)))
      }
      #print(summary(GAM.Model$gam))
      
      # Generate y limits
      Min = min(min(predict(GAM.Model$gam, level = 0, newdata = Projection, type = "response")), # Min of the GAM prediction
                min(predict(LM.Model, level = 0, newdata = Projection, type = "response")), # Min of the LM prediction
                Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% summarise(Min = min(Value)) %>% pull(Min)) # Min of the actual values
      Ymin = ifelse(para == "Chloride", floor(Min/10)*10, 0)
      
      Division = case_when(para == "Nitrate" ~ 2,
                          para == "Chloride" ~ 15,
                          para == "Sodium" ~ 10)
      
      Max = max(max(predict(GAM.Model$gam, level = 0, newdata = Projection, type = "response")), # Min of the GAM prediction
                max(predict(LM.Model, level = 0, newdata = Projection, type = "response")), # Min of the LM prediction
                Wells %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% summarise(Max = max(Value)) %>% pull(Max)) # Min of the actual values
      
      Ymax = ceiling(Max/Division)*Division
      
      #
      
      want.New <- seq(1, nrow(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start)), length.out = 200)
      pdat.New <- with(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start), data.frame(Year = Year[want.New]))
      p.GAM.Model <- predict(GAM.Model$gam, newdata = pdat.New, type = "terms",  se.fit = TRUE)
      pdat.GAM.Model <- transform(pdat.New, p.GAM.Model = p.GAM.Model$fit[,1], se2 = p.GAM.Model$se.fit[,1])
      df.res.GAM.Model <- df.residual(GAM.Model$gam)
      crit.t.GAM.Model <- qt(0.025, df.res.GAM.Model, lower.tail = FALSE)
      pdat.GAM.Model <- transform(pdat.GAM.Model,
                                  upper = p.GAM.Model + (crit.t.GAM.Model * se2),
                                  lower = p.GAM.Model - (crit.t.GAM.Model * se2))
      d.GAM.Model <- Deriv(GAM.Model)
      dci.GAM.Model <- confint(d.GAM.Model, term = Term)
      dsig.GAM.Model <- signifD(pdat.GAM.Model$p.GAM.Model, d = d.GAM.Model[[Term]]$deriv,
                                + dci.GAM.Model[[Term]]$upper, dci.GAM.Model[[Term]]$lower)
      
      future.trending.WQ(well_id,para,data.frame(date=as.integer(d.GAM.Model$eval),deriv=d.GAM.Model$Year$deriv,sig.incr=dsig.GAM.Model$incr,sig.decr=dsig.GAM.Model$decr))
      
      
      ggplot(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para), aes(Year, Value)) +
        geom_point(colour = "grey50", alpha = 0.6) +
        # This line is the expansion (LM)
        geom_smooth(data = Projection, aes(y = predict(LM.Model, level = 0, newdata = Projection, type = "response"),
                                          colour = "LM"), linewidth = 1.3, se = FALSE) +
        # This line is the expansion (GAM K = 5)
        geom_smooth(data = Projection, aes(y = predict(GAM.Model$gam, level = 0, newdata = Projection, type = "response"),
                                          colour = "K5"), linewidth = 1.3, se = FALSE) +
        # Reporting
        geom_hline(aes(yintercept = 20), linewidth = 1, linetype = Report.Line, colour = "grey50") +
        geom_text(aes(Xmin, 21, label = Report.Text), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
        # Half MAC
        geom_hline(aes(yintercept = MAC/2), linetype = "dashed", linewidth = 1, colour = "grey50") +
        geom_text(aes(Xmin, MAC/2 + Label.Space, label = "Half MAC"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
        # MAC
        geom_hline(aes(yintercept = MAC), linetype = "dashed", linewidth = 1, colour = "grey40") +
        geom_text(aes(Xmin, MAC + Label.Space, label = "Maximum Acceptable Concentration"), colour = "grey30", hjust = 0, vjust = 0, check_overlap = TRUE) +
        scale_colour_manual(values = c("K5" = "#007DA5", "LM" ="#011E41"),
                            labels = c(paste0("GAM (Win. = ", Bucket5, "y)"), "Linear"),
                            name = NULL) +
        scale_x_continuous(breaks = seq(floor(Xmin/10)*10, endyear, by = By), limits = c(Xmin, endyear), name = NULL) +
        scale_y_continuous(name = paste0(para, " (mg/L)"), expand = c(0, 0)) +
        coord_cartesian(ylim = c(Ymin, Ymax)) +
        theme_bw(base_family = "sans") +
        # ggtitle(Well_Name,subtitle=paste0("Projections (n = ",n,")")) + 
        ggtitle(Well_Name,subtitle="Projections") + 
        theme(plot.title = element_text(size = 11),
              plot.subtitle = element_text(size = 9),
              axis.text.y = element_text(size = 10),
              axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 10),
              axis.title = element_text(size = 11),
              legend.text = element_text(size = 9),
              legend.position = "bottom")
      
    }
    
    
    # Test
    # neat_K5_LM.P(muni = "Georgetown", well_id = "Cedarvale 1/1A", para = "Chloride")
    # neat_K5_LM.P(muni = "Orangeville" , well_id = "Well 10", para = "Sodium")
    # neat_K5_LM.P(muni = "Orangeville" , well_id = "Well 5", para = "Nitrate")
    
    #   Blank plot
    ggblank <- function(msg="There is insufficient data\nto make a projection") {
      ggplot() + 
        annotate("text",x=1,y=1,size=4,label=msg) + 
        theme_void()
    }
    
    #   2d: Assemble Figures ####
    
    
    # Assemble small (Only 2a and 2c; insufficient seasonal data)
    Assembly.Two = function(muni, well_id, para) {

      # need to check if the number of years with data satisfy the knot criteria imposed on the GAMM (see neat_K5_LM.P)
      Start = Start.Dates %>% filter(Muni == muni, Well == well_id, Parameter == para) %>% pull(Start)
      K = Wells.K %>% filter(Muni == muni & Well == well_id & Parameter == para) %>% pull(K)
      Kmax = length(unique(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para & Year >= Start) %>% pull(Year)))
      Bucket5 = round((nowyear-1 - Start)/(K - 1), 0)
      n = nrow(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para))

      if (K>Kmax | Bucket5<3 | n<35 ) {
        plot_grid(neat_K5_K3(muni = muni, well_id = well_id, para = para),
                  ggblank(),
                  nrow = 1)     
      } else {
        plot_grid(neat_K5_K3(muni = muni, well_id = well_id, para = para),
                  neat_K5_LM.P(muni = muni, well_id = well_id, para = para),
                  nrow = 1)      
      }
    }
    
    # Assemble big (annual, seasonal, prediction)
    Assembly.Three = function(muni, well_id, para) {
      
      plot_grid(neat_K5_K3(muni = muni, well_id = well_id, para = para),
                neat_S(muni = muni, well_id = well_id, para = para),
                neat_K5_LM.P(muni = muni, well_id = well_id, para = para),
                nrow = 1)
      
    }
    
    
    # Test
    # Assembly.Three(muni = "Orangeville", well = "Well 9A", para = "Chloride")
    # Assembly.Two(muni = "Georgetown", well_id = "C1", para = "Chloride")
    
    # Suggested sizes for individual figures
    # Assembly.Three(muni = "Orangeville", well_id = "Well 9A", para = "Chloride") #%>%
    #   # ggsave(path = "dat/Report Figures",
    #   #        file = paste0("Appendix Chloride Orangeville 9A Seasonal.png"),
    #   #        width = 24.5,
    #   #        height = 9.5,
    #   #        dpi = 300,
    #   #        units = "cm")
    # 
    # Assembly.Two(muni = "Georgetown", well_id = "Cedarvale 4A", para = "Nitrate") #%>%
    #   # ggsave(path = "dat/Report Figures",
    #   #        file = "Appendix Nitrate Georgetown C4A.png",
    #   #        width = 17,
    #   #        height = 9.5,
    #   #        dpi = 300,
    #   #        units = "cm")
    # 
    # #
    
    # Create list of wells with seasonal
    Seasonal.List <- Wells.Seasonal %>%
      select(Muni, Well, Parameter) %>%
      reframe(named_vec = list(Muni, Well, Parameter)) %>%
      deframe() %>%
      set_names(c("Muni", "Well", "Parameter"))
    
    # Create list of wells without seasonal
    NonSeasonal.List <- Wells %>%
      # Remove all sites that can't be analyzed
      inner_join(Wells.K %>%
                  filter(!is.na(K))) %>%
      select(Muni, Well, Parameter) %>%
      distinct() %>%
      anti_join(Wells.Seasonal %>%
                  select(Muni, Well, Parameter)) %>%
      reframe(named_vec = list(Muni, Well, Parameter)) %>%
      deframe() %>%
      set_names(c("Muni", "Well", "Parameter"))
    

    # Create all the three-panel (seasonal) well figures
    Seasonal.List %>%
      pmap(function(Muni, Well, Parameter){
        # Assembly.Three(muni = Muni, well_id = Well, para = Parameter) %>%
        #   ggsave(# path = "dat/seasonal",
        #          # file = paste0(Parameter, " ", Muni, " ", str_replace(Well,"/","-"), ".png"),
        #          path = 'dat/gammfigs',
        #          file = paste0(dfloc$LOC_ID[dfloc$Well==Well],"-",Parameter, ".png"),
        #          width = 24.5,
        #          height = 9.5,
        #          dpi = 300,
        #          units = "cm")
        # dfloc$muni[dfloc$Well==Well] <<- Muni
        if (Parameter=="Nitrate") dfloc$NO3.conf[dfloc$Well==Well] <<- "moderate"
        if (Parameter=="Chloride") dfloc$Cl.conf[dfloc$Well==Well] <<- "moderate"
        if (Parameter=="Sodium") dfloc$Na.conf[dfloc$Well==Well] <<- "moderate"
        
      
        Assembly.Two(muni = Muni, well_id = Well, para = Parameter) %>%
          ggsave(# path = "dat/non-seasonal",
            # file = paste0(Parameter, " ", Muni, " ", str_replace(Well,"/","-"), ".png"),
            path = paste0('dat/',Parameter,"/"),
            file = paste0(dfloc$LOC_ID[dfloc$Well==Well], ".png"),
            width = 17,
            height = 9.5,
            dpi = 300,
            units = "cm")

      })

    # Create all the non-seasonal figures
    # for (i in seq_len(length(NonSeasonal.List$Muni))) {
    #   muni = NonSeasonal.List$Muni[i]
    #   well_id = NonSeasonal.List$Well[i]
    #   para = NonSeasonal.List$Parameter[i]
    #   print(paste(muni,well_id,para))
    #   print(Wells %>% filter(Muni == muni & Well == well_id & Parameter == para))
    #   Assembly.Two(muni = muni, well_id = well_id, para = para)
    # }

    NonSeasonal.List %>%
      pmap(function(Muni, Well, Parameter){
        # dfloc$muni[dfloc$Well==Well] <<- Muni
        if (Parameter=="Nitrate") dfloc$NO3.conf[dfloc$Well==Well] <<- "low"
        if (Parameter=="Chloride") dfloc$Cl.conf[dfloc$Well==Well] <<- "low"
        if (Parameter=="Sodium") dfloc$Na.conf[dfloc$Well==Well] <<- "low"
        
        Assembly.Two(muni = Muni, well_id = Well, para = Parameter) %>%
          ggsave(# path = "dat/non-seasonal",
                # file = paste0(Parameter, " ", Muni, " ", str_replace(Well,"/","-"), ".png"),
                path = paste0('dat/',Parameter,"/"),
                file = paste0(dfloc$LOC_ID[dfloc$Well==Well], ".png"),
                width = 17,
                height = 9.5,
                dpi = 300,
                units = "cm")

      })
  }
  return(dfloc)
}
#


