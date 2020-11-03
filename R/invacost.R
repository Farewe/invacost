#' INVACOST database
#'
#' The database compiling published values of economic costs of Invasive Alien
#' Species.
#'
#' @format A data frame with 10005 rows and 61 variables:
#' \describe{
#'   \item{Cost_ID}{A unique numerical identifier for the cost estimate}
#'   \item{Repository}{The original source of each material: 'Web of Science 
#'   (WoS)', 'Google Scholar (GS)', 'Google search engine (Go)' or ‘Targeted 
#'   collection (TC)'  }
#'   \item{Reference_ID}{The numerical identifier of the material analysed, 
#'   which allows correspondence with the InvaCost_references file that provides
#'    bibliographic details }
#'   \item{Reference_title}{The title of the material analysed}
#'   \item{Authors}{The authors of the material analysed }
#'   \item{Publication_year}{The publication year of the material analysed}
#'   \item{Type_of_material}{ The type of material analysed (i.e. scientific 
#'   peer-reviewed article or grey literature); for grey literature, the exact 
#'   nature of the material was indicated (e.g., official report, press 
#'   release)}
#'   \item{Previous_materials}{If any, the list of successive materials checked
#'    before reaching the material originally providing the cost estimate}
#'   \item{Availability}{The accessibility of the material as a searchable 
#'   document (yes/no)}
#'   \item{Kingdom}{For each species recorded, the taxonomic information from 
#'   kingdom level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Phylum}{For each species recorded, the taxonomic information from 
#'   kingdom level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Class}{For each species recorded, the taxonomic information from 
#'   Class level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Order}{For each species recorded, the taxonomic information from 
#'   Order level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Family}{For each species recorded, the taxonomic information from 
#'   Family level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Genus}{For each species recorded, the taxonomic information from 
#'   Genus level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Species}{For each species recorded, the taxonomic information from 
#'   Species level using the Global Biodiversity Information Facility
#'    (GBIF) as a reference }
#'   \item{Common_name}{The non-scientific (or vernacular) name(s) provided by 
#'   the authors, or by the International Union for Conservation of Nature 
#'   (IUCN) when not provided}
#'   \item{Environment}{The type of habitat (aquatic, terrestrial, semi-aquatic) 
#'   where the cost estimate occurred }
#'   \item{Geographic_region}{The geographical region(s) where the cost estimate
#'    occurred (Africa, Asia, Central America, Europe, North America, 
#'    Oceania-Pacific islands, South America)}
#'   \item{Official_country}{The country or official territory where the cost is
#'    incurred; sometimes, this is not congruent with the geographic regions as 
#'    some territories (e.g. Overseas areas) are situated on other continents 
#'    than their country of attachment}
#'   \item{State/Province}{}
#'   \item{Location}{When provided, the precise location (e.g., region, city, 
#'   area) where the cost estimate occurred }
#'   \item{Spatial_scale}{The spatial scale considered for estimating the cost: 
#'   global (worldwide-scale), intercontinental (sites from two or more 
#'   geographic regions) continental ('geographic region' level), regional
#'    (several countries within a single geographic region), country, site (for 
#'    cost evaluated at intra-country level, including USA states) and unit (for 
#'    costs evaluated for a well-defined surface area or entity)}
#'   \item{Period_of_estimation}{If provided, the exact period of time covered 
#'   by the costs estimated, otherwise the raw formulation (e.g. late 90’s, 
#'   during 5 years)}
#'   \item{Time_range}{The time range considered by the authors for providing 
#'   the cost estimate: year (when costs were if the estimate is given yearly or
#'    for a period up to one year) or period (when costs were provided for a 
#'    period exceeding a year)}
#'   \item{Probable_starting_year}{The year range in which the cost is known or 
#'   assumed to occur. When not explicitly provided by the authors, we mentioned
#'    'unspecified' in both columns unless the authors provided a clear duration
#'     time. In this case, we considered the ‘Publication year’ as a reference 
#'     for the probable starting/ending year from which we added/subtracted the 
#'     number of years* of the ‘Period of estimation’. In the case of a cost 
#'     estimate provided for a one-year period straddling two calendar years,
#'      we mentioned the latest year of the cost occurrence in both columns.
#'       When vague formulations were used (e.g. early 90’s), we still 
#'       translated them in probable ending/starting year (e.g. 1990-1995). We
#'        will harmonise the way these specific cases are dealt with when 
#'        reviewing and validating new lines proposed by new contributors. }
#'   \item{Probable_ending_year}{see \code{Probable_starting_year}}
#'   \item{Occurrence}{The status of the cost estimate as potentially ongoing 
#'   (if the cost can be expected to continue over time) or one-time (if the 
#'   cost was explicitly considered as over by the authors)}
#'   \item{Raw_cost_estimate_local_currency}{The cost estimate directly
#'    retrieved from the analysed materials }
#'   \item{Min_Raw_cost_estimate_local_currency}{The lower boundary of the ‘Raw 
#'   cost estimate local currency’ (if a range of estimates was provided by the 
#'   authors)}
#'   \item{Max_Raw_cost_estimate_local_currency}{The higher boundary of the ‘Raw 
#'   cost estimate local currency’ (if a range of estimates was provided by the
#'    authors)}
#'   \item{Raw_cost_estimate_2017_USD_exchange_rate}{The ‘Raw cost estimate 
#'   local currency’ standardised from local ‘Currency’ and ‘Applicable year’
#'    to 2017 US$ based on ER** }
#'   \item{Raw_cost_estimate_2017_USD_PPP}{The ‘Raw cost estimate local 
#'   currency’ standardised to 2017 US$ based on PPP*** }
#'   \item{Cost_estimate_per_year_local_currency}{The ‘Raw cost estimate local 
#'   currency’ transformed to a cost estimate per year of the ‘Period of 
#'   estimation’ (obtained by dividing the raw cost estimate by the number 
#'   of years* of the ‘Period of estimation’) }
#'   \item{Cost_estimate_per_year_2017_USD_exchange_rate}{The ‘Cost estimate per
#'    year local currency’ standardised from local ‘Currency’ and ‘Applicable 
#'    year’ to 2017 USD based on ER** (See the formula in the ‘Standardisation
#'     of cost data’ section)}
#'   \item{Cost_estimate_per_year_2017_USD_PPP}{: The ‘Cost estimate per year 
#'   local currency’ standardised from local ‘Currency’ and ‘Applicable year’
#'    to 2017 USD based on PPP*** (See the formula in the ‘Standardisation of
#'     cost data’ section)}
#'   \item{Currency}{The currency of the ‘Raw cost estimate local currency’ as
#'    extracted from the material}
#'   \item{Applicable_year}{The year of the ‘Currency’ value (not the year of 
#'   the cost occurrence) considered for the conversion/standardization of the 
#'   cost estimate}
#'   \item{Type_of_applicable_year}{The assessment of the applicable year as
#'   effective if explicitly stated by the authors or publication year if no 
#'   explicit information provided}
#'   \item{Implementation}{This states – at the time of the estimation – whether 
#'   the reported cost was actually observed (i.e. cost actually incurred) or 
#'   potential (i.e. not incurred but expected cost)}
#'   \item{Acquisition_method}{: The method used to provide the cost estimate as
#'    a report/estimation (gathered or derived from field-based information) or
#'     extrapolation (cost modelled beyond the original spatial and/or temporal 
#'     observation range)}
#'   \item{Impacted_sector}{The sector impacted by the cost estimate in our 
#'   socio-ecosystems (e.g. agriculture, health, public and social welfare; see
#'    Table 3 in the data paper for details on each category)}
#'   \item{Type_of_cost}{The type of the cost includes: damages and losses 
#'   incurred by an invasion (e.g. damage repair, medical care, value of crop 
#'   losses), or means dedicated to understand or predict (e.g. research), 
#'   prevent (e.g. education, biosecurity), early detect (e.g. monitoring, 
#'   surveillance) and/or manage (e.g. control, eradication) the invaders}
#'   \item{Method_reliability}{The assessment of the methodological approach 
#'   used for cost estimation as of (i) high reliability if either provided by 
#'   officially pre-assessed materials (peer-reviewed articles and official 
#'   reports) or the estimation method was documented, repeatable and/or
#'    traceable if provided by other grey materials, or (ii) low reliability if
#'     not (see Figure 2 for more details)}
#'   \item{Details}{When necessary, narrative elements deemed important either
#'    to understand the cost estimate or to support choices made for completing
#'     the database; this column was left unchanged from the original entries in 
#'     order to allow trace-back investigations}
#'   \item{Benefit_value(s)}{The mention of if any benefit value was found in 
#'   the analysed material (yes/no); the figure was not recorded or described 
#'   as being out of the scope of InvaCost}
#'   \item{Contributors}{The name of collaborator(s) having recorded the cost 
#'   estimate; currently, it is only the initials of the authors, but each 
#'   future contributor will be consistently acknowledged here}
#'   \item{Island}{Indicates if costs are for an island (Y) or mainland (N) or
#'   if this information was not specified or for both island & mainland(NA)}
#'   \item{verbatimHabitat}{A copy from the source of the explanation of the
#'    "habitat" or studied site/area/system}
#'   \item{Habitat}{Habitat classification code (see details)}
#'   \item{protectedArea}{Indicates if costs are for protected area (Y) or not 
#'   (N) or if this information was not specified or included both types (NA)}
#'   \item{Abstract}{Abstract of the document from which the cost estimation
#'   was extracted}
#'   \item{Language}{Refers to the language in which the document was written}
#'   \item{Probable_starting_year_high_margin}{}
#'   \item{Probable_ending_year_high_margin}{}
#'   \item{Probable_starting_year_low_margin}{}
#'   \item{Probable_ending_year_low_margin}{}
#'   \item{Impacted_sector_2}{}
#'   \item{Type_2}{}
#'   \item{To removeNew}{}
#'   \item{Spatial_scale2}{}
#'   \item{Version}{Version in which the cost estimate was added. Useful to
#'   reproduce results from earlier versions of the database by eliminating
#'   recent entries. Do not use it to remove "older" entries as these remain
#'   valid even for recent versions.}
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