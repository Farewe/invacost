#' @export
#' @method print invacost.annual.est
print.invacost.annual.est <- function(x, ...)
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
#' @method str invacost.annual.est
str.invacost.annual.est <- function(object, ...)
{
  args <- list(...)
  if(is.null(args$max.level))
  {
    args$max.level <- 2
  }
  NextMethod("str", object = object, max.level = args$max.level)
}

#' @export
#' @method plot invacost.annual.est
plot.invacost.annual.est <- function(x, ...)
{
  print(x$plot)
}

