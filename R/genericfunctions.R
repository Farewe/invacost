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
#' @method print invacost.costs.per.period
print.invacost.costs.per.period <- function(x, ...)
{
  cat("Average annual cost of invasive species over time periods\n")
  cat(paste0("\n- Temporal interval of data : [", 
             x$parameters$minimum.year,
             ", ",
             x$parameters$maximum.year, "]"))
  cat(paste0("\n- Cost transformation: ", 
             x$parameters$cost.transformation))
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
#' @method str invacost.costs.per.period
str.invacost.costs.per.period <- function(object, ...)
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

#' @export
#' @method plot invacost.costs.per.period
plot.invacost.costs.per.period <- function(x, ...)
{
  print(x$plot)
}
