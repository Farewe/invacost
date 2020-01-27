#' @export
#' @method print invacost.trend.over.time
print.invacost.trend.over.time <- function(x, ...)
{
  cat("Estimation of annual cost values of invasive alien species over time\n")
  cat(paste0("\n- Temporal interval of data : [", 
             x$parameters$minimum.year,
             ", ",
             x$parameters$maximum.year, "]"))
  cat(paste0("\n- Temporal interval used for model calibration: [", 
             x$parameters$minimum.year,
             ", ",
             x$parameters$incomplete.year.threshold, "]"))
  cat(paste0("\n- Cost transformation: ", 
             x$parameters$cost.transformation))
  cat(paste0("\n- Values transformed in US$ million: ", 
             ifelse(x$parameters$in.millions, "Yes", "No")))
  cat(paste0("\n- Estimated average annual cost of invasive alien species in ",
             x$parameters$final.year, ":\n",
             "\n   o Linear regression: US$ ",
             "\n     . Linear: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["linear"]),
             "\n     . Quadratic: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quadratic"]),
             "\n   o Multiple Adapative Regresssion Splines: US$ ",
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["mars"]),
             "\n   o Generalized Additive Model: US$ ",
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["gam"]),
             "\n   o Quantile regression: ",
             "\n     . Quantile 0.1: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quantile.0.1"]),
             "\n     . Quantile 0.5: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quantile.0.5"]),
             "\n     . Quantile 0.9: US$ ", 
             ifelse(x$parameters$in.millions, "million ", ""),
             scales::comma(x$final.year.cost["quantile.0.9"])
             ))
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
  cat(paste0("\n- Cost values in US$ ",
             ifelse(x$parameters$in.millions, "millions", ""),
             ":")) 
  cat(paste0("\n    o Total cost over the entire period ",
             scales::comma(x$average.total.cost$total_cost)))
  cat(paste0("\n    o Average annual cost over the entire period ",
             scales::comma(x$average.total.cost$annual_cost)))
  cat(paste0("\n    o Average annual cost over each period\n\n"))
  x2 <- x$average.cost.per.period
  x2$total_cost <- scales::comma(x2$total_cost)
  x2$annual_cost <- scales::comma(x2$annual_cost)
  print(x2)
}

#' @export
#' @method str invacost.trend.over.time
str.invacost.trend.over.time <- function(object, ...)
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


#' @export
#' @method plot invacost.trend.over.time
plot.invacost.trend.over.time <- function(x, ...)
{
  print(x$plot)
}

#' Plot raw cumulated cost of invasive species over different periods of time
#' 
#' This function provides different plotting method for the raw average annual 
#' cost of invasive species over different periods of time
#' 
#' @param plot.type \code{"points"} or \code{"bars"}. Defines the type of plot
#' you want to make; bars are not advised in log scale because the base value (0)
#' is infinite in log-scale. 
#' @param plot.breaks a vector of numeric values indicating the plot breaks 
#' for the axis of average annual cost values. 
#' @param average.annual.values if \code{TRUE}, the plot will represent average
#' annual values rather than cumulative values over the entire period
#' @param cost.transf Type of transformation you want to apply on cost values.
#' Specify \code{NA} or \code{NULL} to avoid any transformation. Only useful
#' for graphical representation.
#' @param graphical.parameters ggplot2 layers and other customisation parameters,
#' to specify if you want to customise ggplot2 graphs.
#' By default, the following layers are configured: ylab, xlab, scale_x_continuous,
#' theme_bw and, if \code{cost.transf = "log10"}, scale_y_log10 and 
#' annotation_logticks.
#' @param ... additional arguments, none implemented for now
#' @export
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
plot.invacost.rawcost <- function(costperperiod,
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
  costperiod <- costperperiod$average.cost.per.period
  costperiod$middle.years <- costperiod$initial_year +
    (costperiod$final_year - 
       costperiod$initial_year) / 2 
  
  ggtext <- data.frame(x = costperperiod$parameters$minimum.year,
                       y = costperperiod$average.total.cost$annual_cost,
                       text = paste0("Average over entire period\n",
                                     scales::comma(costperperiod$average.total.cost$annual_cost)))
  
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
                  "cost per period in US$ ", 
                  ifelse(costperperiod$parameters$in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      scale_x_continuous(breaks = costperperiod$year.breaks) +
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
          annotation_logticks()
      } else
      {
        # 3b. We define axes here for log-scale points ---------------
        p <- 
          p +
          scale_y_log10(breaks = plot.breaks,
                        labels = scales::comma) +
          annotation_logticks()
      }
    } else
    {
      base.val <- 0
      # 3c. We define axes here for non-log plots ---------------
      p <- p + scale_y_continuous(labels = scales::comma)
    }
  } else
  {
    # 4. Adding user-defined graphical parameters to the plot ---------------
    p <- p + graphical.parameters
  }
  
  if(plot.type == "bars")
  {
    ##### 5a. BARPLOTS -------------------------------------------------------------
    p <- p +
      # Bars
      geom_rect(aes(xmin = initial_year,
                    xmax = final_year,
                    ymin = base.val, 
                    ymax = annual_cost),
                col = "black",
                fill = "white") +
      # Lines between points
      geom_line(aes(x = middle.years,
                    y = annual_cost),
                linetype = 2)
  } else if(plot.type == "points")
  {
    ##### 5b. POINT PLOTS ----------------------------------------------------------
    p <- p +
      # Points
      geom_point(aes(x = middle.years,
                     y = annual_cost)) +
      # Lines between points
      geom_line(aes(x = middle.years,
                    y = annual_cost),
                linetype = 2) +
      # Horizontal bars (year span)
      geom_segment(aes(x = initial_year,
                       xend = final_year,
                       y = annual_cost,
                       yend = annual_cost))
  }
  
  # In case we plot the average annual values, we will add individual years .
  # We prepare the ggplot layer here, called 'individualyears'
  # We add them last to show them on top of everything else.
  if(average.annual.values)
  {
    yeargroups <- dplyr::group_by(costperperiod$cost.data,
                                  get(costperperiod$parameters$year.column)) 
    
    yearly.cost <- dplyr::summarise(yeargroups, 
                                    Annual.cost = sum(get(costperperiod$parameters$cost.column)))
    names(yearly.cost)[1] <- "Year"
    
    # 6. Individual years and average over entire period --------------
    p <- p +
      # Points
      geom_point(data = yearly.cost,
                 mapping = aes(x = Year,
                               y = Annual.cost),
                 alpha = .2) + 
      # Text of average annual cost
      geom_text(data = ggtext,
                hjust = 0,
                aes(x = x, y = y, label = text)) +
      # Horizontal line for average annual cost
      geom_hline(data = costperperiod$average.total.cost,
                 aes(yintercept = annual_cost),
                 linetype = 3)
  }
  
  print(p)
}



