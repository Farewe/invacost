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
#' @export
#' @note
#' Information on the beginning and ending years was not directly provided in
#' literature sources of economic costs for about a quarter of entries in the 
#' database. Therefore, for papers for which it was not available, we made 
#' educated guesses on the probable starting and ending years, under two 
#' different scenarios. The first scenario (called “low margin”) was designed 
#' to be realistic, and makes no assumption as of whether the economic impacts 
#' have been continued after the source was published. In this case,
#' we used the duration of impacts indicated by the authors, or publication
#' year when no information was available to fill the missing data. For costs
#' repeated over several years but for which no information with respect to
#' the exact periods of impact was available, we counted only a single year.
#' The second scenario (called “high margin”) was designed as an extreme scenario 
#' where the costs are repeated over time until the reference year of the 
#' database (2017). These two scenarios are provided in the four fields added
#' to the database with the package. We recommend using the “low margin”
#' (columns \code{Probable_starting_year_low_margin} and 
#' \code{Probable_ending_year_low_margin}) scenario as the base scenario, as 
#' its conservative assumptions make it more realistic. 
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
  if(!("Cost_ID" %in% colnames(costdb)))
  {
    stop("The 'invacost' object does not seem to be the invacost database (lacks cost_ID column)")
  }
  if(!(startcolumn %in% colnames(costdb)))
  {
    stop("The 'startcolumn' does not exist in the invacost database, please check spelling.")
  }
  if(!(endcolumn %in% colnames(costdb)))
  {
    stop("The 'endcolumn' does not exist in the invacost database, please check spelling.")
  }
  if(!(sum(is.na(costdb[,startcolumn]))==0))
  {
    stop(paste("The 'startcolumn' is missing values for", sum(is.na(costdb[,startcolumn])),"rows.
    A pre-filled start column should be available in 'Probable_starting_year_low_margin' (see the help file)."))
  }
  if(!(sum(is.na(costdb[,endcolumn]))==0))
  {
    stop(paste("The 'endcolumn' is missing values for", sum(is.na(costdb[,endcolumn])),"rows.
    A pre-filled end column should be available in 'Probable_ending_year_low_margin' (see the help file)."))
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
