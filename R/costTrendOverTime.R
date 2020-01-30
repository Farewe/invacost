#' Estimate the trend of invasive species costs over time
#' 
#' This function fits different models on annualised INVACOST data in order to
#' estimate the average trend over time of invasive species costs.
#' 
#' @param costdb The \bold{expanded INVACOST database} output from 
#' \code{\link{expandYearlyCosts}},
#' where annual costs occurring over several years are repeated for each year.
#' @param cost.column Name of the cost column to use in \code{costdb} (usually, 
#' choose between the exchange rate (default) or PPP annualised cost)
#' @param year.column Name of the year column to use in \code{costdb}.
#' @param cost.transf Type of transformation you want to apply on cost values.
#' The default is a log10 transformation, which is commonly applied in economy,
#' allows to fit linear regression with a normal distribution of residuals, 
#' and makes plots easy to read. You can apply another transformation by 
#' specifying the name of the transformation function (e.g., natural
#' logarithm, {\code{"log"}}). Specify \code{NA} or \code{NULL} to avoid any 
#' transformation.
#' @param in.millions If \code{TRUE}, cost values will be transformed in 
#' millions (to make graphs easier to read), else if \code{}, cost values will
#' not be transformed.
#' @param confidence.interval a numeric value between 0 and 1, corresponding
#' to the desired confidence intervals around model predictions.
#' @param minimum.year the starting year of this analysis. By default, 
#' 1960 was chosen because it marks the period from which world bank data is 
#' available for exchange rates and inflation values.
#' @param maximum.year the ending year for this analysis. By default, 2017
#' was chosen as it is the last year for which we have data in INVACOST.
#' @param final.year the year for which you want to obtain the final 
#' average cost estimate from models. Default is 2017.
#' @param incomplete.year.threshold Estimated threshold for incomplete cost 
#' data. All years above or equal to this threshold will be excluded from 
#' model calibration, because of the time-lag between economic impacts of
#' invasive species and the documentation and publication of these impacts.
#' @param incomplete.year.weights A named vector containing weights of years
#' for the regressions. Useful to decrease the weights of incomplete years
#' in regressions. Names of this vector must correspond to years.
#' @param gam.k The smoothing factor of GAM; default value of -1 will let the
#' GAM find the smoothing factor automatically. Provide a manual value if you 
#' have expectations about the shape of the curve and want to avoid overfitting
#' because of interannual variations.
#' @param mars.nk The maximum number of model terms in the MARS model. The default 
#' value of 21 corresponds to the default value calculated in earth package.
#' Lowering this value will reduce the number of terms in the MARS model, which
#' can be useful if you have expectations about the shape of the curve and want
#' to avoid overfitting because of interannual variations.
#' @return a \code{list} with 3 to 6 elements (only the first three will be 
#' provided if you selected a cost transformation different from log10):
#'
#' \itemize{
#' \item{\code{cost.data}: the annualised costs of invasions, as sums of all 
#' costs for each year.}
#' \item{\code{parameters}: parameters used to run the function. The 
#' \code{minimum.year} and \code{maximum.year} are based on the input data
#' (i.e., the user may specify \code{minimum.year = 1960} but the input data may
#' only have data starting from 1970, hence the \code{minimum.year} will be
#'  1970.)}
#' \item{\code{fitted.models}: a list of objects the fitted models.}
#' \item{\code{estimated.annual.costs}: a data.frame containing the predicted 
#' cost values for each year for all the fitted models.}
#' \item{\code{RMSE}: an array containing RMSE of models for the calibration 
#' data and for all data. NOTE: the RMSE for quantile regression is not an 
#' relevant metric. }
#' \item{\code{final.year.cost}: a vector containing the estimated annual
#' costs of invasive species based on all models for \code{final.year}.}
#' }
#' The structure of this object can be seen using \code{str()}
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
#' @importFrom stats lm predict qt residuals
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' 
#' with help from C. Diagne & A.-C. Vaissière
#' @examples
#' data(invacost)
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_low_margin",
#'                                   endcolumn = "Probable_ending_year_low_margin")
#' costdb <- db.over.time[db.over.time$Implementation == "Observed", ]
#' costdb <- costdb[which(costdb$Method_reliability == "High"), ]
#' res <- costTrendOverTime(costdb)
#' res

