invacost <- read.csv("./data-raw/INVACOST.csv",
                     header = TRUE, sep = ";",
                     na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!", "Unspecified"),
                     dec = ".")

# invacost <- invacost[-which(is.na(invacost$Annualised_cost_estimate_2017_USD_exchange_rate)), ]
invacost[which(invacost$Reference_ID == 8733 & 
                 invacost$Repository == "WoS"), "Method_reliability"] <- "Low"
invacost[which(invacost$Cost_ID == 1386), "Method_reliability"] <- "Low"
invacost[which(invacost$Cost_ID == 1175), "Method_reliability"] <- "Low"

usethis::use_data(invacost, overwrite = TRUE)

