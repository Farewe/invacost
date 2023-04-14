#' Provide a pretty summary of model results
#' 
#' This function is useful for presenting the main results (coefficients, tests,
#' etc.) of models in a paper
#' 
#' @param x output object from \code{\link{modelCosts}}
#' @export
#' @references \url{https://github.com/Farewe/invacost}
#' 
#' Leroy Boris, Kramer Andrew M, Vaissière Anne-Charlotte, Kourantidou Melina,
#' Courchamp Franck & Diagne Christophe (2022). Analysing economic costs 
#' of invasive alien species with the invacost R package. Methods in Ecology
#' and Evolution. \doi{10.1111/2041-210X.13929}
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}, Andrew Kramer, Anne-Charlotte
#' Vaissière, Christophe Diagne
#' @examples
#' data(invacost)
#' 
#' ### Cleaning steps
#' # Eliminating data with no information on starting and ending years
#' invacost <- invacost[-which(is.na(invacost$Probable_starting_year_adjusted)), ]
#' invacost <- invacost[-which(is.na(invacost$Probable_ending_year_adjusted)), ]
#' # Keeping only observed and reliable costs
#' invacost <- invacost[invacost$Implementation == "Observed", ]
#' invacost <- invacost[which(invacost$Method_reliability == "High"), ]
#' # Eliminating data with no usable cost value
#' invacost <- invacost[-which(is.na(invacost$Cost_estimate_per_year_2017_USD_exchange_rate)), ]
#' 
#' ### Expansion
#' \donttest{
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_adjusted",
#'                                   endcolumn = "Probable_ending_year_adjusted")
#'                                   
#' ### Analysis                                   
#' res <- modelCosts(db.over.time)
#' prettySummary(res)}

