#' INVACOST database
#'
#' The database compiling published values of economic costs of Invasive Alien
#' Species.
#'
#' @format A data frame with 10005 rows and 61 variables:
#' \describe{
#'   \item{Cost_ID}{}
#'   \item{Repository}{}
#'   \item{Reference_ID}{}
#'   \item{Reference_title}{}
#'   \item{Authors}{}
#'   \item{Abstract}{}
#'   \item{Publication_year}{}
#'   \item{Language}{}
#'   \item{Type_of_material}{}
#'   \item{Previous_materials}{}
#'   \item{Availability}{}
#'   \item{Kingdom}{}
#'   \item{Phylum}{}
#'   \item{Class}{}
#'   \item{Order}{}
#'   \item{Family}{}
#'   \item{Genus}{}
#'   \item{Species}{}
#'   \item{Subspecies}{}
#'   \item{Common_name}{}
#'   \item{Environment}{}
#'   \item{Environment_IAS}{}
#'   \item{Island}{}
#'   \item{verbatimHabitat}{}
#'   \item{Habitat}{}
#'   \item{protectedArea}{}
#'   \item{Geographic_region}{}
#'   \item{Official_country}{}
#'   \item{State|Province|Administrative_area}{}
#'   \item{Location}{}
#'   \item{Spatial_scale}{}
#'   \item{Period_of_estimation}{}
#'   \item{Time_range}{}
#'   \item{Probable_starting_year}{}
#'   \item{Probable_ending_year}{}
#'   \item{Probable_starting_year_adjusted}{}
#'   \item{Probable_ending_year_adjusted}{}
#'   \item{Occurrence}{}
#'   \item{Raw_cost_estimate_local_currency}{}
#'   \item{Min_Raw_cost_estimate_local_currency}{}
#'   \item{Max_Raw_cost_estimate_local_currency}{}
#'   \item{Raw_cost_estimate_2017_USD_exchange_rate}{}
#'   \item{Raw_cost_estimate_2017_USD_PPP}{}
#'   \item{Cost_estimate_per_year_local_currency}{}
#'   \item{Cost_estimate_per_year_2017_USD_exchange_rate}{}
#'   \item{Cost_estimate_per_year_2017_USD_PPP}{}
#'   \item{Currency}{}
#'   \item{Applicable_year}{}
#'   \item{Type_of_applicable_year}{}
#'   \item{Implementation}{}
#'   \item{Acquisition_method}{}
#'   \item{Impacted_sector}{}
#'   \item{Type_of_cost}{}
#'   \item{Type_of_cost_merged}{}
#'   \item{Management_type}{}
#'   \item{Method_reliability}{}
#'   \item{Method_reliability_refined}{}
#'   \item{Method_reliability_Explanation}{}
#'   \item{Method_reliability_Expert_Name}{}
#'   \item{Overlap}{}
#'   \item{Benefit_value(s)}{}
#'   \item{Details}{}
#'   \item{Initial contributors_names}{}
#'   \item{Double-checking}
#' }
#' @usage data(invacost)
#' @details
#'  \bold{Standardisation of cost data’}
#'
#' *The number of years of the ‘Period of estimation’ is the difference between 
#' the ‘Probable ending year’ and the ‘Probable starting year”; when we had no 
#' complete or exact information on the period of costs, we considered the 
#' publication year as a starting and/or ending year, and approximated the 
#' duration time based on either the available information provided by the 
#' authors or a one-year duration when no information was available)
#' 
#' **Market exchange rate (local currency unit per US$) provided by the World
#'  Bank Open Data (available at 
#'  https://data.worldbank.org/indicator/PA.NUS.FCRF?end=2017&start=1960)
#'  
#' ***Purchase Power Parity (local currency unit per US$) provided by the World
#'  Bank Open Data (available at
#'   https://data.worldbank.org/indicator/PA.NUS.PPP?end=2017&start=1990) and 
#'   the Organisation for Economic Cooperation and Development (available at
#'    https://data.oecd.org/conversion/purchasing-powerparities-ppp.htm).
#' @references 
#' Include both the data paper and the Nature paper here.
#' @source Include URL to the original dataset here
"invacost"