#' @export
#' @method print invacost.annual.est
print.invacost.annual.est <- function(x, ...)
{
  cat("Estimation of annual cost values of invasive alien species over time\n")
  cat(paste0("- Temporal interval of data : [", 
             min(x$cost.data$Year, na.rm = TRUE),
             ", ",
             max(x$cost.data$Year, na.rm = TRUE), "]"))
  cat(paste0("- Temporal interval used for model calibration: ", 
             min(x$cost.data$Year, na.rm = TRUE)))
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

#' @export
#' @method print VSSampledPoints
print.VSSampledPoints <- function(x, ...)
{
  # Next line is to ensure retrocompatibility with earlier versions of
  # virtualspecies where no print function was designed for VSSampledPoints
  if(!is.list(x$detection.probability))
  {
    print(x)
  } else
  {
    cat(paste("Occurrence points sampled from a virtual species"))
    cat(paste("\n\n- Type:", x$type))
    cat(paste("\n- Number of points:", nrow(x$sample.points)))
    if(length(x$bias))
    {
      cat("\n- Sampling bias: ")
      cat(paste("\n   .Bias type:", 
                x$bias$bias))
      cat(paste("\n   .Bias strength:",
                x$bias$bias.strength))
    } else
    {
      cat("\n- No sampling bias")
    }
    cat(paste0("\n- Detection probability: "))
    cat(paste0("\n   .Probability: ", x$detection.probability$detection.probability))
    cat(paste0("\n   .Corrected by suitability: ", x$detection.probability$correct.by.suitability))
    cat(paste0("\n- Probability of identification error (false positive): ", x$error.probability))
    if(length(x$sample.prevalence))
    {
      cat(paste0("\n- Sample prevalence: "))
      cat(paste0("\n   .True:", x$sample.prevalence["true.sample.prevalence"]))
      cat(paste0("\n   .Observed:", x$sample.prevalence["observed.sample.prevalence"]))
    }
    cat(paste0("\n- Multiple samples can occur in a single cell: ", 
               ifelse(x$replacement, "Yes", "No")))
    cat("\n\n")
    if(nrow(x$sample.points) > 10)
    {
      cat("First 10 lines: \n")
      print(x$sample.points[1:10, ])
      cat(paste0("... ", nrow(x$sample.points) - 10, " more lines.\n"))
    } else
    {
      print(x$sample.points)
    }
  }
}

#' @export
#' @method str VSSampledPoints
str.VSSampledPoints <- function(object, ...)
{
  args <- list(...)
  if(is.null(args$max.level))
  {
    args$max.level <- 2
  }
  NextMethod("str", object = object, max.level = args$max.level)
}