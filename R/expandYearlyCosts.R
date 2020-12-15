#' Expand cost values per year of the database over relevant periods of impact
#' 
#' For costs that occur over several years, this function repeats the 
#' cost value per year over each year of the relevant period of impact.
#' 
#' @param costdb The \bold{'InvaCost' database}, usually obtained with  
#' \code{data(\link{invacost})}
#' @param startcolumn Name of the column containing starting years
#' @param endcolumn Name of the column containing ending years
#' @return A \code{data.frame} containing the 'InvaCost' database where 
#' all costs occurring over several years are repeated for each year.
#' @export
#' @note
#' Information on the beginning and ending years was not directly provided in
#' literature sources of economic costs for a substantial part of entries in the 
#' database (\code{Probable_starting_year} and \code{Probable_ending_year 
#' columns}). 
#' Therefore, for papers for which this information was not available,  
#' educated guesses were made by the 'InvaCost' team on the probable starting 
#' and ending years. These educated guesses were designed 
#' to be conservative, and make no assumption as of whether the economic impacts 
#' have been continued after the publication year of the material where the cost
#' was collected.
#' Therefore, we used the publication year as the probable ending year. For 
#' costs repeated over several years but for which no information with respect 
#' to the exact periods of impact was available, we counted only a single year.
#' These educated guesses are included in the columns (columns 
#' \code{Probable_starting_year_adjusted} and 
#' \code{Probable_ending_year_adjusted}), and we recommend using them the base 
#' scenario, as its conservative assumptions limit over-estimations of the 
#' costs. 
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}, Andrew Kramer, Anne-Charlotte
#' Vaissière, Christophe Diagne
#' @references \url{https://github.com/Farewe/invacost}
#' 
#' Leroy Boris, Kramer Andrew M, Vaissière Anne-Charlotte, Courchamp Franck & Diagne Christophe (2020). Analysing global economic costs of invasive alien species with the
#' invacost R package. biorXiv. \url{https://doi.org/10.1101/2020.12.10.419432}
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
#' \dontrun{
#' db.over.time <- expandYearlyCosts(invacost,
#'                                   startcolumn = "Probable_starting_year_adjusted",
#'                                   endcolumn = "Probable_ending_year_adjusted")
#'                                   }
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
    A pre-filled start column should be available in 'Probable_starting_year_adjusted' (see the help file)."))
  }
  if(!(sum(is.na(costdb[,endcolumn]))==0))
  {
    stop(paste("The 'endcolumn' is missing values for", sum(is.na(costdb[,endcolumn])),"rows.
    A pre-filled end column should be available in 'Probable_ending_year_adjusted' (see the help file)."))
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
