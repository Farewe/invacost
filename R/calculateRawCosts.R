#' Calculate the raw average annual cost of invasions over periods of time
#' 
#' This function calculates the raw average annual cost of invasive species
#' over different periods of time
#' 
#' @param costdb The \bold{expanded INVACOST database} output from 
#' \code{\link{expandYearlyCosts}},
#' where annual costs occurring over several years are repeated for each year.
#' @param cost.column Name of the cost column to use in \code{costdb} (usually, 
#' choose between the exchange rate (default) or PPP annualised cost)
#' @param year.column Name of the year column to use in \code{costdb}.
#' @param in.millions If \code{TRUE}, cost values will be transformed in 
#' millions (to make graphs easier to read), else if \code{}, cost values will
#' not be transformed.
#' @param minimum.year the starting year of this analysis. By default, 
#' 1960 was chosen because it marks the period from which world bank data is 
#' available for exchange rates and inflation values.
#' @param maximum.year the ending year for this analysis. By default, 2017
#' was chosen as it is the last year for which we have data in INVACOST.
#' @param year.breaks a vector of breaks for the year intervals over which
#' you want to calculate raw cost values
#' @return a \code{list} with 5 elements:
#'
#' \itemize{
#' \item{\code{cost.data}: the annualised costs of invasions, as sums of all 
#' costs for each year.}
#' \item{\code{parameters}: parameters used to run the function. The 
#' \code{minimum.year} and \code{maximum.year} are based on the input data
#' (i.e., the user may specify \code{minimum.year = 1960} but the input data may
#' only have data starting from 1970, hence the \code{minimum.year} will be
#'  1970.)}
#' \item{\code{average.total.cost}: the average annual cost of IAS calculated
#' over the entire time period}
#' \item{\code{average.cost.per.period}: a data.frame containing the the average 
#' annual cost of IAS calculated over each time interval}
#' }
#' The structure of this object can be seen using \code{str()}
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
#' @details
#' Missing data for specific years will be considered as zero. 
#' For example, if there is only data for 1968 for the 1960-1969 interval,
#' then the total cost for the interval will be equal to the cost of 1968, and the
#' average annual cost for 1960-1969 will be cost of 1968 / 10.
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
#' res <- calculateRawAvgCosts(costdb)
#' res

calculateRawAvgCosts <- function(
  costdb,
  cost.column = "Cost_estimate_per_year_2017_USD_exchange_rate",
  year.column = "Impact_year",
  in.millions = TRUE,
  minimum.year = 1960,
  maximum.year = 2017,
  year.breaks = seq(minimum.year, maximum.year, by = 10)
)
{
  if(any(costdb[, year.column] < minimum.year))
  {
    warning(paste0("There are ",  length(unique(costdb$Cost_ID[which(costdb[, year.column] < minimum.year)])),
                   " cost values for periods earlier than ",
                   minimum.year, ", which will be removed.\n"))
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
  
  parameters <- list(cost.column = cost.column,
                     year.column = year.column,
                     in.millions = in.millions,
                     minimum.year = minimum.year, 
                     maximum.year = maximum.year)
  
  if(in.millions)
  {
    costdb[, cost.column] <- costdb[, cost.column] / 1e6
  }
  
  
  if(!(maximum.year %in% year.breaks))
  {
    year.breaks <- c(year.breaks,
                     maximum.year)
  }
  
  # Average cost of the entire period of time
  total.cost <-  as.data.frame(rawAvgCost(costdb,
                                          cost.column,
                                          year.column))
  
  # Average cost over each interval
  period.costs <- data.frame()
  for (per in 1:(length(year.breaks) - 1))
  {
    period <- c(year.breaks[per:(per + 1)])
    # Always include the last year in the last period
    if(per == (length(year.breaks) - 1))
    {
      period[2] <- period[2] + 1
    }
    cur.db <- costdb[which(costdb$Impact_year >= period[1] &
                             costdb$Impact_year < period[2]), ]
    if(nrow(cur.db))
    {
      period.costs <- rbind.data.frame(period.costs,
                                       as.data.frame(rawAvgCost(cur.db,
                                                                cost.column,
                                                                year.column,
                                                                min.year = period[1],
                                                                max.year = period[2] - 1)))
    }
    
  }

  results <- list(cost.data = costdb,
                  parameters = parameters, 
                  year.breaks = year.breaks,
                  average.total.cost = total.cost,
                  average.cost.per.period = period.costs)
  
  class(results) <- append("invacost.rawcost", class(results))
  return(results)

}



#' Calculate the raw average annual cost over a single period of time
#' 
#' This simple function calculates the raw average annual cost of invasive species
#' over a single period of time
#' 
#' @param costdb The \bold{expanded INVACOST database} output from 
#' \code{\link{expandYearlyCosts}},
#' where annual costs occurring over several years are repeated for each year.
#' @param cost.column Name of the cost column to use in \code{costdb} (usually, 
#' choose between the exchange rate (default) or PPP annualised cost)
#' @param year.column Name of the year column to use in \code{costdb}.
#' @param min.year The minimum year of the period (specify only if different from
#' the range of data)
#' @param max.year The minimum year of the period (specify only if different from
#' the range of data)
#' @return a named \code{list} with 5 elements
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
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
#' res <- rawAvgCost(costdb)
#' res
rawAvgCost <- function(
  costdb,
  cost.column = "Cost_estimate_per_year_2017_USD_exchange_rate",
  year.column = "Impact_year",
  min.year = NULL,
  max.year = NULL
)
{
  initial_year <- ifelse(!is.null(min.year),
                        min.year,
                        min(costdb[, year.column]))
  final_year <- ifelse(!is.null(max.year),
                      max.year,
                      max(costdb[, year.column]))
  return(list(initial_year = initial_year,
              final_year = final_year,
              time_span = length(initial_year:final_year),
              total_cost = sum(costdb[, cost.column]),
              annual_cost = sum(costdb[, cost.column]) /
                length(initial_year:final_year)))
}

    