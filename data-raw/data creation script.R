# invacost <- read.csv("./data-raw/INVACOST-UTF-8.csv",
#                      header = TRUE, sep = ";",
#                      na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", "Unspecified"),
#                      dec = ".",
#                      fileEncoding = "UTF-8")
library(readxl)

ic_version <- "4.1"

invacost <- as.data.frame(read_xlsx(paste0("./data-raw/InvaCost_database_v",
                                           ic_version, ".xlsx"),
                                     na = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", 
                                            "Unspecified", "Unknown",
                                            "unspecified"),
                                    guess_max = 10000))




invacost$Applicable_year <- as.numeric(invacost$Applicable_year)
invacost$Publication_year <- as.numeric(invacost$Publication_year)
invacost$Probable_starting_year <- as.numeric(invacost$Probable_starting_year)
invacost$Probable_ending_year <- as.numeric(invacost$Probable_ending_year)
invacost$Probable_starting_year_adjusted <- as.numeric(invacost$Probable_starting_year_adjusted)
invacost$Probable_ending_year_adjusted <- as.numeric(invacost$Probable_ending_year_adjusted)


# Correction in v4.1, missing a few ending dates
invacost[invacost$Reference_ID == "Gouldthorpe2009" &
           invacost$Time_range == "Year", "Probable_ending_year"] <- 
  invacost[invacost$Reference_ID == "Gouldthorpe2009" &
             invacost$Time_range == "Year", "Probable_ending_year_adjusted"] <- 
  invacost[invacost$Reference_ID == "Gouldthorpe2009" &
             invacost$Time_range == "Year", "Probable_starting_year_adjusted"]

usethis::use_data(invacost, overwrite = TRUE)


description <- as.data.frame(read_xlsx(paste0("./data-raw/Descriptors ",
                                              ic_version, ".xlsx"),
                                       skip = 3))

Encoding(description$Column_name) <- "UTF-8"
Encoding(description$Definition) <- "UTF-8"

cat(paste0("#' 'InvaCost' database
#'
#' The 'InvaCost' database compiling published values of economic costs of
#' Invasive Alien Species. Version ", ic_version, "
#' 
#'
#' \\describe{
#'   \\item{",
           paste0(apply(description[, 1:2],
      1,
      paste0, collapse = "}{"),
      collapse = "}
#'   \\item{"),
"}
#' }
#'
#'
#' @format A data frame with ", nrow(invacost), " rows and ", ncol(invacost), " variables
#' 
#' @usage data(invacost)
#' @references 
#' Diagne, C., Leroy, B., Gozlan, R. E., Vaissière, A. C., Assailly, C., 
#' Nuninger, L., Roiz, D., Jourdain, F., Jarić, I., & Courchamp, F. (2020). 
#' InvaCost, a public database of the economic costs of biological invasions 
#' worldwide. Scientific Data, 7(1), 1–12. 
#' \\doi{10.1038/s41597-020-00586-z}
#' 
#' \\url{https://github.com/Farewe/invacost}
#' 
#' Leroy Boris, Kramer Andrew M, Vaissière Anne-Charlotte, Kourantidou Melina,
#' Courchamp Franck & Diagne Christophe (2022). Analysing economic costs 
#' of invasive alien species with the invacost R package. Methods in Ecology
#' and Evolution. \doi{10.1111/2041-210X.13929}
#' 
#' History of database releases:
#'  \\doi{10.6084/m9.figshare.12668570}
#' @source \\doi{10.6084/m9.figshare.12668570}
'invacost'
"),
file = (con <- file("./R/invacost.R", "w", encoding="UTF-8")))

close(con)

