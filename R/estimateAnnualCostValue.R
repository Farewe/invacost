#' Estimate the average annual cost value of invasions 
#' 
#' This function fits different models on annualised INVACOST data in order to
#' estimate the average annual cost of invasive species.
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
#' @param confidence.intervals a numeric value between 0 and 1, corresponding
#' to the desired confidence intervals around model predictions.
#' @param plot.breaks a vector of numeric values indicating the plot breaks 
#' for the axis of annual cost values. 
#' @param minimum.year the starting year of this analysis. By default, 
#' 1960 was chosen because it marks the period from which world bank data is 
#' available for exchange rates and inflation values.
#' @param maximum.year the ending year for this analysis. By default, 2017
#' was chosen as it is the last year for which we have data in INVACOST.
#' @param final.year.cost the year for which you want to obtain the final 
#' average cost estimate from models. Default is 2017.
#' @param incomplete.year.threshold Estimated threshold for incomplete cost 
#' data. All years above or equal to this threshold will be excluded from 
#' model calibration, because of the time-lag between economic impacts of
#' invasive species and the documentation and publication of these impacts.
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
#' \item{\code{estimated.annual.costs}}: a data.frame containing the predicted 
#' cost values for each year for all the fitted models.
#' \item{\code{plot}}: the ggplot object of the output plot.
#' \item{\code{final.year.cost}}: a vector containing the estimated annual
#' costs of invasive species based on all models for \code{final.year}.
#' }
#' The structure of this object can be seen using \code{str()}
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
#' @details
#' 
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}
#' 
#' with help from C. Diagne & A.-C. Vaissière
#' @examples
#' # Create an example stack with two environmental variables
#' data(invacost)
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable.Starting.year.Low.margin",
#'                                   endcolumn = "Probable.Ending.year.Low.margin")
#' costdb <- db.over.time[db.over.time$Implementation == "Observed", ]
#' costdb <- costdb[which(costdb$Method.reliability == "High"), ]
#' costdb <- costdb[-which(costdb$Reference.ID == 8733), ]
#' res <- estimateAnnualCosts(costdb)

