#' Expand annual cost values of the database over periods
#' 
#' For costs that occur over several years, this function will repeat the 
#' annualised cost value over each year of the relevant period.
#' 
#' @param costdb The \bold{INVACOST database}, usually obtained with  
#' \code{data(\link{invacost})}.
#' @param startcolumn Name of the column containing starting years.
#' @param endcolumn Name of the column containing ending years.
#' @return a \code{data.frame} containing the INVACOST database where 
#' all costs occuring over several years will be repeated for each year.
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
#' invacost <- invacost[-which(is.na(invacost$Annualised.cost.estimate..2017.USD.exchange.rate.)), ]
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable.Starting.year.Low.margin",
#'                                   endcolumn = "Probable.Ending.year.Low.margin")
expandYearlyCosts <- function(costdb, startcolumn, endcolumn)
{
  return(
    dplyr::bind_rows(
      lapply(costdb$Cost.ID, function(x, costdb.,
                                      start,
                                      end) { 
        years <- costdb.[which(costdb.$Cost.ID == x), start]:
          costdb.[which(costdb.$Cost.ID == x), end]
        return(data.frame(Impact.year = years,
                          costdb.[which(costdb.$Cost.ID == x), ][
                            rep(seq_len(nrow(costdb.[costdb.$Cost.ID == x, ])), each =                               length(years)), ]))
      }, costdb. = costdb, start = startcolumn, end = endcolumn)
    )
  )
}
