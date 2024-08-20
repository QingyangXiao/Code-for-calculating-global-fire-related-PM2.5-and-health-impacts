Acute_health_impacts.R is used to estimate the acute premature mortalities attributable to Canadian wildfire-related PM2.5 exposure.

1. System requirements
R x64 3.5.1 and RStudio 2023.03.0 were used to create and test this code.

2. Installation guide
No additional package is needed for running this code.

3. Demo data
The demo data package (Demo_input_data_acute_ health_impacts.zip) includes data used for estimating acute premature deaths in Canada and the U.S. which attributed to PM2.5 from Canadian wildfires on the 176th day of year 2023. PM25Daily_NA_Grid_2023_176_GFED_Fire.csv contains the estimated daily concentration of PM2.5 from Canadian wildfires in Canada and the U.S. on the 176th day of year 2023 (parameter name "Pred_CAN"). Only grids meet the following criteria were selected for estimating acute health impacts: (1) grid daily mean PM2.5 concentrations exceeded 15 μg m–3 (the recommended guideline levels of the WHO) and (2) Canadian wildfires related PM2.5 accounted for at least half of the total daily PM2.5. Pop_2023_NA_Region_Grid.csv contains the gridded total population of Canada and the U.S (parameter name "Pop"). IHME-GBD_2019_DATA-NA_AllDeath.csv contains the national all-cause baseline death rate from GBD study of Canada and the U.S (parameter name "val").

4. Run the code
When running the code, please update the path, unzip the demo data package, and run the R code. The pseudocode is described below.
a) matching the acute exposure with population and baseline death rate at grid level 
b) calculate the relative risk of each grid according to the exposure level 
c) calculate the number of deaths according to the relative risk, population, and baseline death rate at grid level
d) sum the number of deaths in grids belong to the same region
The expected run time for the demo data is less than 1 minutes.

5. Output
The expected output is a csv file named "Acute_death_NA_Region_GFED.csv" that contains the impacted regions' total acute premature deaths attributable to Canadian wildfires on the 176th day of year 2023 in Canada and the U.S. The parameter "Region" indicates the impacted regions' name and the parameter "Death_CAfire" indicates the number of estimated acute premature deaths.
