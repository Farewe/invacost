# invacost <- read.csv("./data-raw/INVACOST-UTF-8.csv",
#                      header = TRUE, sep = ";",
#                      na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", "Unspecified"),
#                      dec = ".",
#                      fileEncoding = "UTF-8")

invacost <- as.data.frame(read_excel("./data-raw/INVACOST.xlsx",
                                     na = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", "Unspecified")))


# invacost <- invacost[-which(is.na(invacost$Annualised_cost_estimate_2017_USD_exchange_rate)), ]
invacost <- invacost[-which(invacost$`To remove` == "yes"), ]
invacost[which(invacost$Reference_ID == 8733 & 
                 invacost$Repository == "WoS"), "Method_reliability"] <- "Low"
invacost[which(invacost$Cost_ID == 1386), "Method_reliability"] <- "Low"
invacost[which(invacost$Cost_ID == 1175), "Method_reliability"] <- "Low"

invacost <- invacost[, -which(
  colnames(invacost) %in% c("Benefit_value(s)",
                            "Probable_starting_year_high_margin",
                            "Probable_ending_year_high_margin",
                            "Impacted_sector_2",
                            "To.remove",
                            "Type_2",
                            "Spatial_scale2",
                            "To remove"))]

usethis::use_data(invacost, overwrite = TRUE)


# for the help file:
cat(paste0(colnames(invacost), collapse = "}{}
#'   \\item{"))

