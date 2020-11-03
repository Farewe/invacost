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
#' @param year.column Name of the year column to use in \code{costdb}( usually, 
#' "Impact_year" from \code{\link{expandYearlyCosts}} 
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
#' @param include.last.year \code{TRUE} or \code{FALSE}. Defines if the last
#' year of the dataset is included in the last interval (\code{TRUE}) or is
#' considered as an interval of its own (\code{FALSE}). Generally only useful
#' if the last year is at the limit of an interval.
#' @return a \code{list} with 6 elements:
#'
#' \itemize{
#' \item{\code{cost.data}: the input data.}
#' \item{\code{parameters}: parameters used to run the function. The 
#' \code{minimum.year} and \code{maximum.year} are based on the input data
#' (i.e., the user may specify \code{minimum.year = 1960} but the input data may
#' only have data starting from 1970, hence the \code{minimum.year} will be
#'  1970.)}
#' \item{\code{year.breaks}: the years used to define year intervals over which costs were calculated.}
#' \item{\code{cost.per.year}: the annualised costs of invasions, as sums of all 
#' costs for each year.}
#' \item{\code{average.total.cost}: the average annual cost of IAS calculated
#' over the entire time period}
#' \item{\code{average.cost.per.period}: a data.frame containing the the average 
#' annual cost of IAS calculated over each time interval}
#' }
#' The structure of this object can be seen using \code{str()}
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
#' @details
#' Missing data will be ignored. However, note that the average for each 
#' interval will always be calculated on the basis of the full temporal range.
#' For example, if there is only data for 1968 for the 1960-1969 interval,
#' then the total cost for the interval will be equal to the cost of 1968, and the
#' average annual cost for 1960-1969 will be cost of 1968 / 10.
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}, Andrew Kramer, Anne-Charlotte
#' Vaissière, Christophe Diagne
#' 
#' @examples
#' data(invacost)
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_low_margin",
#'                                   endcolumn = "Probable_ending_year_low_margin")
#' costdb <- db.over.time[db.over.time$Implementation == "Observed", ]
#' costdb <- costdb[which(costdb$Method_reliability == "High"), ]
#' costdb <- costdb[-which(is.na(costdb$Cost_estimate_per_year_2017_USD_exchange_rate)), ]
#' res <- calculateRawAvgCosts(costdb)
#' res

