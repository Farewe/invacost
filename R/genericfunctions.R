#' @export
#' @method print invacost.trendcost
print.invacost.trendcost <- function(x, ...)
{
  cat("Estimation of annual cost values of invasive alien species over time\n")
  cat(paste0("\n- Temporal interval of data : [", 
             x$parameters$minimum.year,
             ", ",
             x$parameters$maximum.year, "]"))
  cat(paste0("\n- Temporal interval used for model calibration: [", 
             x$parameters$minimum.year,
             ", ",
             min(x$parameters$incomplete.year.threshold,
                 x$parameters$maximum.year), "]"))
  cat(paste0("\n- Cost transformation: ", 
             x$parameters$cost.transformation))
  cat(paste0("\n- Values transformed in US$ million: ", 
             ifelse(x$parameters$in.millions, "Yes", "No")))
  cat(paste0("\n- Estimated average annual cost of invasive alien species in ",
             x$parameters$final.year, ":\n",
             "\n   o Linear regression: ",
             "\n     . Linear: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["ols.linear"], accuracy = .01),
             "\n     . Quadratic: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["ols.quadratic"], accuracy = .01),
             "\n   o Robust regression: ",
             "\n     . Linear: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["robust.linear"], accuracy = .01),
             "\n     . Quadratic: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["robust.quadratic"], accuracy = .01),
             "\n   o Multiple Adapative Regression Splines: US$ ",
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["mars"], accuracy = .01),
             "\n   o Generalized Additive Model: US$ ",
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["gam"], accuracy = .01),
             "\n   o Quantile regression: ",
             "\n     . Quantile 0.1: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quantile.0.1"], accuracy = .01),
             "\n     . Quantile 0.5: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quantile.0.5"], accuracy = .01),
             "\n     . Quantile 0.9: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quantile.0.9"], accuracy = .01),
             "\n"
             ))
  cat(paste0("\nYou can inspect the summary of each fitted model with object$model.summary\n"))
}

#' @export
#' @method print invacost.rawcost
print.invacost.rawcost <- function(x, ...)
{
  cat("Average annual cost of invasive species over time periods\n")
  cat(paste0("\n- Temporal interval of data : [", 
             x$parameters$minimum.year,
             ", ",
             x$parameters$maximum.year, "]"))
  cat(paste0("\n- Values transformed in US$ million: ", 
             ifelse(x$parameters$in.millions, "Yes", "No")))
  cat(paste0("\n- Number of cost estimates: ",
             x$parameters$number.of.estimates, " (number of individual year values: ",
             x$parameters$number.of.year.values, ")"))
  cat(paste0("\n- Cost values in US$ ",
             ifelse(x$parameters$in.millions, "millions", ""),
             ":")) 
  cat(paste0("\n    o Total cost over the entire period ",
             scales::comma(x$average.total.cost$total_cost, accuracy = .01)))
  cat(paste0("\n    o Average annual cost over the entire period ",
             scales::comma(x$average.total.cost$annual_cost, accuracy = .01)))
  cat(paste0("\n    o Average annual cost over each period\n\n"))
  x2 <- x$average.cost.per.period
  x2$total_cost <- scales::comma(x2$total_cost, accuracy = .01)
  x2$annual_cost <- scales::comma(x2$annual_cost, accuracy = .01)
  print(x2)
}

#' @export
#' @method print invacost.modelsummary
print.invacost.modelsummary <- function(x, ...)
{
  cat("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Summary of model fits ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n")
  cat("______________________________     Ordinary Least Square regression models  _______________________________\n\n\n")
  cat(">>>>>>>>       Linear regression\n\n")
  cat("R squared: ", x$ols.linear$r.squared, " - Adjusted R squared: ", x$ols.linear$r.squared)
  print(x$ols.linear$coeftest)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat("\n\n>>>>>>>>       Quadratic regression\n\n")
  cat("R squared: ", x$ols.quadratic$r.squared, " - Adjusted R squared: ", x$ols.quadratic$r.squared)
  print(x$ols.quadratic$coeftest)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat("______________________________           Robust regression models           _______________________________\n\n\n")
  
  cat(">>>>>>>>       Linear regression\n\n")
  print(x$robust.linear)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat("\n\n>>>>>>>>       Quadratic regression\n\n")
  print(x$robust.quadratic)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat("______________________________          Generalized Additive Models          _______________________________\n\n\n")
  print(x$gam)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat("______________________________     Multiple Adaptive Regression Splines      _______________________________\n\n\n")
  print(x$mars)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat("______________________________            Quantile regressions               _______________________________\n\n\n")
  cat(">>>>>>>>       0.1 quantile \n\n")
  print(x$qt0.1)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat(">>>>>>>>       0.5 quantile \n\n")
  print(x$qt0.5)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
  cat(">>>>>>>>       0.9 quantile \n\n")
  print(x$qt0.9)
  cat("------------------------------------------------------------------------------------------------------------\n\n")
  
}