prettySummary <- function(x)
{
  if(!inherits(x, "invacost.costmodel"))
  {
    stop("This function was designed to work with an object of class invacost.costmodel (output of modelCosts()")
  }
  # Pretty summaries (to make it easier to present results in papers) -------
  
  summary.models <- 
    
    as.array(rbind(
      
      c("Ordinary Least Square regression - Linear", rep("", 5)),
      
      cbind(rbind(c("", "Estimate", "Standard error", "t value", "p-value"),
                  c("Intercept", x$model.summary$ols.linear$coeftest[1, ]),
                  c("Year", x$model.summary$ols.linear$coeftest[2, ]),
                  "",
                  c("", "Adjusted R\u00B2", "R\u00B2", "", ""),
                  c("", x$model.summary$ols.linear$adjusted.r.squared,
                    x$model.summary$ols.linear$r.squared, "", "")), ""),
      rep("_________________", 6),
      
      c("Ordinary Least Square regression - Quadratic", rep("", 5)),
      
      cbind(rbind(c("", "Estimate", "Standard error", "t value", "p-value"),
                  c("Intercept", x$model.summary$ols.quadratic$coeftest[1, ]),
                  c("Year", x$model.summary$ols.quadratic$coeftest[2, ]),
                  "",
                  c("", "Adjusted R\u00B2", "R\u00B2", "", ""),
                  c("", x$model.summary$ols.quadratic$adjusted.r.squared,
                    x$model.summary$ols.quadratic$r.squared, "", "")), ""),
      rep("_________________", 6),
      
      # Robust 
      c("Robust regression - Linear", rep("", 5)),
      rbind(c("", "Estimate", "Standard error", "t value", "p-value", ""),
            c("Intercept", x$model.summary$robust.linear$coefficients[1, ], ""),
            c("Year", x$model.summary$robust.linear$coefficients[2, ], ""),
            "",
            c("", "Adjusted R\u00B2", "R\u00B2", "", "", ""),
            c("", x$model.summary$robust.linear$adj.r.squared,
              x$model.summary$robust.linear$r.squared, "", "", ""),
            "",
            c("Summary of model weights", rep("", 5)),
            c("", "Min", "25%", "50%", "75%", "Max"),
            c("", stats::quantile(x$model.summary$robust.linear$rweights)),
            c("", "Number of outliers", rep("", 4)),
            c("", length(which(x$model.summary$robust.linear$rweights == 0)),
              rep("", 4))),
      rep("_________________", 6),
      
      c("Robust regression - Quadratic", rep("", 5)),
      
      rbind(c("", "Estimate", "Standard error", "t value", "p-value", ""),
            c("Intercept", x$model.summary$robust.quadratic$coefficients[1, ], ""),
            c("Year", x$model.summary$robust.quadratic$coefficients[2, ], ""),
            "",
            c("", "Adjusted R\u00B2", "R\u00B2", "", "", ""),
            c("", x$model.summary$robust.quadratic$adj.r.squared,
              x$model.summary$robust.quadratic$r.squared, "", "", ""),
            "",
            c("Summary of model weights", rep("", 5)),
            c("", "Min", "25%", "50%", "75%", "Max"),
            c("", stats::quantile(x$model.summary$robust.quadratic$rweights)),
            c("", "Number of outliers", rep("", 4)),
            c("", length(which(x$model.summary$robust.quadratic$rweights == 0)),
              rep("", 4))),
      rep("_________________", 6),
      
      # MARS
      
      c("Multivariate Adaptive Regression Splines", rep("", 5)),
      rbind(cbind("", 
                  c("", rownames(x$model.summary$mars$coefficients)),
                  c("log10(cost)", x$model.summary$mars$coefficients[, 1]),
                  "", "", ""),
            "",
            c("", "Generalized R\u00B2", "R\u00B2", "Generalized Cross-Validation", "Root Sum of Squares", ""),
            c("", x$model.summary$mars$grsq, x$model.summary$mars$rsq,
              x$model.summary$mars$gcv, x$model.summary$mars$rss, ""), 
            "",
            c("Variance model", rep("", 5)),
            c("", "Estimate", "Standard error (last iteration)", "Standard error/coefficient %", "", ""),
            c("Intercept", summary(x$model.summary$mars$varmod)$coef.tab[1, ], "", ""),
            c("Intercept", summary(x$model.summary$mars$varmod)$coef.tab[2, ], "", ""),
            "",
            c("", "R\u00B2 for last iteration", rep("", 4)),
            c("", x$model.summary$mars$varmod$iter.rsq, rep("", 4))),
      rep("_________________", 6),
      
      
      # GAM
      
      c("Generalized Additive Models", rep("", 5)),
      rbind(c("Parametric coefficients", rep("", 5)),
            c("", "Estimate", "Standard error", "z value", "p-value", ""),
            c("Intercept (mean)", x$model.summary$gam$p.table[1, ], ""),
            c("Intercept (sd)", x$model.summary$gam$p.table[2, ], ""),
            "",
            c("Smooth terms", rep("", 5)),
            c("", "Estimated degree of freedom", "Residual degree of freedom", "Chi\u00B2", "p-value", ""),
            c("smooth (mean)", x$model.summary$gam$s.table[1, ], ""),
            c("smooth (sd)", x$model.summary$gam$s.table[2, ], ""),
            "",
            c("", "Explained deviance (%)", rep("", 4)),
            c("", x$model.summary$gam$dev.expl * 100, rep("", 4))
      ),
      rep("_________________", 6),
      
      # Quantile regression
      
      c("Quantile regression", rep("", 5)),
      rbind(c("", "Coefficients quantile 0.1", "Coefficients quantile 0.5", "Coefficients quantile 0.9", "", ""),
            c("Intercept", x$model.summary$qt0.1$coefficients[1, 1], 
              x$model.summary$qt0.5$coefficients[1, 1], 
              x$model.summary$qt0.9$coefficients[1, 1], "", ""),
            c("Year", x$model.summary$qt0.1$coefficients[2, 1], 
              x$model.summary$qt0.5$coefficients[2, 1], 
              x$model.summary$qt0.9$coefficients[2, 1], "", "")),
      rep("_________________", 6)))
  
  summary.models <- apply(summary.models, 2, unlist)
  summary.models <- as.data.frame(summary.models)
  rownames(summary.models) <- 1:nrow(summary.models)
  colnames(summary.models) <- 1:ncol(summary.models)
  return(summary.models)
}