calculateRawAvgCosts <- function(
  costdb,
  cost.column = "Cost_estimate_per_year_2017_USD_exchange_rate",
  year.column = "Impact_year",
  in.millions = TRUE,
  minimum.year = 1960,
  maximum.year = 2017,
  year.breaks = seq(minimum.year, maximum.year, by = 10),
  include.last.year = TRUE
)
{
  if(any(is.na(costdb[, cost.column])))
  {
    costdb <- costdb[-which(is.na(costdb[, cost.column])), ]
    warning("There were NA values in the cost column, they have been removed.\n")
  } 
  
  
  if(any(costdb[, year.column] < minimum.year))
  {
    warning(paste0("There are ",  length(unique(costdb$Cost_ID[which(costdb[, year.column] < minimum.year)])),
                   " cost values for periods earlier than ",
                   minimum.year, ", which will be removed.\n"))
    costdb <- costdb[-which(costdb[, year.column] < minimum.year), ]
  }
  
  if(any(costdb[, year.column] > maximum.year))
  {
    warning(paste0("There are ", length(unique(costdb$Cost_ID[which(costdb[, year.column] > maximum.year)])),
                   " cost values for periods later than ",
                   maximum.year,
                   " which will be removed.\n"))
    costdb <- costdb[-which(costdb[, year.column] > maximum.year), ]
  }
  
  parameters <- list(cost.column = cost.column,
                     year.column = year.column,
                     in.millions = in.millions,
                     minimum.year = minimum.year, 
                     maximum.year = maximum.year,
                     number.of.estimates = length(unique(costdb$Cost_ID)),
                     number.of.year.values = nrow(costdb))
  
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
                                          year.column,
                                          min.year = minimum.year,
                                          max.year = maximum.year))
  
  # Average cost for each year
  cost.per.year <- data.frame()
  for (year in minimum.year:maximum.year)
  {
    
    cur.db <- costdb[which(costdb$Impact_year == year), ]
    
    if(nrow(cur.db))
    {
      cost.per.year <- rbind(cost.per.year,
                             as.data.frame(rawAvgCost(cur.db,
                                                      cost.column,
                                                      year.column)))
    } else
    {
      cost.per.year <- rbind.data.frame(cost.per.year,
                                        list(initial_year = year, 
                                             final_year = year, 
                                             time_span = 1,
                                             total_cost = NA,
                                             annual_cost = NA,
                                             number_estimates = 0,
                                             number_year_values = 0))
    }
    
  }
  # In case requested periods are 1-year intervals
  tmp <- cost.per.year
  cost.per.year <- cost.per.year[, -which(colnames(cost.per.year) %in%
                                          c("final_year", 
                                            "time_span",
                                            "annual_cost",
                                            "number_year_values"))]
  colnames(cost.per.year)[colnames(cost.per.year) == "initial_year"] <- "year"
  colnames(cost.per.year)[colnames(cost.per.year) == "total_cost"] <- "cost"
  
  
  
  # Average cost over each interval
  if(all(diff(year.breaks) == 1))
  {
    period.costs <- tmp
  } else
  {
    period.costs <- data.frame()
    if(include.last.year)
    {
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
        } else
        {
          period.costs <- rbind.data.frame(period.costs,
                                           list(initial_year = period[1], 
                                                final_year = period[2] - 1, 
                                                time_span = length(period[1]:(period[2] - 1)),
                                                total_cost = NA,
                                                annual_cost = NA,
                                                number_estimates = 0,
                                                number_year_values = 0))
        }
      }
    } else
    {
      for (per in 1:length(year.breaks))
      {
        
        if(per != length(year.breaks))
        { # When we are NOT at the last year: proceed as usual
          period <- c(year.breaks[per:(per + 1)])
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
          } else
          {
            period.costs <- rbind.data.frame(period.costs,
                                             list(initial_year = period[1], 
                                                  final_year = period[2] - 1, 
                                                  time_span = length(period[1]:(period[2] - 1)),
                                                  total_cost = NA,
                                                  annual_cost = NA,
                                                  number_estimates = 0,
                                                  number_year_values = 0))
          }
        } else
        { # When we ARE at the last year: there is only one year so proceed differently
          period <- c(year.breaks[c(per, per)])
          cur.db <- costdb[which(costdb$Impact_year == period[1]), ]
          if(nrow(cur.db))
          {
            period.costs <- rbind.data.frame(period.costs,
                                             as.data.frame(rawAvgCost(cur.db,
                                                                      cost.column,
                                                                      year.column,
                                                                      min.year = period[1],
                                                                      max.year = period[2])))
          } else
          {
            period.costs <- rbind.data.frame(period.costs,
                                             list(initial_year = period[1], 
                                                  final_year = period[2], 
                                                  time_span = length(period[1]:period[2]),
                                                  total_cost = NA,
                                                  annual_cost = NA,
                                                  number_estimates = 0,
                                                  number_year_values = 0))
          }
        }
      }
    }
  }

  results <- list(cost.data = costdb,
                  parameters = parameters, 
                  year.breaks = year.breaks,
                  cost.per.year = cost.per.year,
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
#' \itemize{
#'  \item{\code{initial_year}: first year in the data}
#'  \item{\code{final_year}: last year in the data}
#'  \item{\code{time_span}: the difference between initial and final years.}
#'  \item{\code{total_cost}: total cost.}
#'  \item{\code{annual.cost}: cost per year}
#'  \item{\code{number_estimates}: the number of cost estimates before expansion 
#' via \code{\link{expandYearlyCosts}}
#'  \item{\code{number_year_values}: the number of yearly costs included}
#' }}
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
#' @export
#' @note
#' Arguments \code{min.year} and \code{max.year} do not filter the data. Only 
#' specify them if you wish to change the interval over which averages are 
#' calculated. For example, if your data have values from 1960 to 1964 but you
#' want to calculated the average value from 1960 to 1969, set 
#' \code{min.year = 1960} and \code{max.year = 1969}.
#' 
#' However, if you want to calculate values for an interval narrower than your
#' data, filter the data BEFORE running this function.
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
                length(initial_year:final_year),
              number_estimates = length(unique(costdb$Cost_ID)),
              number_year_values = nrow(costdb)))
}

    