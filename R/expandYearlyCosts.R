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
#' data(invacost)
#' invacost <- invacost[-which(is.na(invacost$Cost_estimate_per_year_2017_USD_exchange_rate)), ]
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_low_margin",
#'                                   endcolumn = "Probable_ending_year_low_margin")
expandYearlyCosts <- function(costdb, startcolumn, endcolumn)
{
  if(!("Cost_ID" %in% colnames(invacost)))
  {
    stop("The 'invacost' object does not seem to be the invacost database (lacks cost_ID column)")
  }
  if(!(startcolumn %in% colnames(invacost)))
  {
    stop("The 'startcolumn' does not exist in the invacost database, please check spelling.")
  }
  if(!(endcolumn %in% colnames(invacost)))
  {
    stop("The 'endcolumn' does not exist in the invacost database, please check spelling.")
  }
  return(
    dplyr::bind_rows(
      lapply(costdb$Cost_ID, function(x, costdb.,
                                      start,
                                      end) { 
        years <- costdb.[which(costdb.$Cost_ID == x), start]:
          costdb.[which(costdb.$Cost_ID == x), end]
        return(data.frame(Impact_year = years,
                          costdb.[which(costdb.$Cost_ID == x), ][
                            rep(seq_len(nrow(costdb.[costdb.$Cost_ID == x, ])), 
                                each = length(years)), ]))
      }, costdb. = costdb, start = startcolumn, end = endcolumn)
    )
  )
}