costTrendOverTime <- function(costdb,
                              cost.column = "Cost_estimate_per_year_2017_USD_exchange_rate",
                              year.column = "Impact_year",
                              cost.transf = "log10",
                              in.millions = TRUE,
                              confidence.interval = 0.95,
                              minimum.year = 1960, 
                              maximum.year = 2017, 
                              final.year = 2017, 
                              incomplete.year.threshold = 2015,
                              incomplete.year.weights = NULL,
                              gam.k = -1,
                              mars.nk = 21
)
{
  if(is.null(cost.transf))
  {
    cost.transf <- "none"
  }

  if(any(costdb[, year.column] < minimum.year))
  {
    warning(paste0("There are ",  length(unique(costdb$Cost_ID[which(costdb[, year.column] < minimum.year)])),
                   " cost values for periods earlier than ",
                   minimum.year, ", which will will be removed.\n"))
    costdb <- costdb[-which(costdb[, year.column] < minimum.year), ]
  }
  
  if(any(costdb[, year.column] > maximum.year))
  {
    warning(paste0("There are cost values for periods later than ",
                   maximum.year, ": ",
                   length(unique(costdb$Cost_ID[which(costdb[, year.column] > maximum.year)])),
                   " different cost estimate(s).\nTheir values later than ",
                   maximum.year,
                   " will be removed.\n"))
    costdb <- costdb[-which(costdb[, year.column] > maximum.year), ]
  }
  
  
  if(final.year > maximum.year |
     final.year > max(costdb[, year.column], na.rm = TRUE))
  {
    warning(paste0("The final year is beyond the range of data,
    which creates an extrapolation situation. Be careful, the models included 
    here may not be realistic for extrapolations, because they do not include
    underlying drivers which my result in non-linearities over time."))
  }
  
  parameters <- list(cost.transformation = cost.transf,
                     incomplete.year.threshold = incomplete.year.threshold,
                     in.millions = in.millions,
                     confidence.interval = confidence.interval,
                     minimum.year = min(costdb[, year.column], na.rm = TRUE), 
                     maximum.year = max(costdb[, year.column], na.rm = TRUE), 
                     final.year = final.year)
                     
  yeargroups <- dplyr::group_by(costdb,
                                get(year.column)) 
  
  yearly.cost <- dplyr::summarise(yeargroups, 
                                  Annual.cost = sum(get(cost.column)))
  names(yearly.cost)[1] <- "Year"
  
  if(!is.null(incomplete.year.weights))
  {
    if(!all(yearly.cost$Year %in% names(incomplete.year.weights)))
    {
      stop("The vector provided in incomplete.year.weights does not have all the
           years in the range of data.")
    } else
    {
      incomplete.year.weights <- incomplete.year.weights[names(incomplete.year.weights) %in%
                                                           yearly.cost$Year]
      incomplete.year.weights <- incomplete.year.weights[match(yearly.cost$Year,
                                                               names(incomplete.year.weights))]
    }
  }
  
  if(in.millions)
  {
    yearly.cost$Annual.cost <- yearly.cost$Annual.cost / 1e6
  }
  
  
  
  if(cost.transf != "none")
  {
    yearly.cost$transf.cost <- do.call(cost.transf, list(yearly.cost$Annual.cost))
  } else
  {
    yearly.cost$transf.cost <- yearly.cost$Annual.cost
  }
  
  if(any(yearly.cost[, "Year"] >= incomplete.year.threshold))
  {
    message(paste0(length(which(yearly.cost[, "Year"] >= incomplete.year.threshold)),
                   " years will not be included in model calibrations because\n",
                   "they occurred later than incomplete.year.threshold (", incomplete.year.threshold,
                   ")\n"))
    yearly.cost$Calibration <- ifelse(yearly.cost$Year < incomplete.year.threshold,
                                       "Included", "Excluded")
    yearly.cost.calibration <- yearly.cost[-which(yearly.cost[, "Year"] >= incomplete.year.threshold), ]
    if(!is.null(incomplete.year.weights))
    {
      incomplete.year.weights <- incomplete.year.weights[-which(names(incomplete.year.weights) >= incomplete.year.threshold)]
    }
  } else
  {
    yearly.cost$Calibration <- "Included"
    yearly.cost.calibration <- yearly.cost
  }
  # For nicer graphs
  yearly.cost$Calibration <- factor(yearly.cost$Calibration, levels = c("Excluded",
                                                                        "Included"))
  
  model.RMSE <- array(NA, dim = c(7, 2),
                      dimnames = list(c("regression.linear",
                                        "regression.quadratic",
                                        "mars",
                                        "gam",
                                        "qt0.1",
                                        "qt0.5",
                                        "qt0.9"),
                                      c("RMSE.calibration", 
                                        "RMSE.alldata")))
  
  # Prediction years correspond to the entire range provided by the user
  prediction.years <- data.frame(Year = minimum.year:maximum.year)
  
  # Linear regression 
  reg.lm <- lm(transf.cost ~ Year, data = yearly.cost.calibration,
               weights = incomplete.year.weights)
  pred.lm <- predict(reg.lm, 
                     prediction.years,
                     interval = "confidence",
                     level = confidence.interval)
  rownames(pred.lm) <- prediction.years[, 1]
  
  model.RMSE["regression.linear", "RMSE.calibration"] <- sqrt(mean(residuals(reg.lm)^2))
  model.RMSE["regression.linear", "RMSE.alldata"] <- sqrt(
    mean((pred.lm[match(yearly.cost$Year, rownames(pred.lm)), "fit"] -
            yearly.cost$transf.cost)^2))
  
  
  reg.quad.lm <- lm(transf.cost ~ Year + I(Year^2), data = yearly.cost.calibration,
                    weights = incomplete.year.weights)
  pred.quad.lm <- predict(reg.quad.lm, 
                          prediction.years,
                          interval = "confidence",
                          level = confidence.interval)
  rownames(pred.quad.lm) <- prediction.years[, 1]
  
  model.RMSE["regression.quadratic", "RMSE.calibration"] <- sqrt(mean(residuals(reg.quad.lm)^2))
  model.RMSE["regression.quadratic", "RMSE.alldata"] <- sqrt(
    mean((pred.quad.lm[match(yearly.cost$Year, rownames(pred.quad.lm)), "fit"] -
            yearly.cost$transf.cost)^2))
  
  # Multiple Adapative Regression splines
  mars <- earth::earth(transf.cost ~ Year, data = yearly.cost.calibration,
                       varmod.method = "earth",
                       nk = mars.nk,
                       nfold = 5,
                       ncross = 3,
                       weights = incomplete.year.weights)
  pred.mars <- predict(mars,
                       prediction.years,
                       interval = "pint",
                       level = confidence.interval)
  rownames(pred.mars) <- prediction.years[, 1]
  
  model.RMSE["mars", "RMSE.calibration"] <- sqrt(mean(residuals(mars)^2))
  model.RMSE["mars", "RMSE.alldata"] <- sqrt(
    mean((pred.mars[match(yearly.cost$Year, rownames(pred.mars)), "fit"] -
            yearly.cost$transf.cost)^2))
  
  
  # Generalized Additive Models
  igam <- mgcv::gam(transf.cost ~ s(Year, k = gam.k), data = yearly.cost.calibration,
                    weights = incomplete.year.weights)
  pred.gam <- predict(igam,
                      newdata = prediction.years,
                      se.fit = TRUE)
  pred.gam <- data.frame(fit = pred.gam$fit,
                         lwr = pred.gam$fit -
                           pred.gam$se * qt(confidence.interval + 
                                              (1 - confidence.interval) / 2,
                                            df = nrow(yearly.cost) - 1),
                         upr = pred.gam$fit +
                           pred.gam$se * qt(confidence.interval + 
                                              (1 - confidence.interval) / 2,
                                            df = nrow(yearly.cost) - 1))
  rownames(pred.gam) <- prediction.years[, 1]
  
  model.RMSE["gam", "RMSE.calibration"] <- sqrt(mean(residuals(igam)^2))
  model.RMSE["gam", "RMSE.alldata"] <- sqrt(
    mean((pred.gam[match(yearly.cost$Year, rownames(pred.gam)), "fit"] -
            yearly.cost$transf.cost)^2))
  
  
  # Quantile regression
  qt0.1 <- quantreg::rq(transf.cost ~ Year, 
                        data = yearly.cost.calibration,
                        tau = 0.1,
                        weights = incomplete.year.weights)
  qt0.5 <- quantreg::rq(transf.cost ~ Year, 
                        data = yearly.cost.calibration,
                        tau = 0.5,
                        weights = incomplete.year.weights)
  qt0.9 <- quantreg::rq(transf.cost ~ Year, 
                        data = yearly.cost.calibration,
                        tau = 0.9,
                        weights = incomplete.year.weights)
  
  
  # quantreg sometimes throws errors in the prediction of confidence intervals
  # so we need to adatp the code
  
  pred.qt0.1 <- try(predict(qt0.1,
                            newdata = prediction.years,
                            interval = "confidence"),
                    silent = TRUE)
  if("try-error" %in% class(pred.qt0.1)) 
  {
    pred.qt0.1 <- data.frame(
      fit = predict(qt0.1,
                    newdata = prediction.years),
      lwr = NA, upr = NA)
  }
  pred.qt0.5 <- try(predict(qt0.5,
                            newdata = prediction.years,
                            interval = "confidence"),
                    silent = TRUE)
  if("try-error" %in% class(pred.qt0.5)) 
  {
    pred.qt0.5 <- data.frame(
      fit = predict(qt0.5,
                    newdata = prediction.years),
      lwr = NA, upr = NA)
  }
  pred.qt0.9 <- try(predict(qt0.9,
                            newdata = prediction.years,
                            interval = "confidence"),
                    silent = TRUE)
  if("try-error" %in% class(pred.qt0.9)) 
  {
    pred.qt0.9 <- data.frame(
      fit = predict(qt0.9,
                    newdata = prediction.years),
      lwr = NA, upr = NA)
  }
  colnames(pred.qt0.9) <- colnames(pred.qt0.5) <- colnames(pred.qt0.1) <- colnames(pred.lm)
  rownames(pred.qt0.9) <- rownames(pred.qt0.5) <- rownames(pred.qt0.1) <- prediction.years[, 1]
  model.RMSE["qt0.1", "RMSE.calibration"] <- sqrt(mean(residuals(qt0.1)^2))
  model.RMSE["qt0.1", "RMSE.alldata"] <- sqrt(
    mean((pred.qt0.1[match(yearly.cost$Year, rownames(pred.qt0.1)), "fit"] -
            yearly.cost$transf.cost)^2))
  model.RMSE["qt0.5", "RMSE.calibration"] <- sqrt(mean(residuals(qt0.5)^2))
  model.RMSE["qt0.5", "RMSE.alldata"] <- sqrt(
    mean((pred.qt0.5[match(yearly.cost$Year, rownames(pred.qt0.5)), "fit"] -
            yearly.cost$transf.cost)^2))
  model.RMSE["qt0.9", "RMSE.calibration"] <- sqrt(mean(residuals(qt0.9)^2))
  model.RMSE["qt0.9", "RMSE.alldata"] <- sqrt(
    mean((pred.qt0.9[match(yearly.cost$Year, rownames(pred.qt0.9)), "fit"] -
            yearly.cost$transf.cost)^2))
  
  
  
  model.preds <- rbind.data.frame(data.frame(model = "Linear regression",
                                             Year = prediction.years$Year,
                                             Details = "Linear",
                                             pred.lm),
                                  data.frame(model = "Linear regression",
                                             Year = prediction.years$Year,
                                             Details = "Quadratic",
                                             pred.quad.lm),
                                  data.frame(model = "MARS",
                                             Year = prediction.years$Year,
                                             Details = "",
                                             pred.mars),
                                  data.frame(model = "GAM",
                                             Year = prediction.years$Year,
                                             Details = "",
                                             pred.gam),
                                  data.frame(model = "Quantile regression",
                                             Year = prediction.years$Year,
                                             Details = "Quantile 0.1",
                                             pred.qt0.1),
                                  data.frame(model = "Quantile regression",
                                             Year = prediction.years$Year,
                                             Details = "Quantile 0.5",
                                             pred.qt0.5),
                                  data.frame(model = "Quantile regression",
                                             Year = prediction.years$Year,
                                             Details = "Quantile 0.9",
                                             pred.qt0.9))
  
  if(cost.transf == "log10")
  {
    # Transform log10 values back to actual US$
    model.preds[, c("fit", "lwr", "upr")] <- 
      apply(model.preds[, c("fit", "lwr", "upr")] ,
            2,
            function(x) 10^x)
    
    results <- list(cost.data = yearly.cost,
                    parameters = parameters, 
                    fitted.models = list(linear = reg.lm,
                                         quadratic = reg.quad.lm,
                                         mars = mars,
                                         gam = igam,
                                         quantile = list(qt0.1 = qt0.1,
                                                         qt0.5 = qt0.5,
                                                         qt0.9 = qt0.9)),
                    estimated.annual.costs = model.preds,
                    RMSE = model.RMSE,
                    final.year.cost = c(linear = 
                                          unname(10^predict(reg.lm,
                                                     newdata = data.frame(Year = final.year))),
                                        quadratic = 
                                          unname(10^predict(reg.quad.lm,
                                                            newdata = data.frame(Year = final.year))),
                                        mars = 
                                          unname(10^predict(mars,
                                                     newdata = data.frame(Year = final.year))),
                                        gam = 
                                          unname(10^predict(igam,
                                                     newdata = data.frame(Year = final.year))),
                                        quantile.0.1 = 
                                          unname(10^predict(qt0.1,
                                                     newdata = data.frame(Year = final.year))),
                                        quantile.0.5 = 
                                          unname(10^predict(qt0.5,
                                                     newdata = data.frame(Year = final.year))),
                                        quantile.0.9 = 
                                          unname(10^predict(qt0.9,
                                                     newdata = data.frame(Year = final.year)))))
  } else if(cost.transf == "none")
  {
    results <- list(cost.data = yearly.cost,
                    parameters = parameters, 
                    fitted.models = list(linear = reg.lm,
                                         quadratic = reg.quad.lm,
                                         mars = mars,
                                         gam = igam,
                                         quantile = list(qt0.1 = qt0.1,
                                                         qt0.5 = qt0.5,
                                                         qt0.9 = qt0.9)),
                    estimated.annual.costs = model.preds,
                    RMSE = model.RMSE,
                    final.year.cost = c(linear = 
                                          unname(predict(reg.lm,
                                                  newdata = data.frame(Year = final.year))),
                                        quadratic = 
                                          unname(predict(reg.quad.lm,
                                                         newdata = data.frame(Year = final.year))),
                                        mars = 
                                          unname(predict(mars,
                                                  newdata = data.frame(Year = final.year))),
                                        gam = 
                                          unname(predict(igam,
                                                  newdata = data.frame(Year = final.year))),
                                        quantile.0.1 = 
                                          unname(predict(qt0.1,
                                                  newdata = data.frame(Year = final.year))),
                                        quantile.0.5 = 
                                          unname(predict(qt0.5,
                                                  newdata = data.frame(Year = final.year))),
                                        quantile.0.9 = 
                                          unname(predict(qt0.9,
                                                  newdata = data.frame(Year = final.year)))))
  } else
  {
    results <- list(cost.data = yearly.cost,
                    parameters = parameters, 
                    fitted.models = list(linear = reg.lm,
                                         quadratic = reg.quad.lm,
                                         mars = mars,
                                         gam = igam,
                                         quantile = list(qt0.1 = qt0.1,
                                                         qt0.5 = qt0.5,
                                                         qt0.9 = qt0.9)),
                    RMSE = model.RMSE)
  }
  class(results) <- append("invacost.trendcost", class(results))
  return(results)
}
