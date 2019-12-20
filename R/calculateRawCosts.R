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
#' @param cost.transf Type of transformation you want to apply on cost values.
#' Specify \code{NA} or \code{NULL} to avoid any transformation. Only useful
#' for graphical representation.
#' @param minimum.year the starting year of this analysis. By default, 
#' 1960 was chosen because it marks the period from which world bank data is 
#' available for exchange rates and inflation values.
#' @param maximum.year the ending year for this analysis. By default, 2017
#' was chosen as it is the last year for which we have data in INVACOST.
#' @param year.breaks a vector of breaks for the year intervals over which
#' you want to calculate raw cost values
#' @param plot.breaks a vector of numeric values indicating the plot breaks 
#' for the axis of average annual cost values. 
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
#' \item{\code{plot}}: the ggplot object of the output plot.
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
  cost.transf = "log10",
  minimum.year = 1960,
  maximum.year = 2017,
  year.breaks = seq(minimum.year, maximum.year, by = 10),
  plot.breaks = c(0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000,
                 100000000, 1000000000, 10000000000, 100000000000, 1000000000000)
)
{
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
  
  parameters <- list(cost.transformation = cost.transf,
                     in.millions = in.millions,
                     minimum.year = min(costdb[, year.column], na.rm = TRUE), 
                     maximum.year = max(costdb[, year.column], na.rm = TRUE))
  
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
    period.costs <- rbind.data.frame(period.costs,
                                     as.data.frame(rawAvgCost(cur.db,
                                                              cost.column,
                                                              year.column)))
  }
  
  ggperiods <- period.costs
  ggperiods$middle.years <- 
    ggperiods$initial_year + (ggperiods$final_year - ggperiods$initial_year) / 2 
  
  ggtext <- data.frame(x = minimum.year,
                       y = total.cost$annual_cost,
                       text = paste0("Average over entire period\n",
                                     scales::comma(total.cost$annual_cost)))
  
  if(cost.transf == "log10")
  {
    p <- ggplot(ggperiods) +
      geom_line(aes(x = middle.years,
                    y = annual_cost)) +
      geom_point(aes(x = middle.years,
                     y = annual_cost)) +
      geom_segment(aes(x = initial_year,
                       xend = final_year,
                       y = annual_cost,
                       yend = annual_cost)) +
      geom_text(data = ggtext,
                hjust = 0,
                aes(x = x, y = y, label = text)) +
      geom_hline(data = total.cost,
                 aes(yintercept = annual_cost),
                 linetype = 3) +
      ylab(paste0("Average annual cost in US$ ", 
                  ifelse(in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      scale_x_continuous(breaks = year.breaks) +
      scale_y_log10(breaks = plot.breaks,
                    labels = scales::comma) +
      annotation_logticks() +
      theme_bw() 
  } else
  {
    p <- ggplot(ggperiods) +
      geom_line(aes(x = middle.years,
                    y = annual_cost)) +
      geom_point(aes(x = middle.years,
                     y = annual_cost)) +
      geom_segment(aes(x = initial_year,
                       xend = final_year,
                       y = annual_cost,
                       yend = annual_cost)) +
      geom_text(data = ggtext,
                hjust = 0,
                aes(x = x, y = y, label = text))  +
      geom_hline(data = total.cost,
                 aes(yintercept = annual_cost),
                 linetype = 3) +
      ylab(paste0("Average annual cost in US$ ", 
                  ifelse(in.millions, 
                         "millions",
                         ""))) +
      xlab("Year") +
      scale_x_continuous(breaks = year.breaks) +
      theme_bw() 
  }
   
  print(p)

  results <- list(cost.data = costdb,
                  parameters = parameters, 
                  average.total.cost = total.cost,
                  average.cost.per.period = period.costs,
                  plot = p)
  
  class(results) <- append("invacost.costs.per.period", class(results))
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
#' @return a named \code{list} with 5 elements
#' @seealso \code{\link{expandYearlyCosts}} to get the database in appropriate format.
#' @details
#' 
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
  year.column = "Impact_year"
)
{
  return(list(initial_year = min(costdb[, year.column]),
              final_year = max(costdb[, year.column]),
              time_span = length(min(costdb[, year.column]):
                                   max(costdb[, year.column])),
              total_cost = sum(costdb[, cost.column]),
              annual_cost = sum(costdb[, cost.column]) /
                length(min(costdb[, year.column]):
                         max(costdb[, year.column]))))
}

    