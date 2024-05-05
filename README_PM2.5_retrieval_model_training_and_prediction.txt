The R code is used to train the PM2.5 retrieval model and predict surface PM2.5 concentration.

1. System requirements
R x64 3.5.1 and RStudio 2023.03.0 were used to create and test this code. This code can be run on a desktop but for better calculation efficiency, we recommend run this code on cluster.

2. Installation guide
The R packages "MASS 7.3-58.3", "DMwR 0.4.1", "randomForest 4.7.1.1", "foreach 1.5.2", and "doSNOW 1.0.20" are required to run this code. These packages could be downloaded and installed by the install.packages() command in R within 10 minutes.

3. Demo data
The two demo data packages (Demo_input_data_1_Model_training_data_2023_NA.zip and Demo_input_data_2_Data_for_prediction_2023_176_GFED_NA) includes data used for training the random forest model in North America region in 2023 (Model_training_data_2023_NA.csv) and data used to predict gridded PM2.5 concentrations on the 176th day of year 2023 in North America (Data_for_prediction_2023_176_GFED_NA.csv).

4. Run the code
When running the code, please update the path, unzip the demo data package, and run the R code. It should be noted that the model hyperparameters have been adjusted for the demo run and are not the same when running the code with Global model training dataset. The pseudocode is described below.
a) train the first layer model with the high PM2.5 event as dependent variable with data from Model_training_data_2023_NA.csv
  a.1 define the high PM2.5 event
  a.2 apply the SMOTE algorithm to adjust the imbalance of the training data
  a.3 train the first layer model
b) training the second layer model that predict the total PM2.5 concentrations
  b.1 make predictions of the first-layer model as a predictor in the second layer model
  b.2 training of the second layer model
c) training the third layer model that predict the residual in total PM2.5 concentrations
  c.1 make predictions of the second-layer model and calculate the residual in total PM2.5 concentrations
  c.2 training of the third layer model
d) making predictions with the trained model and the demo data (Data_for_prediction_2023_176_GFED_NA.csv) on the 176th day of year 2023 in North America
The expected run time is about 4h for the model training and 5min for the prediction.

5. Output
The expected output is a csv file "Pred_2023_176_GFED.csv" that contains the gridded PM2.5 predictions for the 176th day of year 2023 in North America. The parameter "pred2" is the estimated total PM2.5 predictions, and the parameters "lon" and "lat" are the longitude and latitude of the centriod of each grid.
