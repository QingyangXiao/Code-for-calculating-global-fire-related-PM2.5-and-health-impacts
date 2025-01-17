Chronic_health_impacts.R is used to estimate the chronic premature mortalities attributable to Canadian wildfire-related PM2.5 exposure.

1. System requirements
R x64 3.5.1 and RStudio 2023.03.0 were used to create and test this code.

2. Installation guide
No additional package is needed for running this code.

3. Demo data
The demo data package (Demo_input_data_chronic_ health_impacts.zip) includes data used for estimating chronic premature deaths in Canada and the U.S. which attributed to PM2.5 from Canadian wildfires on 2023. AnnualExposure_NA_Grid_PM25_FirebySource_2023_GFED.csv contains the estimated annual mean concentration of PM2.5 from all sources and Canadian wildfires in Canada and the U.S. on 2023 (parameter name "All" and "Fire_CAN"). Pop_2023_NA_Region_Grid.csv contains the gridded total population of Canada and the U.S (parameter name "Pop"). IHME-GBD_2019_DATA-NA_AllDeath.csv contains the national all-cause baseline death rate from GBD study of Canada and the U.S (parameter name "val").

4. Run the code
When running the code, please update the path, unzip the demo data package, and run the R code. The pseudocode is described below.
a) matching the chronic exposure with population and baseline death rate at grid level 
b) calculate the relative risk of each grid according to the exposure level 
c) calculate the number of deaths according to the relative risk, population, and baseline death rate at grid level
d) sum the number of deaths in grids belong to the same region
The expected run time for the demo data is less than 1 minutes.

5. Output
The expected output is a csv file named "Chronic_death_NA_Country_GFED.csv" that contains the national total chronic premature deaths attributable to Canadian wildfires on 2023 in Canada and the U.S. The parameter "Country" indicates the country name and the parameter "Death_CAfire" indicates the number of estimated chronic premature deaths.


