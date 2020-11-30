# invacost <- read.csv("./data-raw/INVACOST-UTF-8.csv",
#                      header = TRUE, sep = ";",
#                      na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", "Unspecified"),
#                      dec = ".",
#                      fileEncoding = "UTF-8")
library(readxl)
invacost <- as.data.frame(read_xlsx("./data-raw/InvaCost_3.0.xlsx",
                                     na = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", 
                                            "Unspecified", "Unknown"),
                                    guess_max = 10000))

invacost$Applicable_year <- as.numeric(invacost$Applicable_year)
invacost$Publication_year <- as.numeric(invacost$Publication_year)
invacost$Probable_starting_year <- as.numeric(invacost$Probable_starting_year)
invacost$Probable_ending_year <- as.numeric(invacost$Probable_ending_year)
invacost$Probable_starting_year_adjusted <- as.numeric(invacost$Probable_starting_year_adjusted)
invacost$Probable_ending_year_adjusted <- as.numeric(invacost$Probable_ending_year_adjusted)
invacost$Version <- "V1"
invacost$Version[grep("NE", invacost$Cost_ID)] <- "V2"
invacost$Version[grep("SC", invacost$Cost_ID)] <- "V2-1"


usethis::use_data(invacost, overwrite = TRUE)


# for the help file:
cat(paste0(colnames(invacost), collapse = "}{}
#'   \\item{"))