#' @export
#' @method str invacost.trendcost
str.invacost.trendcost <- function(object, ...)
{
  args <- list(...)
  if(is.null(args$max.level))
  {
    args$max.level <- 2
  }
  NextMethod("str", object = object, max.level = args$max.level)
}

#' @export
#' @method str invacost.rawcost
str.invacost.rawcost <- function(object, ...)
{
  args <- list(...)
  if(is.null(args$max.level))
  {
    args$max.level <- 2
  }
  NextMethod("str", object = object, max.level = args$max.level)
}

#' Plot model predictions of cost trends over time 
#'
#' This function provides different plotting methods for the estimated annual
#' cost of invasive species based on the temporal trend of costs.
#' 
#' @param x The output object from \code{\link{costTrendOverTime}}
#' @param plot.type \code{"single"} or \code{"facets"}. Defines the type of plot
#' you want to make: a single facet with all models (\code{"single"}), or a 
#' facet per category of model (\code{"facets"})
#' @param plot.breaks a vector of numeric values indicating the plot breaks 
#' for the Y axis (cost values)
#' @param models the models the user would like to appear in the plots. Can be
#' any subset of the models included in 'costTrendOverTime'. Default is all models.
#' @param graphical.parameters set this to \code{"manual"} if you want to 
#' customise ggplot2 parameters. 
#' By default, the following layers are configured: ylab, xlab, scale_x_continuous,
#' theme_bw and, if \code{cost.transf = "log10"}, scale_y_log10 and 
#' annotation_logticks. If you specify \code{grahical.parameters = "manual"},
#' all defaults will be ignored.
#' @param ... additional arguments, none implemented for now
#' @export
#' @import ggplot2
#' @importFrom grDevices grey rgb
#' @note 
#' Error bands represent 95% confidence intervals for OLS regression, robust
#' regression, GAM and quantile regression. We cannot construct confidence 
#' intervals around the mean for MARS techjniques. However, we can estimate
#' prediction intervals by fitting a variance model to MARS residuals. Hence,
#' the error bands for MARS model represent 95% prediction intervals estimated
#' by fitting a linear model to the residuals of the MARS model. To learn more
#' about this, see \code{\link[earth]{varmod}}
#' 
#' 
#' If the legend appears empty (no colours) on your computer screen, try to
#' zoom in the plot, or to write to a file. There is a rare bug where under
#' certain conditions you cannot see the colours in the legend, because of their
#' transparency; zooming in or writing to a file are the best workarounds.
#' @examples
#' data(invacost)
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_low_margin",
#'                                   endcolumn = "Probable_ending_year_low_margin")
#' costdb <- db.over.time[db.over.time$Implementation == "Observed", ]
#' costdb <- costdb[which(costdb$Method_reliability == "High"), ]
#' res <- costTrendOverTime(costdb)
#' plot(res)
#' plot(res, plot.type = "single")
#' @export
#' @method plot invacost.trendcost
plot.invacost.trendcost <- function(x,
                                    plot.breaks = 10^(-15:15),
                                    plot.type = "facets",
                                    models = c("ols.linear", 
                                               "ols.quadratic", 
                                               "robust.linear",
                                               "robust.quadratic",
                                               "gam",
                                               "mars",
                                               "quantile"),
                                    graphical.parameters = NULL,
                                    ...)
{
  # 1. We create the ggplot here ---------------
  p <- ggplot()
  
  # Setting up graphical.parameters
  if(is.null(graphical.parameters))
  {
    # 2a. If user do not specify graphical parameters we create them here ---------------
    p <- p + 
      ylab(paste0("Annual cost in US$ ", 
                  ifelse(x$parameters$in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      theme_bw()
    if(x$parameters$cost.transformation == "log10")
    {
      # 3a. We define axes here for log-transformed data ---------------
      p <- p +
        scale_y_log10(breaks = plot.breaks,
                      labels = scales::comma) +
        annotation_logticks()
    } else if(x$parameters$cost.transformation == "none")
    {
      # 3b. We define axes here for untransformed data ---------------
      p <- p +
        scale_y_continuous(labels = scales::comma)
    } else
    {
      stop("If you made a manual transformation (other than log10), then you
           will have to make the plot by yourself.")
    }
  } else 
  {
    # Workaround for retrocompatibility
    if(graphical.parameters == "manual")
    {
      graphical.parameters <- NULL
    }
    # 4. Adding user-defined parameters to the plot ---------------
    p <- p + graphical.parameters
  }
  
  # Changing order of factors for points 
  x$cost.data$Calibration <- factor(x$cost.data$Calibration, 
                                             levels = c("Included", "Excluded"))
  # Preparing model predictions for plots
  model.preds <- x$estimated.annual.costs
  model.preds$Model <- as.character(model.preds$model)
  model.preds$Model[model.preds$model == "OLS regression" & 
                      model.preds$Details == "Linear"] <- "OLS linear regression"
  model.preds$Model[model.preds$model == "OLS regression" 
                    & model.preds$Details == "Quadratic"] <- "OLS quadratic regression"
  model.preds$Model[model.preds$model == "Robust regression" & 
                      model.preds$Details == "Linear"] <- "Robust linear regression"
  model.preds$Model[model.preds$model == "Robust regression" & 
                      model.preds$Details == "Quadratic"] <- "Robust quadratic regression"
  model.preds$Model[model.preds$model == "Quantile regression"] <-
    paste0(model.preds$Details[model.preds$model == "Quantile regression"],
           " regression")
  
  # Ordering model names
  model.preds$Model <- factor(model.preds$Model,
                              levels = c("OLS linear regression", 
                                         "OLS quadratic regression",
                                         "Robust linear regression",
                                         "Robust quadratic regression",
                                         "MARS",
                                         "GAM",
                                         paste("Quantile", c(0.1, 0.5, 0.9), "regression")))
  model.preds$model <- factor(model.preds$model,
                              levels = c("OLS regression", "Robust regression",
                                         "GAM", "MARS", "Quantile regression"))
  
  # Limiting plots to user selected
  #Relabel models parameter to match plot labeling from above
  models[models=="ols.linear"] <- "OLS linear regression"
  models[models=="ols.quadratic"] <- "OLS quadratic regression"
  models[models=="gam"] <- "GAM"
  models[models=="mars"] <- "MARS"
  models <- rep(models,1+2*(models=="quantile"))
  models[models=="quantile"] <- c("Quantile 0.1 regression","Quantile 0.5 regression","Quantile 0.9 regression")
  models[models=="robust.linear"] <- "Robust linear regression"
  models[models=="robust.quadratic"] <- "Robust quadratic regression"
  model.preds <- model.preds[model.preds$Model %in% models,]
  
  
  # Creating a colourblind palette (Wong 2011)
  # to best distinguish models
  alpha <- round(.8 * 255)
  cols <- c(`OLS linear regression` = rgb(86, 180, 233, alpha = alpha,
                                      maxColorValue = 255), # Sky blue
            `OLS quadratic regression` = rgb(230, 159, 0, alpha = alpha,
                                         maxColorValue = 255), # Orange
            `Robust linear regression` = rgb(0, 114, 178, alpha = alpha,
                                          maxColorValue = 255), # Blue
            `Robust quadratic regression` = rgb(213, 94, 0, alpha = alpha,
                                             maxColorValue = 255), # Vermillion
            `MARS` = rgb(204, 121, 167, alpha = alpha,
                         maxColorValue = 255), # Reddish purple
            `GAM` = rgb(0, 158, 115, alpha = alpha,
                        maxColorValue = 255), # Bluish green
            `Quantile 0.5 regression` = grey(0.5, alpha = alpha / 255),
            `Quantile 0.1 regression` = grey(0.25, alpha = alpha / 255),
            `Quantile 0.9 regression` = grey(0, alpha = alpha / 255)
  )
  
  
  if(plot.type == "single")
  {
    # 5. Single plot --------------------
    p <-
      p +
      geom_point(data = x$cost.data, 
                 aes_string(x = "Year",
                            y = "Annual.cost",
                            shape = "Calibration"),
                 col = grey(.4)) +
      geom_line(data = model.preds, 
                aes_string(x = "Year",
                           y = "fit",
                           col = "Model"),
                size = 1) +
      scale_discrete_manual(aesthetics = "col",
                            values = cols)
      
  } else if(plot.type == "facets")
  { 
    # 6. Facet plot --------------------
    p <-
      p +
      geom_point(data = x$cost.data, 
                 aes_string(x = "Year",
                            y = "Annual.cost",
                            shape = "Calibration"),
                 col = grey(.4)) +
      geom_line(data = model.preds, 
                aes_string(x = "Year",
                           y = "fit",
                           col = "Model"),
                size = 1) +
      geom_ribbon(data = model.preds, 
                  aes_string(x = "Year",
                             ymin = "lwr",
                             ymax = "upr",
                             group = "Details"),
                  alpha = .1) + 
      facet_wrap (~ model,
                  scales = "free_y") +
      scale_discrete_manual(aesthetics = "col",
                            values = cols)
    message("Note that MARS error bands are prediction intervals and not confidence interval (see ?plot.invacost.trendcost)\n")
    
  }
  

  return(p)
}

#' Plot raw cumulated cost of invasive species over different periods of time
#' 
#' This function provides different plotting methods for the raw average annual 
#' cost of invasive species over different periods of time
#' 
#' @param x The output object from \code{\link{calculateRawAvgCosts}}
#' @param plot.type \code{"points"} or \code{"bars"}. Defines the type of plot
#' you want to make; bars are not advised in log scale because the base value (0)
#' is infinite in log-scale. 
#' @param plot.breaks aa vector of numeric values indicating the plot breaks 
#' for the Y axis (cost values)
#' @param average.annual.values if \code{TRUE}, the plot will represent average
#' annual values rather than cumulative values over the entire period
#' @param cost.transf Type of transformation you want to apply on cost values.
#' Specify \code{NULL} to avoid any transformation. Only useful
#' for graphical representation.
#' @param graphical.parameters set this to \code{"manual"} if you want to 
#' customise ggplot2 parameters. 
#' By default, the following layers are configured: ylab, xlab, scale_x_continuous,
#' theme_bw and, if \code{cost.transf = "log10"}, scale_y_log10 and 
#' annotation_logticks. If you specify \code{grahical.parameters = "manual"},
#' all defaults will be ignored.
#' @param ... additional arguments, none implemented for now
#' @export
#' @import ggplot2
#' @examples
#' data(invacost)
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_low_margin",
#'                                   endcolumn = "Probable_ending_year_low_margin")
#' costdb <- db.over.time[db.over.time$Implementation == "Observed", ]
#' costdb <- costdb[which(costdb$Method_reliability == "High"), ]
#' res <- calculateRawAvgCosts(costdb)
#' plot(res)
#' plot(res, plot.type = "bars")
#' @method plot invacost.rawcost
plot.invacost.rawcost <- function(x,
                                  plot.breaks = 10^(-15:15),
                                  plot.type = "points",
                                  average.annual.values = TRUE,
                                  cost.transf = "log10",
                                  graphical.parameters = NULL,
                                  ...)
{
  if(is.null(cost.transf))
  {
    cost.transf <- "none"
  }
  costperiod <- x$average.cost.per.period
  costperiod$middle.years <- costperiod$initial_year +
    (costperiod$final_year - 
       costperiod$initial_year) / 2 
  
  ggtext <- data.frame(x = x$parameters$minimum.year,
                       y = x$average.total.cost$annual_cost,
                       text = paste0("Average ",  
                                     x$parameters$minimum.year, 
                                     " - ", x$parameters$maximum.year, "\n",
                                     scales::comma(x$average.total.cost$annual_cost,
                                                   accuracy = .01)))
  
  if(!average.annual.values)
  {
    # In case we don't plot average annual values, then we change 'annual_cost' 
    # to plot the total cost of the period rather than the average annual cost
    costperiod$annual_cost <- costperiod$total_cost
  }
  
  # 1. We create the ggplot here ---------------
  p <- ggplot(costperiod)
  
  # Setting up graphical.parameters
  if(is.null(graphical.parameters))
  {
    # 2a. If user do not specify graphical parameters we create them here ---------------
    p <- p + 
      ylab(paste0(ifelse(average.annual.values,
                         "Average annual",
                         "Total"),
                  " cost per period in US$ ", 
                  ifelse(x$parameters$in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      scale_x_continuous(breaks = x$year.breaks) +
      theme_bw()
    if(cost.transf == "log10")
    {
      if(plot.type == "bars")
      {
        # Because we are in log, we need to find a proper start for the barplots
        # If all cost values are above 1, we will set the base value to 1
        # Otherwise we take the lower multiple of 10 that is closest to the minimum
        # value
        base.val <- ifelse(min(costperiod$annual_cost) > 1,
                           10^0, # or this: floor(log10(min(costperiod$annual_cost) - 1)), (change above to min(costperiod$annual_cost) > 2)
                           10^-(attr(regexpr("(?<=\\.)0+", 
                                             min(costperiod$annual_cost), 
                                             perl = TRUE), 
                                     "match.length") + 1))
        # 3a. We define axes here for log-scale bars ---------------
        p <- 
          p +
          scale_y_log10(breaks = plot.breaks,
                        labels = scales::comma,
                        limits = c(base.val, NA)) +
          annotation_logticks(sides = "l")
      } else
      {
        # 3b. We define axes here for log-scale points ---------------
        p <- 
          p +
          scale_y_log10(breaks = plot.breaks,
                        labels = scales::comma) +
          annotation_logticks(sides = "l")
      }
    } else
    {
      base.val <- 0
      # 3c. We define axes here for non-log plots ---------------
      p <- p + scale_y_continuous(labels = scales::comma)
    }
  } else
  {
    # Workaround for retrocompatibility
    if(graphical.parameters == "manual")
    {
      graphical.parameters <- NULL
    }
    # 4. Adding user-defined graphical parameters to the plot ---------------
    p <- p + graphical.parameters
  }
  
  if(plot.type == "bars")
  {
    ##### 5a. BARPLOTS -------------------------------------------------------------
    p <- p +
      # Bars
      geom_rect(aes_string(xmin = "initial_year",
                           xmax = "final_year",
                           ymin = "base.val", 
                           ymax = "annual_cost"),
                col = "black",
                fill = "white") +
      # Lines between points
      geom_line(aes_string(x = "middle.years",
                           y = "annual_cost"),
                linetype = 2)
  } else if(plot.type == "points")
  {
    ##### 5b. POINT PLOTS ----------------------------------------------------------
    p <- p +
      # Points
      geom_point(aes_string(x = "middle.years",
                            y = "annual_cost")) +
      # Lines between points
      geom_line(aes_string(x = "middle.years",
                           y = "annual_cost"),
                linetype = 2) +
      # Horizontal bars (year span)
      geom_segment(aes_string(x = "initial_year",
                              xend = "final_year",
                              y = "annual_cost",
                              yend = "annual_cost"))
  }
  
  # In case we plot the average annual values, we will add individual years .
  # We prepare the ggplot layer here, called 'individualyears'
  # We add them last to show them on top of everything else.
  if(average.annual.values)
  {
    yeargroups <- dplyr::group_by(x$cost.data,
                                  get(x$parameters$year.column)) 
    
    yearly.cost <- dplyr::summarise(yeargroups, 
                                    Annual.cost = sum(get(x$parameters$cost.column)))
    names(yearly.cost)[1] <- "Year"
    
    # 6. Individual years and average over entire period --------------
    p <- p +
      # Points
      geom_point(data = yearly.cost,
                 mapping = aes_string(x = "Year",
                                      y = "Annual.cost"),
                 alpha = .2) + 
      # Text of average annual cost
      geom_text(data = ggtext,
                hjust = 0,
                aes_string(x = "x", y = "y", label = "text")) +
      # Horizontal line for average annual cost
      geom_hline(data = x$average.total.cost,
                 aes_string(yintercept = "annual_cost"),
                 linetype = 3)
  }
  
  
  return(p)
}



