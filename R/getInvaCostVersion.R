#' Download and read a specific version of InvaCost
#' 
#' This function will download the requested major release of InvaCost to
#' the specified file, then read it into R, such that analyses done on older
#' releases of the database can be reproduced.
#' 
#' @param version \code{character} indicating the major release to download.
#' Current versions include: \code{"1.0"}, \code{"2.0"}, \code{"2.1"}, 
#' \code{"3.0"}
#' @param destination_file \code{character} indicating the name of the saved
#' file
#' 
#' @return a \code{data.frame} with dimensions variable depending on the chosen
#' version.
#' 
#' @details
#' The public archive for invacost releases is available here:
#' \url{https://figshare.com/articles/dataset/InvaCost_References_and_description_of_economic_cost_estimates_associated_with_biological_invasions_worldwide_/12668570}
#' 
#' The files used in this function correspond to official releases by the 
#' InvaCost team and are downloaded in CSV (sep = ";") from a dedicated
#' GitHub repository: \url{https://github.com/Farewe/invacost_versions}
#' 
#' @importFrom utils download.file read.csv2
#' @references \url{https://github.com/Farewe/invacost}
#' 
#' Leroy Boris, Kramer Andrew M, Vaissière Anne-Charlotte, Courchamp Franck & Diagne Christophe (2020). Analysing global economic costs of invasive alien species with the
#' invacost R package. biorXiv. \url{https://doi.org/10.1101/2020.12.10.419432}
#' @export
#' @author
#' Boris Leroy \email{leroy.boris@@gmail.com}, Andrew Kramer, Anne-Charlotte
#' Vaissière, Christophe Diagne
#' @examples
#' invacost <- getInvaCostVersion("1.0")
#' dim(invacost)


getInvaCostVersion <- function(
  version = "3.0",
  destination_file = NULL
)
{
  
  URL <- paste0("https://raw.githubusercontent.com/Farewe/invacost_versions/master/InvaCost_",
                version, ".csv")

  if(!is.null(destination_file))
  {
    download.file(URL, 
                  destfile = destination_file, 
                  method = "auto")
    invacost <- read.csv2(destination_file, 
                          sep = ";", header = TRUE,
                          na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", 
                                         "Unspecified", "Unknown", ""))
  } else
  {
    destination_file <- paste0("InvaCost_", version, "_", as.numeric(Sys.time()), ".csv")
    download.file(URL, 
                  destfile = destination_file, 
                  method = "auto")
    invacost <- read.csv2(destination_file, 
                          sep = ";", header = TRUE,
                          na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", 
                                         "#REF!",
                                         "Unspecified", "Unknown", ""))
    unlink(destination_file)
  }

  invacost$Cost_estimate_per_year_local_currency <- as.numeric(invacost$Cost_estimate_per_year_local_currency)
  invacost$Cost_estimate_per_year_2017_USD_exchange_rate <- as.numeric(invacost$Cost_estimate_per_year_2017_USD_exchange_rate)
  invacost$Cost_estimate_per_year_2017_USD_PPP <- as.numeric(invacost$Cost_estimate_per_year_2017_USD_PPP)
  invacost$Applicable_year <- as.numeric(invacost$Applicable_year)
  invacost$Publication_year <- as.numeric(invacost$Publication_year)
  invacost$Probable_starting_year <- as.numeric(invacost$Probable_starting_year)
  invacost$Probable_ending_year <- as.numeric(invacost$Probable_ending_year)
  invacost$Probable_starting_year_adjusted <- as.numeric(invacost$Probable_starting_year_adjusted)
  invacost$Probable_ending_year_adjusted <- as.numeric(invacost$Probable_ending_year_adjusted)
  
  return(invacost)
}