estimateAnnualCosts <- function(costdb,
                                cost.column = "Annualised.cost.estimate..2017.USD.exchange.rate.",
                                year.column = "Applicable.year",
                                cost.transf = "log10",
                                in.millions = TRUE,
                                confidence.interval = 0.95,
                                plotbreaks = c(0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000,
                                               100000000, 1000000000, 10000000000, 100000000000, 1000000000000),
                                minimum.year = 1960, 
                                maximum.year = 2017, 
                                final.year = 2017, 
                                incomplete.year.threshold = 2010
)
{
  if(any(costdb[, year.column] < minimum.year))
  {
    warning(paste0("There are cost values for periods earlier than ",
                   minimum.year, ": ",
                   length(unique(costdb$Cost.ID[which(costdb[, year.column] < minimum.year)])),
                   " different cost estimate(s).\nTheir values earlier than ",
                   minimum.year,
                   " will be removed.\n"))
    costdb <- costdb[-which(costdb[, year.column] < minimum.year), ]
  }
  
  if(any(costdb[, year.column] > maximum.year))
  {
    warning(paste0("There are cost values for periods later than ",
                   maximum.year, ": ",
                   length(unique(costdb$Cost.ID[which(costdb[, year.column] > maximum.year)])),
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
  
  if(in.millions)
  {
    yearly.cost$Annual.cost <- yearly.cost$Annual.cost / 1e6
  }
  
  
  
  if(!is.null(cost.transf) | !is.na(cost.transf))
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
    yearly.cost$Completeness <- ifelse(yearly.cost$Year < incomplete.year.threshold,
                                       "Adequate", "Inadequate")
    yearly.cost.calibration <- yearly.cost[-which(yearly.cost[, "Year"] >= incomplete.year.threshold), ]
  }
  
  
  # Linear regression 
  reg.lm <- lm(transf.cost ~ Year, data = yearly.cost.calibration)
  pred.lm <- predict(reg.lm, 
                     yearly.cost["Year"],
                     interval = "confidence",
                     level = confidence.interval)
  
  # Multiple Adapative Regression splines
  mars <- earth::earth(transf.cost ~ Year, data = yearly.cost.calibration,
                       varmod.method = "earth",
                       nfold = 5,
                       ncross = 3)
  pred.mars <- predict(mars,
                       yearly.cost$Year,
                       interval = "pint",
                       level = confidence.interval)
  
  # Generalized Additive Models
  igam <- mgcv::gam(transf.cost ~ s(Year), data = yearly.cost.calibration)
  pred.gam <- predict(igam,
                      newdata = data.frame(Year = yearly.cost$Year),
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
  
  # Quantile regression
  qt0.1 <- quantreg::rq(transf.cost ~ Year, 
                        data = yearly.cost.calibration,
                        tau = 0.1)
  qt0.5 <- quantreg::rq(transf.cost ~ Year, 
                        data = yearly.cost.calibration,
                        tau = 0.5)
  qt0.9 <- quantreg::rq(transf.cost ~ Year, 
                        data = yearly.cost.calibration,
                        tau = 0.9)
  
  
  # quantreg sometimes throws errors in the prediction of confidence intervals
  # so we need to adatp the code
  
  pred.qt0.1 <- try(predict(qt0.1,
                            newdata = data.frame(Year = yearly.cost$Year),
                            interval = "confidence"),
                    silent = TRUE)
  if("try-error" %in% class(pred.qt0.1)) 
  {
    pred.qt0.1 <- data.frame(
      fit = predict(qt0.1,
                    newdata = data.frame(Year = yearly.cost$Year)),
      lwr = NA, upr = NA)
  }
  pred.qt0.5 <- try(predict(qt0.5,
                            newdata = data.frame(Year = yearly.cost$Year),
                            interval = "confidence"),
                    silent = TRUE)
  if("try-error" %in% class(pred.qt0.5)) 
  {
    pred.qt0.5 <- data.frame(
      fit = predict(qt0.5,
                    newdata = data.frame(Year = yearly.cost$Year)),
      lwr = NA, upr = NA)
  }
  pred.qt0.9 <- try(predict(qt0.9,
                            newdata = data.frame(Year = yearly.cost$Year),
                            interval = "confidence"),
                    silent = TRUE)
  if("try-error" %in% class(pred.qt0.9)) 
  {
    pred.qt0.9 <- data.frame(
      fit = predict(qt0.9,
                    newdata = data.frame(Year = yearly.cost$Year)),
      lwr = NA, upr = NA)
  }
  colnames(pred.qt0.9) <- colnames(pred.qt0.5) <- colnames(pred.qt0.1) <- colnames(pred.lm)
  
  model.preds <- rbind.data.frame(data.frame(model = "Linear regression",
                                             Year = yearly.cost$Year,
                                             Quantile = 0,
                                             pred.lm),
                                  data.frame(model = "MARS",
                                             Year = yearly.cost$Year,
                                             Quantile = 0,
                                             pred.mars),
                                  data.frame(model = "GAM",
                                             Year = yearly.cost$Year,
                                             Quantile = 0,
                                             pred.gam),
                                  data.frame(model = "Quantile regression",
                                             Year = yearly.cost$Year,
                                             Quantile = 0.1,
                                             pred.qt0.1),
                                  data.frame(model = "Quantile regression",
                                             Year = yearly.cost$Year,
                                             Quantile = 0.5,
                                             pred.qt0.5),
                                  data.frame(model = "Quantile regression",
                                             Year = yearly.cost$Year,
                                             Quantile = 0.9,
                                             pred.qt0.9))
  
  model.preds$Quantile <- as.factor(model.preds$Quantile)
  levels(model.preds$Quantile)[1] <- "Not quantile reg."
  
  if(cost.transf == "log10")
  {
    # Transform log10 values back to actual US$
    model.preds[, c("fit", "lwr", "upr")] <- 
      apply(model.preds[, c("fit", "lwr", "upr")] ,
            2,
            function(x) 10^x)
    
    p <- ggplot() +
      geom_point(data = yearly.cost, 
                 aes(x = Year,
                     y = Annual.cost,
                     col = Completeness)) +
      ylab(paste0("Annual cost in US$ ", 
                  ifelse(in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      geom_line(data = model.preds, 
                aes(x = Year,
                    y = fit,
                    linetype = Quantile)) +
      geom_ribbon(data = model.preds, 
                  aes(x = Year,
                      ymin = lwr,
                      ymax = upr,
                      group = Quantile),
                  alpha = .1) +
      scale_y_log10(breaks = plotbreaks,
                    labels = scales::comma) +
      theme_bw() +
      annotation_logticks() + 
      facet_wrap (~ model)
    print(p)
    
    results <- list(cost.data = yearly.cost,
                    parameters = parameters, 
                    fitted.models = list(linear = reg.lm,
                                         mars = mars,
                                         gam = igam,
                                         quantile = list(qt0.1 = qt0.1,
                                                         qt0.5 = qt0.5,
                                                         qt0.9 = qt0.9)),
                    estimated.annual.costs = model.preds,
                    plot = p,
                    final.year.cost = c(linear = 
                                          10^predict(reg.lm,
                                                     newdata = data.frame(Year = final.year)),
                                        mars = 
                                          10^predict(mars,
                                                     newdata = data.frame(Year = final.year)),
                                        gam = 
                                          10^predict(igam,
                                                     newdata = data.frame(Year = final.year)),
                                        quantile.0.1 = 
                                          10^predict(qt0.1,
                                                     newdata = data.frame(Year = final.year)),
                                        quantile.0.5 = 
                                          10^predict(qt0.5,
                                                     newdata = data.frame(Year = final.year)),
                                        quantile.0.9 = 
                                          10^predict(qt0.9,
                                                     newdata = data.frame(Year = final.year))))
  } else if(is.null(cost.transf) | is.na(cost.transf))
  {
    p <- ggplot() +
      geom_point(data = yearly.cost, 
                 aes(x = Year,
                     y = Annual.cost)) +
      ylab(paste0("Annual cost in US$ ", 
                  ifelse(in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      geom_line(data = model.preds, 
                aes(x = Year,
                    y = fit,
                    linetype = Quantile)) +
      geom_ribbon(data = model.preds, 
                  aes(x = Year,
                      ymin = lwr,
                      ymax = upr,
                      group = Quantile),
                  alpha = .1) +
      theme_bw() +
      annotation_logticks() + 
      facet_wrap (~ model)
    print(p)
    results <- list(cost.data = yearly.cost,
                    parameters = parameters, 
                    fitted.models = list(linear = reg.lm,
                                         mars = mars,
                                         gam = igam,
                                         quantile = list(qt0.1 = qt0.1,
                                                         qt0.5 = qt0.5,
                                                         qt0.9 = qt0.9)),
                    estimated.annual.costs = model.preds,
                    plot = p,
                    final.year.cost = c(linear = 
                                          predict(reg.lm,
                                                  newdata = data.frame(Year = final.year)),
                                        mars = 
                                          predict(mars,
                                                  newdata = data.frame(Year = final.year)),
                                        gam = 
                                          predict(igam,
                                                  newdata = data.frame(Year = final.year)),
                                        quantile.0.1 = 
                                          predict(qt0.1,
                                                  newdata = data.frame(Year = final.year)),
                                        quantile.0.5 = 
                                          predict(qt0.5,
                                                  newdata = data.frame(Year = final.year)),
                                        quantile.0.9 = 
                                          predict(qt0.9,
                                                  newdata = data.frame(Year = final.year))))
  } else
  {
    message("The cost transformation was not in log10, so you will have 
    to transforme the predicted costs in dollars by yourself, and make graphs of
    your own. The output object will only contains the fitted models.")
    results <- list(cost.data = yearly.cost,
                    parameters = parameters, 
                    fitted.models = list(linear = reg.lm,
                                         mars = mars,
                                         gam = igam,
                                         quantile = list(qt0.1 = qt0.1,
                                                         qt0.5 = qt0.5,
                                                         qt0.9 = qt0.9)))
  }
  results$parameters <- list()
  class(results) <- append("invacost.annual.est", class(results))
  return(results)
}
