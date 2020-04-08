The INVACOST R Package: Global Costs of Biological Invasions
================
INVACOST team
03/04/2020

  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Changes to the package](#changes-to-the-package)
  - [Basic steps to get started](#basic-steps-to-get-started)
      - [How to load the data in R?](#how-to-load-the-data-in-r)
      - [Where are the economic values I should
        use?](#where-are-the-economic-values-i-should-use)
      - [How do we filter out unreliable
        costs?](#how-do-we-filter-out-unreliable-costs)
      - [How do I know when costs
        occurred?](#how-do-i-know-when-costs-occurred)
      - [How complete is our economic
        data?](#how-complete-is-our-economic-data)
  - [Calculate raw/observed costs of
    invasions](#calculate-rawobserved-costs-of-invasions)
      - [Basic usage](#basic-usage)
      - [Customising parameters](#customising-parameters)
      - [Customising graphs](#customising-graphs)
  - [Estimate the average annual cost of
    invasions](#estimate-the-average-annual-cost-of-invasions)
      - [Correction for data incompleteness due to publication
        lag](#correction-for-data-incompleteness-due-to-publication-lag)
      - [Assumptions](#assumptions)
      - [Models included in the ensemble
        modelling](#models-included-in-the-ensemble-modelling)
      - [Model fitting](#model-fitting)
      - [How to choose between models?](#how-to-choose-between-models)
      - [Customising graphs](#customising-graphs-1)
  - [Example on a specific subset: mammals of North
    America](#example-on-a-specific-subset-mammals-of-north-america)
  - [Example on many subsets: all taxons/species in the
    database](#example-on-many-subsets-all-taxonsspecies-in-the-database)
  - [Improving the package](#improving-the-package)
  - [Citation](#citation)

# Introduction

The INVACOST R package provides the INVACOST database in R with several
functions to analyse economic costs of invasive species.

There are two main methods developed in this package to estimate the
costs associated to biological invasions.

  - The first approach consists in calculating the *raw costs* that
    occurred over specific intervals of time. From this approach you can
    obtain the *observed* cumulated and average annual costs of
    biological invasions for the chosen tim intervals.  
    This approach is generalisable to any subset of the invacost
    database, regardless of data quantity. However, it does account for
    the temporal dynamics of costs, and may thus underestimate the costs
    of invasions, especially for recent years for which we have
    incomplete data.

  - The second approach consists in estimating the long-term trend in
    annual cost values with an ensemble modelling approach. Because it
    includes the dynamic nature of cost values, it is probably the most
    robust approach to estimate average annual costs. However, it
    requires more data and for data-poor cases it will not work or
    provide inadequate results. We fit several models because the trend
    of costs over time is not necessarily linear. This approach requires
    decisions about models to keep or remove, on the basis of the
    quality of model fit, or of our *a priori* assumptions. Note that
    this modelling approach is not designed for extrapolations because
    there is no certainty that the underlying factors of costs will have
    similar trends in the future.

# Installation

The easiest method to install the package for now is to install it
directly from github with the following command line (requires the
package devtools).

**DOES NOT WORK UNTIL THE PACKAGE IS RELEASED PUBLICLY ON GITHUB**

``` r
install.packages("devtools")
devtools::install_github("Farewe/invacost")
```

However, for as long as the package is in embargo, you have to install
it manually from the .tar.gz file. Before you do that, install the
following packages:

``` r
install.packages(c("dplyr", "earth", "mgcv", "quantreg", "scales"))
```

Then, install the package from the .tar.gz file (do not extract it,
install from the raw .tar.gz).

# Changes to the package

For those of you who tried the earlier versions of the package:

  - Many bugs arose when working on small subsets of invacost. Most of
    them have been corrected.

  - Graphics are no longer included in the functions. They are not
    provided as stand-alone generic function (i.e. type
    `plot(your.object)` and you will get the same graphs as before).
    They are easier to customise if you are familiar with ggplot2.

  - New information has been added in outputs of functions, e.g. the
    number of unique estimates used to compute values.

  - Lots of minor changes / quality of life improvement.

# Basic steps to get started

## How to load the data in R?

``` r
library(invacost)
data(invacost)
```

The database is now loaded in R memory under a very original name:
`invacost`.

``` r
# Number of rows (cost estimates)
nrow(invacost)
```

    ## [1] 2392

``` r
# Number of columns (database fields)
ncol(invacost)
```

    ## [1] 47

There are 47 fields in the invacost database, and I strongly recommend
you get familiarised with them by inspecting them individually and
reading the paper describing the database (and its fields) available
here: `link to be added when available ¯\_(ツ)_/¯`.

## Where are the economic values I should use?

There are several fields that contain economic values (they generally
contain `cost` in their names), but you probably won’t need most of
them. Indeed, we stored raw information from the papers, but this raw
information is often difficult to compare because it can be based on
different currencies, different years (inflation) and different periods
of time (e.g. 1 year vs 10 years). Therefore, we standardised economic
values into annual cost values in 2017 US$ with two different methods.
We recommend you use one of these two standardised cost columns:

  - `Cost_estimate_per_year_2017_USD_exchange_rate`: Annual cost
    estimate in US$ 2017 based on exchange rate
  - `Cost_estimate_per_year_2017_USD_PPP`: Annual cost estimate in US$
    2017 based on purchasing power parity (PPP)

The second method is probably more robust to provide equitable
estimations between countries, but PPP was not available for all
countries and all years, so oftentimes it could not be estimated.
Therefore, to avoid data exclusion, we generally tend to focus on
exchange rate since it is available for most country after 1960.

Therefore, in the following sections we will always use the same column
for cost values: `Cost_estimate_per_year_2017_USD_exchange_rate`.

There is a small number of costs for which we could not derive these
estimates, so we will exclude them for the rest of this tutorial.

``` r
if(any(is.na(invacost$Cost_estimate_per_year_2017_USD_exchange_rate)))
{
  invacost <- invacost[-which(is.na(invacost$Cost_estimate_per_year_2017_USD_exchange_rate)), ]
}

# Number of rows (cost estimates)
nrow(invacost)
```

    ## [1] 2389

## How do we filter out unreliable costs?

You have to be aware of the limitations of such a database. This
database is the most up-to-date and comprehensive compilation of both
the published and grey literature on the economic costs of biological
invasions. Therefore, it includes sound estimations of economic costs of
invasive species, with detailed sources and reproducible methodology;
but it also includes unsourced and irreproducible *guestimates*.
Therefore, we want to apply filters on the database to avoid as much as
possible the unreliable economic cost estimates. Furthermore, the
database includes both observed and predicted costs, so depending on our
objectives we may or may not want to filter out potential costs.

  - **Reliability**: There is a standard field in the database called
    `Method_reliability`, which provides a simple yet objective
    evaluation of the reliability of cost estimates. It uses the
    following decision tree:
    <img src="./Readme_files/figure-html/reliability.png" width="1700" />
    Red means categorised as unreliable, green means categorised as
    reliable. This reliability descriptor has limitations. The most
    important one is that we decided to not evaluate the methodology for
    peer-reviewed articles and official reports. This choice was based
    on experiments where we identified strong divergence in reliability
    decisions between different members of the INVACOST team. We also
    identified that depending on the study objective, different
    decisions about reliability could be made. Therefore, this
    `Method_reliability` descriptor should be considered as a first
    approximation of cost reliability, and you should decide whether or
    not you want to eliminate papers on the basis of thee lack of
    reproducibility of their methodologies. To do that, take time to
    investigate the `Details` field (especially for cost values that you
    deem suspiciously high) and potentially go back to the source to
    make your decision. For an example on how to do that, take a look at
    the “Determining cost estimate reproducibility” section in [Bradshaw
    et al. 2016](https://www.nature.com/articles/ncomms12986#Sec8).

<!-- end list -->

``` r
unique(invacost$Method_reliability)
```

    ## [1] "High" "Low"

  - **Observed vs. Potential costs**: The `Implementation` field in the
    database documents whether the costs correspond to Observed or
    Potential costs. Choose depending on your study objectives. In
    addition, costs can also be based on direct observations or
    estimations, or can be based on extrpolations: this is documented in
    the `Acquisition_method` field. Extrapolation does not necessarily
    mean potential: some Observed costs may have been extrapolated from
    a reduced spatial extent. Below is a table showing the number of
    cases of extrapolations and reports/estimation for observed and
    potential costs. As you can see, the majority of Observed costs are
    based on reports / estimations; yet a few are based on
    extrapolations.

<!-- end list -->

``` r
table(invacost$Acquisition_method, invacost$Implementation)
```

    ##                    
    ##                     Observed Potential
    ##   Extrapolation           66       217
    ##   Report/Estimation     1794       312

For the rest of this tutorial, we will be working only on costs
categorised as “reliable” and “observed”:

``` r
invacost <- invacost[which(invacost$Method_reliability == "High"), ]
invacost <- invacost[which(invacost$Implementation == "Observed"), ]

# Number of rows after filtering
nrow(invacost)
```

    ## [1] 1338

## How do I know when costs occurred?

A crucial aspect in analysing cost values is to know the periods of time
over which costs occurred. Indeed, knowing the period over which a cost
occurred allows to derive cumulative costs, estimating average annual
costs; it also enables temporal analyses of costs.  
We have stored information on the periods of time over which cost
occurred in two fields: `Probable_starting_year` and
`Probable_ending_year`.

However, this information was not readily available in a substantial
portion of the papers we compiled in the database: for 720 out of 1338
papers (53.8 % of papers), this information was not available.

Therefore, for papers for which it was not available, we made educated
guesses on the probable starting and ending years, on the basis of a set
of rules we decided for our main paper (*link to be added when the paper
is published*). These educated guesses were based on conservative rules
(e.g., if no duration information was provided, then the impact was
reported of one year only). These estimated stgarting and ending years
are available in two new fields in the database called
`Probable_starting_year_low_margin` and
`Probable_ending_year_low_margin`.

As it stands now, each cost has a starting and an ending year, and
schematically it looks like this:

| Cost ID | Species | Annual Cost | Starting year | Ending year |
| ------- | :------ | ----------: | ------------: | ----------: |
| 1       | Sp 1    |         100 |          1998 |        2001 |
| 2       | Sp 2    |          15 |          2005 |        2007 |
| 3       | Sp 3    |           3 |          1981 |        1981 |

However, to properly analyse the temporal trends of costs, we need to
*expand* it, to make it look like this:

| Cost ID | Species | Annual Cost | Year |
| ------- | :------ | ----------: | ---: |
| 1       | Sp 1    |         100 | 1998 |
| 1       | Sp 1    |         100 | 1999 |
| 1       | Sp 1    |         100 | 2000 |
| 1       | Sp 1    |         100 | 2001 |
| 2       | Sp 2    |          15 | 2005 |
| 2       | Sp 2    |          15 | 2006 |
| 2       | Sp 2    |          15 | 2007 |
| 3       | Sp 3    |           3 | 1981 |

To do this, we use the function we use the function `expandYearlyCosts`,
to which we provide the starting and ending year columns. It will store
the years over which economict costs occured in a column named
`Impact_year`.

``` r
# Expanding and formating the database
db.over.time <- expandYearlyCosts(invacost,
                                  startcolumn = "Probable_starting_year_low_margin",
                                  endcolumn = "Probable_ending_year_low_margin")
# Let's see some columns
head(db.over.time[, c("Cost_ID", "Species",
                      "Cost_estimate_per_year_2017_USD_exchange_rate",
                      "Impact_year")])
```

    ##   Cost_ID               Species Cost_estimate_per_year_2017_USD_exchange_rate
    ## 1       1         Vulpes vulpes                                      16701772
    ## 2       2         Vulpes vulpes                                     181333526
    ## 3       3         Vulpes vulpes                                      15270192
    ## 4      11 Oryctolagus cuniculus                                      21855462
    ## 5      17 Oryctolagus cuniculus                                      84091037
    ## 6      24      Canis lupus spp.                                      46096891
    ##   Impact_year
    ## 1        2004
    ## 2        2004
    ## 3        2000
    ## 4        2004
    ## 5        2004
    ## 6        2004

## How complete is our economic data?

It is impossible to evaluate the absolute degree of completeness of our
invacost - we know that we lack data for many taxonomic groups
(e.g. plants are currently underrepresented) and many places around the
earth (most cost data is located in North America and Europe). You have
to be aware of these potential biases and remember them when
interpreting data/analyses.

There is, however, a temporal bias that we can at least evaluate.
Indeed, we can expect that there is delay between the economic impact of
an invasive species, and the time at which people will start estimating
the value of the impact, and then publish it in a report or journal.

We can grasp an idea of this delay by looking at the difference between
`Impact_year` and `Publication_year` in the expanded database,
`db.over.time`.

``` r
# Calculating time lag
db.over.time$Publication_lag <- db.over.time$Publication_year - db.over.time$Impact_year

# Make a nice boxplot of the time lag
ggplot(db.over.time,
       aes(y = Publication_lag)) +
  geom_boxplot(outlier.alpha = .2) +
  ylab("Publication lag (in years)") + 
  theme_minimal() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.text.y = element_blank(),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 18)) +
  scale_y_continuous(breaks = c(-25, 0, 25, 50, 75, 100),
                     labels = c(-25, 0, 25, 50, 75, 100)) +
  xlab("") +
  coord_flip()
```

![](Readme_files/figure-gfm/lag1-1.png)<!-- -->

*Note that the few occurrences of publications before economic impacts
(negative lag) corresponded to planned budgets over specific periods
expanding beyond the publication year.*

Our suggestion is to use the quartiles of publication lag as an
indication of cost data completeness.

The first quartile indicates the delay to reach 25% completeness; the
median indicates the delay to reach 50% completeness; and the third
quartile indicates the delay to reach 75% completeness.

Let’s see these delays in practice:

``` r
quantiles <- quantile(db.over.time$Publication_lag, probs = c(.25, .5, .75))
quantiles
```

    ## 25% 50% 75% 
    ##   2   6  11

The median delay between impact and publication of impact was **6
years**. In other words, **for the last 6 years, we can expect to have
less than 50% of the economic impacts**.

Likewise, we can say it takes approximately 2 years to have 25% of the
economic data for any year, and 11 years to reach at least 75% of
economic data.

Hence, any analysis on recent years will be based on incomplete data and
is highly likely to provide an underestimation of actual costs.

It is up to you to determine how you desire to include this information
in your analyses; here, we will provide examples of how we suggest to do
that.

One question that may arise for people working on specific subsets of
the database (e.g., only one taxon or one country) is whether you should
evaluate the time lag on your subset. I would recommend to avoid that,
because your subset may be too incomplete to provide a decent estimation
of the time lag. Therefore, I would suggest to evaluate the time lag
only on the global dataset, as we did here.

# Calculate raw/observed costs of invasions

## Basic usage

The first method to analyse economic costs of invasive species consists
in calculating the observed cumulative and average costs over one
specific period of time, or at different time intervals.

We implemented this method in the function `calculateRawAvgCosts`. It
will calculate the cumulative and average costs for the entire period,
as well as for different time intervals (by default, 10-year intervals).

``` r
raw.costs <- calculateRawAvgCosts(db.over.time)
```

    ## Warning in calculateRawAvgCosts(db.over.time): There are 8 cost values for periods earlier than 1960, which will be removed.

    ## Warning in calculateRawAvgCosts(db.over.time): There are 1 cost values for periods later than 2017 which will be removed.

We can get a summary of the results by typing the name of the object in
the console

``` r
raw.costs
```

    ## Average annual cost of invasive species over time periods
    ## 
    ## - Temporal interval of data : [1960, 2017]
    ## - Values transformed in US$ million: Yes
    ## - Number of cost estimates: 1332 (number of individual year values: 3596)
    ## - Cost values in US$ millions:
    ##     o Total cost over the entire period 1,389,519.11
    ##     o Average annual cost over the entire period 23,957.23
    ##     o Average annual cost over each period
    ## 
    ##   initial_year final_year time_span total_cost annual_cost number_estimates
    ## 1         1960       1969        10     275.76       27.58                5
    ## 2         1970       1979        10   4,531.06      453.11               24
    ## 3         1980       1989        10  12,584.11    1,258.41               89
    ## 4         1990       1999        10 204,428.34   20,442.83              276
    ## 5         2000       2009        10 934,110.64   93,411.06              792
    ## 6         2010       2017         8 233,589.20   29,198.65              344
    ##   number_year_values
    ## 1                 32
    ## 2                 74
    ## 3                260
    ## 4                773
    ## 5               1979
    ## 6                478

And we can have a graphical output with:

``` r
plot(raw.costs)
```

![](Readme_files/figure-gfm/raw3-1.png)<!-- -->

This graph represents the observed annual costs of biological invasions
over time. Points are total annual costs for every year (i.e., all
individual costs for a specific year are summed). Horizontal bars
represent the average annual cost for a specific interval of time (here,
10-year intervals). Notice how average annual costs are driven by a
limited number of high-cost years. The dashed line connects average
annual cost of each time interval at mid-years (black dots). The
horizontal dotted line represents the average cost over the entire
period.

We can access the content of the output object with

``` r
str(raw.costs)
```

    ## List of 5
    ##  $ cost.data              :'data.frame': 3596 obs. of  49 variables:
    ##   ..$ Impact_year                                  : int [1:3596] 2004 2004 2000 2004 2004 2004 2004 2004 1996 1993 ...
    ##   ..$ Cost_ID                                      : num [1:3596] 1 2 3 11 17 24 25 30 33 35 ...
    ##   ..$ Repository                                   : chr [1:3596] "TC" "TC" "TC" "TC" ...
    ##   ..$ Reference_ID                                 : num [1:3596] 2 2 2 559 2 2 2 2 409 409 ...
    ##   ..$ Reference_title                              : chr [1:3596] "Counting the Cost: Impact of Invasive Animals in Australia" "Counting the Cost: Impact of Invasive Animals in Australia" "Counting the Cost: Impact of Invasive Animals in Australia" "The economic benefits of rabbit control in Australian temperate pastures by the introduction of rabbit haemorrhagic disease" ...
    ##   ..$ Authors                                      : chr [1:3596] "McLeod" "McLeod" "McLeod" "Vere et al" ...
    ##   ..$ Publication_year                             : num [1:3596] 2004 2004 2004 2004 2004 ...
    ##   ..$ Type_of_material                             : chr [1:3596] "Official report" "Official report" "Official report" "Peer-reviewed article" ...
    ##   ..$ Previous_materials                           : chr [1:3596] "Rolfe, J., & Windle, J. (2014). Public preferences for controlling an invasive species in public and private sp"| __truncated__ "Rolfe, J., & Windle, J. (2014). Public preferences for controlling an invasive species in public and private sp"| __truncated__ "Rolfe, J., & Windle, J. (2014). Public preferences for controlling an invasive species in public and private sp"| __truncated__ "McLeod, R. (2004). Counting the Cost: Impact of Invasive Animals in Australia, 2004. Canberra. Retrieved from h"| __truncated__ ...
    ##   ..$ Availability                                 : chr [1:3596] "Yes" "Yes" "Yes" "Yes" ...
    ##   ..$ Kingdom                                      : chr [1:3596] "Animalia" "Animalia" "Animalia" "Animalia" ...
    ##   ..$ Phylum                                       : chr [1:3596] "Chordata" "Chordata" "Chordata" "Chordata" ...
    ##   ..$ Class                                        : chr [1:3596] "Mammalia" "Mammalia" "Mammalia" "Mammalia" ...
    ##   ..$ Order                                        : chr [1:3596] "Carnivora" "Carnivora" "Carnivora" "Lagomorpha" ...
    ##   ..$ Family                                       : chr [1:3596] "Canidae" "Canidae" "Canidae" "Leporidae" ...
    ##   ..$ Genus                                        : chr [1:3596] "Vulpes" "Vulpes" "Vulpes" "Oryctolagus" ...
    ##   ..$ Species                                      : chr [1:3596] "Vulpes vulpes" "Vulpes vulpes" "Vulpes vulpes" "Oryctolagus cuniculus" ...
    ##   ..$ Common_name                                  : chr [1:3596] "Red fox" "Red fox" "Red fox" "European (common) rabbit" ...
    ##   ..$ Environment                                  : chr [1:3596] "Terrestrial" "Terrestrial" "Terrestrial" "Terrestrial" ...
    ##   ..$ Geographic_region                            : chr [1:3596] "Oceania-Pacific islands" "Oceania-Pacific islands" "Oceania-Pacific islands" "Oceania-Pacific islands" ...
    ##   ..$ Official_country                             : chr [1:3596] "Australia" "Australia" "Australia" "Australia" ...
    ##   ..$ Location                                     : chr [1:3596] NA NA "Tasmania" NA ...
    ##   ..$ Spatial_scale                                : chr [1:3596] "Country" "Country" "Site" "Country" ...
    ##   ..$ Period_of_estimation                         : chr [1:3596] "2004" "2004" "2000" "2004" ...
    ##   ..$ Time_range                                   : chr [1:3596] "Year" "Year" "Year" "Year" ...
    ##   ..$ Probable_starting_year                       : num [1:3596] 2004 2004 2000 2004 2004 ...
    ##   ..$ Probable_ending_year                         : num [1:3596] NA NA NA NA NA NA NA NA NA NA ...
    ##   ..$ Occurrence                                   : chr [1:3596] "Potentially ongoing" "Potentially ongoing" "Potentially ongoing" "Potentially ongoing" ...
    ##   ..$ Raw_cost_estimate_local_currency             : num [1:3596] 1.75e+07 1.90e+08 1.60e+07 2.29e+07 8.81e+07 ...
    ##   ..$ Min_Raw_cost_estimate_local_currency         : num [1:3596] NA NA NA 7100000 NA NA NA NA NA NA ...
    ##   ..$ Max_Raw_cost_estimate_local_currency         : num [1:3596] NA NA NA 38700000 NA NA NA NA NA NA ...
    ##   ..$ Raw_cost_estimate_2017_USD_exchange_rate     : num [1:3596] 1.67e+07 1.81e+08 1.53e+07 2.19e+07 8.41e+07 ...
    ##   ..$ Raw_cost_estimate_2017_USD_PPP               : num [1:3596] 1.66e+07 1.81e+08 1.52e+07 2.18e+07 8.38e+07 ...
    ##   ..$ Cost_estimate_per_year_local_currency        : num [1:3596] 1.75e+07 1.90e+08 1.60e+07 2.29e+07 8.81e+07 ...
    ##   ..$ Cost_estimate_per_year_2017_USD_exchange_rate: num [1:3596] 16.7 181.3 15.3 21.9 84.1 ...
    ##   ..$ Cost_estimate_per_year_2017_USD_PPP          : num [1:3596] 1.66e+07 1.81e+08 1.52e+07 2.18e+07 8.38e+07 ...
    ##   ..$ Currency                                     : chr [1:3596] "AUD" "AUD" "AUD" "AUD" ...
    ##   ..$ Applicable_year                              : num [1:3596] 2004 2004 2004 2004 2004 ...
    ##   ..$ Type_of_applicable_year                      : chr [1:3596] "Publication year" "Publication year" "Publication year" "Publication year" ...
    ##   ..$ Implementation                               : chr [1:3596] "Observed" "Observed" "Observed" "Observed" ...
    ##   ..$ Acquisition_method                           : chr [1:3596] "Report/Estimation" "Report/Estimation" "Report/Estimation" "Report/Estimation" ...
    ##   ..$ Impacted_sector                              : chr [1:3596] "Agriculture" "Environment" "Authorities-Stakeholders" "Agriculture" ...
    ##   ..$ Type_of_cost                                 : chr [1:3596] "Damage-Loss" "Damage-Loss" "Control" "Damage-Loss" ...
    ##   ..$ Method_reliability                           : chr [1:3596] "High" "High" "High" "High" ...
    ##   ..$ Details                                      : chr [1:3596] "Key loss is lamb predation. ABARE (2003) estimate 35 million lambs marked per year. Assumed 2% of all lambs mar"| __truncated__ "Following the methodology in Pimentel et al. (2000), the impact of fox predation on the bird population in Aust"| __truncated__ "Fox control expenditure in Tasmania of $9 million per year is also included (Tasmanian Dept. of Primary Industr"| __truncated__ "Prior to the release of RHDV : Rabbits impose annual costs on wool producers in the temperate pasture areas of "| __truncated__ ...
    ##   ..$ Contributors                                 : chr [1:3596] "C.D, C.A., L.N." "C.D, C.A., L.N." "C.D, C.A., L.N." "C.D, C.A., L.N." ...
    ##   ..$ Probable_starting_year_low_margin            : num [1:3596] 2004 2004 2000 2004 2004 ...
    ##   ..$ Probable_ending_year_low_margin              : num [1:3596] 2004 2004 2000 2004 2004 ...
    ##   ..$ Publication_lag                              : num [1:3596] 0 0 4 0 0 0 0 0 0 3 ...
    ##  $ parameters             :List of 7
    ##   ..$ cost.column          : chr "Cost_estimate_per_year_2017_USD_exchange_rate"
    ##   ..$ year.column          : chr "Impact_year"
    ##   ..$ in.millions          : logi TRUE
    ##   ..$ minimum.year         : num 1960
    ##   ..$ maximum.year         : num 2017
    ##   ..$ number.of.estimates  : int 1332
    ##   ..$ number.of.year.values: int 3596
    ##  $ year.breaks            : num [1:7] 1960 1970 1980 1990 2000 ...
    ##  $ average.total.cost     :'data.frame': 1 obs. of  7 variables:
    ##   ..$ initial_year      : num 1960
    ##   ..$ final_year        : num 2017
    ##   ..$ time_span         : int 58
    ##   ..$ total_cost        : num 1389519
    ##   ..$ annual_cost       : num 23957
    ##   ..$ number_estimates  : int 1332
    ##   ..$ number_year_values: int 3596
    ##  $ average.cost.per.period:'data.frame': 6 obs. of  7 variables:
    ##   ..$ initial_year      : num [1:6] 1960 1970 1980 1990 2000 2010
    ##   ..$ final_year        : num [1:6] 1969 1979 1989 1999 2009 ...
    ##   ..$ time_span         : int [1:6] 10 10 10 10 10 8
    ##   ..$ total_cost        : num [1:6] 276 4531 12584 204428 934111 ...
    ##   ..$ annual_cost       : num [1:6] 27.6 453.1 1258.4 20442.8 93411.1 ...
    ##   ..$ number_estimates  : int [1:6] 5 24 89 276 792 344
    ##   ..$ number_year_values: int [1:6] 32 74 260 773 1979 478
    ##  - attr(*, "class")= chr [1:2] "invacost.rawcost" "list"

Notice that the expanded database used to calculate costs has been
stored in the object, in a slot called `cost.data`. This is especially
important for reproducibility: in case you decide to publish your work,
you can provide this R object which has the exact copy of your specific
version/filters of the database.

There are also some other important elements in this object:

  - `parameters`: provides arguments you chose and basic information
    about your dataset
  - `year.breaks`: your time intervals
  - `average.total.cost`: contains cumulative and average annual costs
    for the entire time period
  - `average.cost.per.period`: contains cumulative and average annual
    costs for each time interval

You can access each element with the `$` sign; for example for the costs
for all time intervals:

``` r
raw.costs$average.cost.per.period
```

    ##   initial_year final_year time_span  total_cost annual_cost number_estimates
    ## 1         1960       1969        10    275.7575    27.57575                5
    ## 2         1970       1979        10   4531.0644   453.10644               24
    ## 3         1980       1989        10  12584.1059  1258.41059               89
    ## 4         1990       1999        10 204428.3427 20442.83427              276
    ## 5         2000       2009        10 934110.6375 93411.06375              792
    ## 6         2010       2017         8 233589.2014 29198.65018              344
    ##   number_year_values
    ## 1                 32
    ## 2                 74
    ## 3                260
    ## 4                773
    ## 5               1979
    ## 6                478

## Customising parameters

There are two main parameters to customize:

  - **beginning** (`minimum.year`) and **ending year** (`maximum.year`)
    of the entire time period. For example in our analyses for the main
    paper we chose to start at 1970, because data for the 1960s are
    scarce and uncertain.

<!-- end list -->

``` r
raw.costs2 <- calculateRawAvgCosts(db.over.time,
                                  minimum.year = 1970,
                                  maximum.year = 2017)
```

    ## Warning in calculateRawAvgCosts(db.over.time, minimum.year = 1970, maximum.year = 2017): There are 11 cost values for periods earlier than 1970, which will be removed.

    ## Warning in calculateRawAvgCosts(db.over.time, minimum.year = 1970, maximum.year = 2017): There are 1 cost values for periods later than 2017 which will be removed.

``` r
raw.costs2
```

    ## Average annual cost of invasive species over time periods
    ## 
    ## - Temporal interval of data : [1970, 2017]
    ## - Values transformed in US$ million: Yes
    ## - Number of cost estimates: 1331 (number of individual year values: 3564)
    ## - Cost values in US$ millions:
    ##     o Total cost over the entire period 1,389,243.35
    ##     o Average annual cost over the entire period 28,942.57
    ##     o Average annual cost over each period
    ## 
    ##   initial_year final_year time_span total_cost annual_cost number_estimates
    ## 1         1970       1979        10   4,531.06      453.11               24
    ## 2         1980       1989        10  12,584.11    1,258.41               89
    ## 3         1990       1999        10 204,428.34   20,442.83              276
    ## 4         2000       2009        10 934,110.64   93,411.06              792
    ## 5         2010       2017         8 233,589.20   29,198.65              344
    ##   number_year_values
    ## 1                 74
    ## 2                260
    ## 3                773
    ## 4               1979
    ## 5                478

The function tells you how many values were removed from the dataset
because they were outside the 1970-2017 time periods.

  - **time intervals**: set them with the arguments `year.breaks`, where
    you specify the starting year of each interval. For example, if your
    specify `year.breaks = c(1970, 1980, 1990, 2000, 2010, 2017)`, then
    intervals will be \[1970-1979\], \[1980-1989\], \[1990-1999\],
    \[2000-2009\], \[2010-2017\]

<!-- end list -->

``` r
# let's plot 20-year intervals
raw.costs3 <- calculateRawAvgCosts(db.over.time,
                                  minimum.year = 1960,
                                  maximum.year = 2017,
                                  year.breaks = seq(1960, 2017, by = 20))
```

    ## Warning in calculateRawAvgCosts(db.over.time, minimum.year = 1960, maximum.year = 2017, : There are 8 cost values for periods earlier than 1960, which will be removed.

    ## Warning in calculateRawAvgCosts(db.over.time, minimum.year = 1960, maximum.year = 2017, : There are 1 cost values for periods later than 2017 which will be removed.

``` r
plot(raw.costs3)
```

![](Readme_files/figure-gfm/raw4.1-1.png)<!-- -->

## Customising graphs

There are two methods to customise graphs.

  - The first one is to use the standard ggplot produced by the package
    and adding things or changing parameters. This method is easy to
    implement but you cannot change everything (e.g. adjust the
    colors/shapes of points is not possible). This is what we will see
    here. See the help here: `?plot.invacost.rawcost`

  - The second one is to make your own ggplot from the output object. It
    is more difficult to implement if you are not familiar with graphs
    in R - but it will be fully customisable. Take a look at the scripts
    from our main paper (`link to be added when available ¯\_(ツ)_/¯`) to
    see how to that.

There are two base plots provided with the package; you have already
seen the default, and here is another one:

``` r
plot(raw.costs,
     plot.type = "bars")
```

![](Readme_files/figure-gfm/raw5-1.png)<!-- -->

You can also remove the log10 scale:

``` r
plot(raw.costs,
     plot.type = "bars",
     cost.transf = NULL)
```

![](Readme_files/figure-gfm/raw5.1-1.png)<!-- -->

To customise parameters using the standard ggplot produced by the
package, you will have to set the argument `graphical.parameters =
"manual"`.

``` r
# Store the plot in object p1 to customize it afterwards
p1 <- plot(raw.costs,
           graphical.parameters = "manual")

# Show the graph in its initial state
p1
```

![](Readme_files/figure-gfm/raw5.2-1.png)<!-- -->

You see that when we specify `graphical.parameters = "manual"`, all the
cosmetic choices we made in the function are removed. You can now choose
them by yourself; here is a starting point:

``` r
# Customize p1 now
p1 <- p1 +
  xlab("Year") + 
  ylab("Average annual cost of invasions in US$ millions") +
  scale_x_continuous(breaks = raw.costs$year.breaks) + # X axis breaks
  theme_bw() + # Minimal theme
  scale_y_log10(breaks = 10^(-15:15), # y axis in log 10 with pretty labels
                labels = scales::comma) +
  annotation_logticks(sides = "l") # log10 tick marks on y axis

# Let's see how it goes
p1
```

![](Readme_files/figure-gfm/raw5.3-1.png)<!-- -->

Your turn to play with graphs now\!

# Estimate the average annual cost of invasions

The second method we provide in the package consists in estimating the
long-term trend in annual cost with different modelling techniques. In
other words, we fit a model to predict costs as a function of years.
Then, we can inspect the different models and the shapes of cost trends
over time, and grasp an idea of dynamics of invasion costs.

This approach requires more data than the raw approach and for data-poor
cases it will not work or provide inadequate results.

## Correction for data incompleteness due to publication lag

Because the average annual economic cost of invasive species will be
determined by the trend over time, we should apply a correction to
‘incomplete’ years. This correction could be based on a threshold of
incompleteness (e.g., remove from calibration all years with \< 75% of
data; threshold = 11 years). Another possibility includes weighting
incomplete years to reduce their importance in the estimation of average
annual costs of invasions. If we do not apply such a correction, we will
underestimate the average annual cost of invasions. Furthermore, many of
the economic impacts are never documented; hence, the true percentage is
likely to be much lower than the values indicated.

Applying a hard threshold such as 75% (i.e., remove last 11 years) would
result in a loss of information because we have been able to obtain
considerable amount of data for the past 11 years. Hence, we decided to
apply a hard threshold to the least-complete years (i.e. exclude years
with \< 25% completeness: the last 2 years). To reduce the negative
impact of the incompleteness of recent years, we applied weights
proportional to their degree of incompleteness; we suggest to apply the
following set of rules to our models: • completeness ≤ 25%: exclusion •
25% \< completeness ≤ 50%: weight = 0.25 • 50% \< completeness ≤ 75%:
weight = 0.50 • completeness \> 75%: weight = 1

Remember that we stored quantiles in the beginning of this tutorial, so
we can access them now to know to what years they correspond:

``` r
quantiles
```

    ## 25% 50% 75% 
    ##   2   6  11

In the next lines of code we create a vector of weights for each year,
which we will provide to the function later on.

``` r
# Creating the vector of weights
year_weights <- rep(1, length(1960:2017))
names(year_weights) <- 1960:2017

# Assigning weights
# Below 25% the weight does not matter because years will be removed
year_weights[names(year_weights) >= (2017 - quantiles["25%"])] <- 0
# Between 25 and 50%, assigning 0.25 weight
year_weights[names(year_weights) >= (2017 - quantiles["50%"]) &
               names(year_weights) < (2017 - quantiles["25%"])] <- .25
# Between 50 and 75%, assigning 0.5 weight
year_weights[names(year_weights) >= (2017 - quantiles["75%"]) &
               names(year_weights) < (2017 - quantiles["50%"])] <- .5

# Let's look at it
year_weights
```

    ## 1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 
    ## 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 
    ## 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 
    ## 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 
    ## 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 
    ## 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 1.00 0.50 0.50 
    ## 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 
    ## 0.50 0.50 0.50 0.25 0.25 0.25 0.25 0.00 0.00 0.00

## Assumptions

As we fit several models based on different techniques, we suggest to
define rules for deciding which model(s) should be finally considered.

Here are the rules we chose for our main paper: • statistical
information about the quality of the fit based on the Root Mean Square
Error (RMSE - lower is better) • simplicity: for models with similar
performance we prefer the models with less assumptions • a qualitative
rationale on the probable shape of trends over time: because of the
exponential increase in the number of invasive species globally (Seebens
et al. 2017), we expect the long-term temporal trend over time to be
either increasing or stabilising, but not decreasing. Hence, we assume
that a model describing a decreasing trend in recent years (i.e., for
years lower than the 75% completeness treshold) would indicate an effect
of the lack of data for recent years. Therefore, on the basis of this a
priori assumption, we deemed as inadequate all models that predicted a
decrease in costs after 2006.

## Models included in the ensemble modelling

There are several models included in the function. All models are
calibrated with cost data as the response variable and time as
predictive variable.

  - **linear regression** (R package `stats`)
  - **quadratic regression** (R package `stats`)
  - **multiple adaptive regression splines** (Multiple Adaptive
    Regression Splines, MARS, R package `earth`). It will fit several
    linear splines, allowing to see non-linear patterns in cost trends
    over time
  - **generalized additive models** (Generalized Additive Models, GAM, R
    package `mgcv`). The GAM model will also show non-linear patterns in
    cost trends over time.
  - **quantile regressions** (R package `quantreg`). Contrary to
    previous models, quantile regressions do not try to estimate the
    average value, they estimate a specific quantile. In the package we
    asked for quantiles 0.1 (lower boundary of costs), 0.5 (median cost
    value) and 0.9 (upper boundary of costs).

We suggest to tweak the number of parameters on GAM and MARS model and
look at how the predicted shape of costs over time change (e.g. start
from default parameters and progressively reduce it). This provides
insightful information about the short-term vs long-term variations in
costs. For an example, see our scripts for the main paper: `link to be
added when available ¯\_(ツ)_/¯`

## Model fitting

The function called `costTrendOverTime` will fit all models
automatically. If we want, we can provide several parameters such as

  - starting year (`minimum.year`): defaults to 1960
  - ending year (`maximum.year`): defaults to 2017
  - cost transformation (`cost.transf`): by default, a log10
    transformation will be applied
  - costs in millions (`in.millions`): by default, costs are transformed
    in millions so numbers are easier to read
  - threshold (`incomplete.year.threshold`) and/or weights
    (`incomplete.year.weights`) for incomplete years
  - number of parameters for GAM (dimension basis `gam.k`) and MARS
    (number of model terms `mars.nk`)
  - the function will conveniently print the annual cost value estimated
    by all models for a single year, usually the last year. You can
    change this by defining `final.year` (defaults to 2017). Do not
    worry, values are estimated for all years, this is mostly to provide
    a summary inspection in the console.

Here is an example in action:

``` r
global.trend <- costTrendOverTime(
  db.over.time, # The EXPANDED database
  minimum.year = 1970, 
  # Some years are so incomplete that we eliminate with our 25% threshold (see above)
  incomplete.year.threshold = 2017 - quantiles["25%"], 
  # For the other incomplete years we apply the vector of weights that we defined above
  incomplete.year.weights = year_weights)
```

    ## Warning in costTrendOverTime(db.over.time, minimum.year = 1970, incomplete.year.threshold = 2017 - : There are 11 cost values for periods earlier than 1970, which will will be removed.

    ## Warning in costTrendOverTime(db.over.time, minimum.year = 1970, incomplete.year.threshold = 2017 - : There are cost values for periods later than 2017: 1 different cost estimate(s).
    ## Their values later than 2017 will be removed.

    ## 3 years will not be included in model calibrations because
    ## they occurred later than incomplete.year.threshold (2015)

``` r
# Let's see the results in the console
global.trend
```

    ## Estimation of annual cost values of invasive alien species over time
    ## 
    ## - Temporal interval of data : [1970, 2017]
    ## - Temporal interval used for model calibration: [1970, 2015]
    ## - Cost transformation: log10
    ## - Values transformed in US$ million: Yes
    ## - Estimated average annual cost of invasive alien species in 2017:
    ## 
    ##    o Linear regression: US$ 
    ##      . Linear: US$ million 233,547.95
    ##      . Quadratic: US$ million 231,282.66
    ##    o Multiple Adapative Regression Splines: US$ million 7,138.29
    ##    o Generalized Additive Model: US$ million 156,296.07
    ##    o Quantile regression: 
    ##      . Quantile 0.1: US$ million 21,905.44
    ##      . Quantile 0.5: US$ million 114,627.96
    ##      . Quantile 0.9: US$ million 4,587,456.97

We can now look at the shape of each model with the `plot` function,
which once agains does ggplot2 stuff internally in invacost:

``` r
plot(global.trend)
```

![](Readme_files/figure-gfm/models2-1.png)<!-- -->

Linear and quadratic regressions are confounded (first panel), whereas
MARS and GAM models suggest non-linear patterns in cost trends over
time. Quantile regressions indicate a median (quantile 0.5) lower than
the linear regression, suggesting that most years have a
lower-than-average cost of invasions, and a few years have very high
costs.

We can access the content of the output object with

``` r
str(global.trend)
```

    ## List of 6
    ##  $ cost.data             :Classes 'tbl_df', 'tbl' and 'data.frame':  48 obs. of  4 variables:
    ##   ..$ Year       : int [1:48] 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 ...
    ##   ..$ Annual.cost: num [1:48] 757 141 142 141 141 ...
    ##   ..$ transf.cost: num [1:48] 2.88 2.15 2.15 2.15 2.15 ...
    ##   ..$ Calibration: Factor w/ 2 levels "Excluded","Included": 2 2 2 2 2 2 2 2 2 2 ...
    ##  $ parameters            :List of 9
    ##   ..$ cost.transformation      : chr "log10"
    ##   ..$ incomplete.year.threshold: Named num 2015
    ##   .. ..- attr(*, "names")= chr "25%"
    ##   ..$ in.millions              : logi TRUE
    ##   ..$ confidence.interval      : num 0.95
    ##   ..$ minimum.year             : int 1970
    ##   ..$ maximum.year             : int 2017
    ##   ..$ final.year               : num 2017
    ##   ..$ gam.k                    : num -1
    ##   ..$ mars.nk                  : num 21
    ##  $ fitted.models         :List of 5
    ##   ..$ linear   :List of 13
    ##   .. ..- attr(*, "class")= chr "lm"
    ##   ..$ quadratic:List of 13
    ##   .. ..- attr(*, "class")= chr "lm"
    ##   ..$ mars     :List of 39
    ##   .. ..- attr(*, "class")= chr "earth"
    ##   ..$ gam      :List of 46
    ##   .. ..- attr(*, "class")= chr [1:3] "gam" "glm" "lm"
    ##   ..$ quantile :List of 3
    ##  $ estimated.annual.costs:'data.frame':  336 obs. of  6 variables:
    ##   ..$ model  : Factor w/ 4 levels "Linear regression",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##   ..$ Year   : int [1:336] 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 ...
    ##   ..$ Details: Factor w/ 6 levels "Linear","Quadratic",..: 1 1 1 1 1 1 1 1 1 1 ...
    ##   ..$ fit    : num [1:336] 118 139 163 192 225 ...
    ##   ..$ lwr    : num [1:336] 59.5 71.7 86.4 104.2 125.4 ...
    ##   ..$ upr    : num [1:336] 234 268 308 353 404 ...
    ##  $ RMSE                  : num [1:7, 1:2] 0.509 0.509 0.424 0.341 0.726 ...
    ##   ..- attr(*, "dimnames")=List of 2
    ##  $ final.year.cost       : Named num [1:7] 233548 231283 7138 156296 21905 ...
    ##   ..- attr(*, "names")= chr [1:7] "linear" "quadratic" "mars" "gam" ...
    ##  - attr(*, "class")= chr [1:2] "invacost.trendcost" "list"

There are several elements in the output object:

  - `cost.data` contains total annual costs per year, upon which model
    are fitted
  - `parameters` contains the parameters used to run the function
  - `fitted.models` contains all the objects of the fitted models. You
    can access models individually from here, look at the parameters,
    etc.
  - `estimated.annual.costs` contains cost values predicted by all
    models for each year, with confidence intervals
  - `RMSE` contains the root mean square error of all models, both for
    the calibration data only and for all data points
  - `final.year.cost` is the cost value predicted by models for
    `final.year`

## How to choose between models?

We provide an example here where we rely on the different assumptions
stated above.

First, we can look at model RMSE:

``` r
global.trend$RMSE
```

    ##                      RMSE.calibration RMSE.alldata
    ## regression.linear           0.5089716    0.8017214
    ## regression.quadratic        0.5087523    0.8008463
    ## mars                        0.4242864    0.5133139
    ## gam                         0.3412085    0.6629063
    ## qt0.1                       0.7263854    0.8021184
    ## qt0.5                       0.5146481    0.7478158
    ## qt0.9                       1.1474502    1.4615649

Overall, both GAM and MARS models provide a closer fit to data points
than linear regressions. *Remember that RMSE is irrelevant for quantile
regression because it does not seek to fit the average trend.*

Hence, purely from a statistical point of view, we would tend to choose
the GAM or RMSE models. However, the GAM model predicted a reduction in
cost after 2006, followed by an uncertain increase (see confidence
interval). Likewise, the MARS model predicted a decrease after 2000. We
interpret this as an effect of data incompleteness for the later years,
because of the delay between cost occurrence and publication. Therefore,
we would suggest to either reduce the number of parameters for both MARS
and GAM models to increase the focus on the long-term trend, or to
remove the incomplete years from calibration.

**Important:** The bottom line is, some of the models we fit (MARS, GAM)
may closely fit the interannual variations in cost values, and thus will
not be suitable to the long-term trends in IAS costs over time.
Therefore, we parameterise them to avoid overfitting the data and better
illustrate the long-term trend. As a consequence, their statistical fit
(RMSE) will be lower, but more in adequacy with our objectives. I advise
you to try different settings and decide for yourself which parameters
seems best for you.

For a more detailed example, see the scripts of our main paper here:
`link to be added when available ¯\_(ツ)_/¯`.

## Customising graphs

Customising plots for the modelling approach similar to the raw cost
approach: there are two options.

  - The first one is to use the standard ggplot produced by the package
    and adding things or changing parameters. This method is easy to
    implement but you cannot change everything (e.g. adjust the
    colors/shapes of points is not possible). This is what we will see
    here. See the help here: `?plot.invacost.trendcost`

  - The second one is to make your own ggplot from the output object. It
    is more difficult to implement if you are not familiar with graphs
    in R - but it will be fully customisable. Take a look at the scripts
    from our main paper (`link to be added when available ¯\_(ツ)_/¯`) to
    see how to that.

There are two base plots provided with the package; you have already
seen the default, and here is another one where all models are on a
single facet:

``` r
plot(global.trend,
     plot.type = "single")
```

![](Readme_files/figure-gfm/models5-1.png)<!-- -->

Likewise to the raw cost approach, if you want to customise ggplot
parameters, you have to set `graphical.parameters = "manual"`.

``` r
# Store the plot in object p2 to customize it afterwards
p2 <- plot(global.trend,
           graphical.parameters = "manual")

# Show the graph in its initial state
p2
```

![](Readme_files/figure-gfm/models6-1.png)<!-- -->

Ugly isn’t it? That’s mostly because the y scale is not in log10 scale.

You can now set all parameters by yourself; here is a starting point:

``` r
# Customize p2 now
p2 <- p2 +
  xlab("Year") + 
  ylab("Average annual cost of invasions in US$ millions") +
  scale_x_continuous(breaks = raw.costs$year.breaks) + # X axis breaks
  theme_bw() + # Minimal theme
  scale_y_log10(breaks = 10^(-15:15), # y axis in log 10 with pretty labels
                labels = scales::comma) +
  annotation_logticks(sides = "l") # log10 tick marks on y axis

# Let's see how it goes
p2
```

![](Readme_files/figure-gfm/models7-1.png)<!-- -->

Tadaaam\!

# Example on a specific subset: mammals of North America

This is just an illustration to show you how to make it work on a subset
of the database. We are not going to analyse it in details.

We assume here that you have run the code on the first sections of this
tutorial: database filtering and completeness.

First, let’s inspect the geographic regions of invacost:

``` r
unique(invacost$Geographic_region)
```

    ##  [1] "Oceania-Pacific islands"                    
    ##  [2] "Europa"                                     
    ##  [3] "North America"                              
    ##  [4] "Central America"                            
    ##  [5] "Diverse/Unspecified"                        
    ##  [6] "South America"                              
    ##  [7] "Africa"                                     
    ##  [8] "Asia"                                       
    ##  [9] "Central America/Oceania-Pacific islands"    
    ## [10] "Oceania/South America"                      
    ## [11] "Africa/Asia/Europa"                         
    ## [12] "Central America/North America"              
    ## [13] "Europa/North America"                       
    ## [14] "Asia/Europa"                                
    ## [15] "Central America/South America"              
    ## [16] "Central America/North America/South America"

There seven different regions in invacost, and sometimes cost are spread
over different regions. Indeed, cost estimates in publications and
reports often correspond to data aggregated over several regions,
several taxa at the same time, several types of cost etc. Most of the
time, it is not possible to split these costs into their respective
subsets. Therefore, we have to omit them if we want to focus on a single
region. Here, we focus on North America only:

``` r
invacost.NA <- invacost[which(invacost$Geographic_region == "North America"), ]

# Number of rows
nrow(invacost.NA)
```

    ## [1] 304

We have 304 lines in the North America subset of invacost. Let’s

``` r
# Let's see the content of the Class column
unique(invacost.NA$Class)
```

    ##  [1] "Mammalia"            "Gastropoda"          "Reptilia"           
    ##  [4] "Amphibia/Reptilia"   "Aves"                "Diverse/Unspecified"
    ##  [7] "Insecta"             "Arachnida"           "Arachnida/Insecta"  
    ## [10] "Magnoliopsida"       "Liliopsida"          "Bivalvia"           
    ## [13] "Malacostraca"        "Ulvophyceae"         "Cephalaspidomorphi" 
    ## [16] "Actinopterygii"      "Liliosida"

``` r
# Subset the NA invacost database
invacost.NA.mammals <- invacost.NA[which(invacost.NA$Class == "Mammalia"), ]

# Number of rows
nrow(invacost.NA.mammals)
```

    ## [1] 63

Once again, there are studies involving multiple taxa, and here we focus
only on mammals.

There are only 63 rows in this subset, which may not be sufficient to
run the predictive approach. Let’s confirm this by starting with the raw
cost approach:

``` r
# Expand the subset
NAmammals.over.time <- expandYearlyCosts(invacost.NA.mammals,
                                         startcolumn = "Probable_starting_year_low_margin",
                                         endcolumn = "Probable_ending_year_low_margin")


raw.NAmammals <- calculateRawAvgCosts(NAmammals.over.time,
                                    minimum.year = 1970)

raw.NAmammals
```

    ## Average annual cost of invasive species over time periods
    ## 
    ## - Temporal interval of data : [1970, 2017]
    ## - Values transformed in US$ million: Yes
    ## - Number of cost estimates: 63 (number of individual year values: 139)
    ## - Cost values in US$ millions:
    ##     o Total cost over the entire period 73,561.74
    ##     o Average annual cost over the entire period 1,532.54
    ##     o Average annual cost over each period
    ## 
    ##   initial_year final_year time_span total_cost annual_cost number_estimates
    ## 1         1970       1979        10   2,296.68      229.67                2
    ## 2         1980       1989        10       <NA>        <NA>                0
    ## 3         1990       1999        10      29.45        2.95                7
    ## 4         2000       2009        10  70,751.43    7,075.14               33
    ## 5         2010       2017         8     484.19       60.52               27
    ##   number_year_values
    ## 1                  2
    ## 2                  0
    ## 3                 51
    ## 4                 53
    ## 5                 33

``` r
plot(raw.NAmammals)
```

    ## Warning: Removed 1 rows containing missing values (geom_point).

    ## Warning: Removed 1 rows containing missing values (geom_segment).

![](Readme_files/figure-gfm/example1.4-1.png)<!-- -->

Indeed, looking at the graph it would be ill-advised to calibrate models
on this subset of invacost (feel free to try it\!). We should rather
focus on the cumulative cost over time, which in our case amounts to US$
73,562 millions for the 1970-2017 time period.

# Example on many subsets: all taxons/species in the database

This is a more complex situation where we want to derive a single
estimate for all species/taxon in the database.

First, we need to inspect the taxonomic fields of the database to decide
whether we want to apply changes before running the script.

``` r
# Here we just show the first 25
unique(invacost$Species)[1:25]
```

    ##  [1] "Vulpes vulpes"                                                          
    ##  [2] "Oryctolagus cuniculus"                                                  
    ##  [3] "Canis lupus spp."                                                       
    ##  [4] "Mus musculus"                                                           
    ##  [5] "Capra hircus"                                                           
    ##  [6] "Equus caballus"                                                         
    ##  [7] "Camelus dromedarius"                                                    
    ##  [8] "Rattus rattus"                                                          
    ##  [9] "Myocastor coypus"                                                       
    ## [10] "Sus scrofa"                                                             
    ## [11] "Erythrocebus patas/Macaca mulatta"                                      
    ## [12] "Capra hircus/Sus scrofa"                                                
    ## [13] "Felis catus/Oryctolagus cuniculus/Vulpes vulpes"                        
    ## [14] "Capra hircus/Felis catus/Oryctolagus cuniculus/Sus scrofa/Vulpes vulpes"
    ## [15] "Canis lupus dingo"                                                      
    ## [16] "Felis catus"                                                            
    ## [17] "Diverse/Unspecified"                                                    
    ## [18] "Trichosurus vulpecula"                                                  
    ## [19] "Rattus norvegicus"                                                      
    ## [20] "Rattus exulans"                                                         
    ## [21] "Rattus exulans/Rattus norvegicus"                                       
    ## [22] "Rattus exulans/Rattus norvegicus/Rattus rattus"                         
    ## [23] "Mustela erminea"                                                        
    ## [24] "Mustela erminea//Trichosurus vulpecula"                                 
    ## [25] "Mus musculus/Oryctolagus cuniculus/Rattus rattus"

As you can see there are many cases where multiple species are studied
together. These cases will be difficult to implement/analyse, but we can
decide to merge some of them together. For example, rats and mouses have
often been analysed together, and we could decide to merge them in a
single group:

``` r
# First we create new columns in character format to avoid factor errors in R
invacost$sp.list <- as.character(invacost$Species)
invacost$genus.list <- as.character(invacost$Genus)

# Second, we merge Rattus and Mus together in a single group in these columns
# Species column
invacost$sp.list[which(invacost$Genus == "Rattus" | invacost$Genus == "Mus")] <- "Rattus spp./Mus spp."
invacost$sp.list[which(invacost$Species %in% c("Rattus sp./Mus sp.", 
                                               "Mus musculus/Rattus rattus",
                                               "Mus musculus/Rattus norvegicus",
                                               "Mus sp./Rattus sp."))] <- "Rattus spp./Mus spp."
# Genus column
invacost$genus.list[which(invacost$sp.list == "Rattus spp./Mus spp.")] <- "Rattus/Mus"
```

We can also do that for other taxa; here are the corrections we applied
for the main paper:

``` r
invacost$sp.list[which(invacost$Genus == "Aedes")] <- "Aedes spp."
invacost$sp.list[which(invacost$Genus == "Felis/Rattus")] <- "Felis catus/Rattus spp."
invacost$sp.list[which(invacost$Genus == "Oryctolagus/Rattus")] <- "Oryctolagus spp./Rattus spp." 
invacost$sp.list[which(invacost$Genus == "Canis")] <- "Canis lupus spp."
```

Now that our taxon group list is set up, we still need to create a
unique identifier for each taxon group, because the generic name
“Diverse/Unspecified” in many different cases and for many different
taxa. For example, we have cases where we know that the class is
*mammals*, but the species is *Diverse/Unspecified*. We do not want to
merge these cases with e.g. *plants*. So we will create a unique
identifier which integrates taxonomic data to avoid mixing together
different kingdoms/phyla/classes etc.

``` r
# Unique identifier
invacost$unique.sp.id <- do.call("paste", invacost[, c("Kingdom", "Phylum", "Class", "Family", "genus.list", "sp.list")])
```

Finally, we will write a loop that will cycle through all these unique
groups, and for each group, calculate the raw cumulative cost and
average annual cost for the 1970-2017 time period.

``` r
# First we expand the database
db.over.time <- expandYearlyCosts(invacost,
                                  startcolumn = "Probable_starting_year_low_margin",
                                  endcolumn = "Probable_ending_year_low_margin")


# Then we prepare a data.frame in which we will store our results
species.summary <- data.frame()
# We will cycle the loop through all unique identifiers
for(sp in unique(db.over.time$unique.sp.id))
{
  # We subset the database for our current species
  cur.db <- db.over.time[which(db.over.time$unique.sp.id %in% sp), ]
  
  # We apply the raw cost function
  cur.raw <- calculateRawAvgCosts(cur.db, minimum.year = 1970)
  
  
  # And from the cur.raw object we extract the specific information we are looking for
  species.summary <- rbind.data.frame(species.summary,
                                      data.frame(
                                        Kingdom = cur.db$Kingdom[1],
                                        Phylum = cur.db$Phylum[1],
                                        Class = cur.db$Class[1],
                                        Family = cur.db$Family[1],
                                        Genus = cur.db$Genus[1],
                                        Species = cur.db$sp.list[1],
                                        Average.annual.cost = cur.raw$average.total.cost$annual_cost,
                                        Cumulated.cost = cur.raw$average.total.cost$total_cost,
                                        Number.estimates = cur.raw$average.total.cost$number_estimates,
                                        Number.year.values = cur.raw$average.total.cost$number_year_values
                                      ))
}

# To make the summary dataframe nicer, we can sort by cost to have the highest groups first
species.summary <- species.summary[order(species.summary$Cumulated.cost, decreasing = TRUE), ]


# Have a look at the first groups
species.summary[1:10, ]
```

    ##                 Kingdom              Phylum               Class
    ## 66  Diverse/Unspecified Diverse/Unspecified Diverse/Unspecified
    ## 126            Animalia          Arthropoda             Insecta
    ## 101            Animalia          Arthropoda             Insecta
    ## 4              Animalia            Chordata            Mammalia
    ## 14             Animalia            Chordata            Mammalia
    ## 165            Animalia          Arthropoda   Arachnida/Insecta
    ## 113            Animalia          Arthropoda             Insecta
    ## 103            Animalia          Arthropoda             Insecta
    ## 64             Animalia            Chordata            Reptilia
    ## 17             Animalia            Chordata            Mammalia
    ##                  Family               Genus                Species
    ## 66  Diverse/Unspecified Diverse/Unspecified    Diverse/Unspecified
    ## 126           Culicidae               Aedes             Aedes spp.
    ## 101 Diverse/Unspecified Diverse/Unspecified    Diverse/Unspecified
    ## 4               Muridae                 Mus   Rattus spp./Mus spp.
    ## 14              Felidae               Felis            Felis catus
    ## 165 Diverse/Unspecified Diverse/Unspecified    Diverse/Unspecified
    ## 113     Rhinotermitidae         Coptotermes Coptotermes formosanus
    ## 103          Formicidae          Solenopsis     Solenopsis invicta
    ## 64           Colubridae               Boiga      Boiga irregularis
    ## 17  Diverse/Unspecified Diverse/Unspecified    Diverse/Unspecified
    ##     Average.annual.cost Cumulated.cost Number.estimates Number.year.values
    ## 66           16342.2223      784426.67               81                173
    ## 126           3304.6298      158622.23              208                783
    ## 101           3008.7939      144422.11               15                 25
    ## 4             1398.0965       67108.63               93                 97
    ## 14            1074.0785       51555.77               22                 33
    ## 165            547.9659       26302.36                3                  3
    ## 113            395.9017       19003.28                9                  9
    ## 103            360.4926       17303.64               21                 60
    ## 64             312.7871       15013.78               15                 15
    ## 17             288.1052       13829.05               36                 64

Of course, many lines in this table are not interesting because they
correspond to all studies covering multiple taxa. Notwithstanding, we
can see that the winners are mosquitoes with a cumulted cost of US$
158,622 millions for 1970- 2017, based on 208 cost estimates in total.

For a more detailed example, please look at the scripts we provided with
the main paper here: `link to be added when available ¯\_(ツ)_/¯`.

# Improving the package

If something is not clear, or missing, please send me a detailed
question by mail (<leroy.boris@gmail.com>). However, remember that we
need to find a good balance between generalisability and specificity:
not enough parameters and users are not happy; too many parameters and
users are lost in the function usage. Therefore, if you have a very
specific request that will not be useful to other users, do not hesitate
to duplicate the source code and adapt the function to your needs. On
the contrary, if you think of a new thing that could be beneficial to
many users, please do not hesitate and become an officiel contributor to
the package\!

# Citation

If you found the package and/or the tutorial useful, please do not
hesitate to cite the package (in addition to the data paper) as an
acknowledgement for the time spent in writing the package and this
tutoriual. Like all R packages, to know how to cite it, type:

``` r
citation("invacost")
```

    ## 
    ## To cite package 'invacost' in publications use:
    ## 
    ##   Boris Leroy, Christophe Diagne and Anne-Charlotte Vaissière, (2020).
    ##   invacost: INVACOST Database With Methods To Analyse Invasion Costs. R
    ##   package version 0.2-4.
    ## 
    ## A BibTeX entry for LaTeX users is
    ## 
    ##   @Manual{,
    ##     title = {invacost: INVACOST Database With Methods To Analyse Invasion Costs},
    ##     author = {Boris Leroy and Christophe Diagne and Anne-Charlotte Vaissière,},
    ##     year = {2020},
    ##     note = {R package version 0.2-4},
    ##   }
    ## 
    ## ATTENTION: This citation information has been auto-generated from the
    ## package DESCRIPTION file and may need manual editing, see
    ## 'help("citation")'.
