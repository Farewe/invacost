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
  if(version == "3.0")
  {
    URL <- "https://raw.githubusercontent.com/Farewe/invacost_versions/500e42400ce748ac798b45952553b3292fae7f5e/InvaCost.csv"
  } else if(version == "2.1")
  {
    URL <- "https://raw.githubusercontent.com/Farewe/invacost_versions/28e0abb20df8fafc046700943fa8ed81bd95ee57/InvaCost.csv"
  } else if(version == "2.0")
  {
    URL <- "https://raw.githubusercontent.com/Farewe/invacost_versions/bc4e59a7a76eef8ea47b462b42053c67d4c3d31b/InvaCost.csv"
  } else if(version == "1.0")
  {
    URL <- "https://raw.githubusercontent.com/Farewe/invacost_versions/b6d4c8607e4874e9c886cfae0de61a95ba2adf93/InvaCost.csv"
  } else
  {
    stop("The version you have entered does not exist. See ?getInvaCostVersion")
  }
  
  if(!is.null(destination_file))
  {
    download.file(URL, 
                  destfile = destination_file, 
                  method = "curl")
    invacost <- read.csv2(destination_file, 
                          sep = ";", header = TRUE)
  } else
  {
    destination_file <- paste0("InvaCost_", version, "_", as.numeric(Sys.time()), ".csv")
    download.file(URL, 
                  destfile = destination_file, 
                  method = "curl")
    invacost <- read.csv2(destination_file, 
                          sep = ";", header = TRUE)
    unlink(destination_file)
  }
  return(invacost)
}