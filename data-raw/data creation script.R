invacost <- read.csv("./data-raw/INVACOST_database.csv",
                     header = TRUE, sep = ";",
                     na.strings = c("NA", "#N/A", "#DIV/0!", "#VALEUR!"),
                     dec = ",")

colnames(invacost) <- gsub("_", "\\.", colnames(invacost))

invacost <- invacost[-which(is.na(invacost$Annualised.cost.estimate..2017.USD.exchange.rate.)), ]

usethis::use_data(invacost)
