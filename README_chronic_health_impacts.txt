Chronic_health_impacts.R is used to estimate the chronic premature moralities attributable to Canadian wildfire-related PM2.5 exposure.

1. System requirements
R x64 3.5.1 and RStudio 2023.03.0 were used to create and test this code.

2. Installation guide
The R packages "FNN 1.1.3.2" are required to run this code. This packages could be downloaded and installed by the install.packages("FNN") command in R within about 1 minute.

3. Demo data
The demo data package (Demo_input_data_chronic_ health_impacts.zip) includes data used for estimating chronic premature deaths in Canada and the U.S. in 2023 due to exposure to the 2023 Canadian wildfires. AnnualExposure_NA_Grid_PM25_FirebySource_2023_GFED.csv contains the annual average source specific PM2.5 concentration served as chronic PM2.5 exposure in Canada and the U.S. Files in folder mrbrt/ contains cause-specific exposure-response function from GBD study. IHME-GBD_2019_DATA-Global_death.csv that contains national cause- and age- specific baseline mortality from GBD study. Pop_2023_NA_Grid_byAge.csv that contains gridded age-specific population data of Canada and the U.S.

4. Run the code
When running the code, please update the path, unzip the demo data package, and run the R code. The pseudocode is described below.
loop through death causes
  loop through age groups
   a) matching the chronic exposure with population and baseline death rate of specific age group and cause at grid level 
   b) search and calculate the relative risk of each grid in the cause-specific risk file according to the exposure level 
   c) calculate the number of deaths according to the relative risk, population, proportion of Canadian fire PM2.5 in total PM2.5, and baseline death rate at grid level
   d) sum the number of deaths in grids belong to the same country
  stop loop
stop loop
The expected run time with the demo data is less than 10 minutes.

5. Output
The expected output is a csv file named "GBD_longterm_deaths_NA_national_GFED.csv" that contains the national sum chronic premature deaths attributable to Canadian wildfires of year 2023 in Canada and the U.S. The parameter "Country" indicates the country name, the parameter "Death_total" indicates the number of estimated chronic premature deaths attributed to all PM2.5, the parameter "Death_totalfire" indicates the number of estimated chronic premature deaths attributed to all fire-related PM2.5, and the parameter "Death_CAfire" indicates the number of estimated chronic premature deaths attributed to Canadian wildfire-related PM2.5.

