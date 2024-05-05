library(MASS)
library(DMwR)
library(randomForest)
library(foreach)
library(doSNOW)

###############################################################################################################
#####                             PM2.5 retrieval model training                                          #####
#####   This code section was used to train the PM2.5 retrieval model with data in North America in 2023  #####
#####   Input: Model_training_data_2023_NA.csv that contains model training data                          #####
#####   Output: The trained model object is saved in R workspace and will be used for PM2.5 predictions   #####
###############################################################################################################

# read in the model training data covering North America in 2023
dat<-read.csv("/Model_training_data_2023_NA.csv")
dat$PM25_idw<-dat$GFED_idw   # Train the model with GFED-based GEOS-Chem total PM2.5 simulations
dat<-subset(dat,select=-c(GFED_idw,QFED_idw,GFAS_idw)) #remove the GEOS-Chem simulations with other wildfire emission inventories

# train the first layer model with the high PM2.5 event as dependent variable 
## define the high PM2.5 event 
dat$Month<-as.numeric(format(strptime(paste0("2023-",dat$DOY),"%Y-%j"),"%m"))
dat$Year<-2023
avg<-aggregate(dat$PM25,by=list(dat$Year,dat$Month,dat$GridID),mean)
colnames(avg)<-c("Year","Month","GridID","avg_PM25")
sd<-aggregate(dat$PM25,by=list(dat$Year,dat$Month,dat$GridID),sd)
colnames(sd)<-c("Year","Month","GridID","sd_PM25")
dat2<-merge(dat,avg,by=c("Year","Month","GridID"))
dat2<-merge(dat2,sd,by=c("Year","Month","GridID"))
dat2$high<-0
dat2$high[dat2$PM25>(dat2$avg_PM25+2*dat2$sd_PM25)]<-1

#Apply SMOTE algorithm
dat2<-subset(dat2,select=-c(GridID,PM25,avg_PM25,sd_PM25))
dat2$DOW<-format(strptime(paste0(dat2$Year,"-",dat2$DOY),format = "%Y-%j"),format="%u")
dat2$DOW<-factor(dat2$DOW)
dat2$high<-factor(dat2$high)

dat2<-SMOTE(high~.,dat2,perc.over=500,perc.under=400)
prop.table(table(dat2$high))
dat2$high[dat2$Density>0]<-1  # grid-days with smoke were set as 0
print("SMOTE finished")
print(Sys.time())

# The training of the first layer PM2.5 retrieval model
dat2_obs<-dat2[!is.na(dat2$AOD),]
dat2_miss<-dat2[is.na(dat2$AOD),]

cl<-makeCluster(6, type="SOCK")
registerDoSNOW(cl)

Model_obs<- randomForest(x=subset(dat2_obs,select=-c(high)), y=dat2_obs$high, 
                         ntree=200, nodesize=4, maxnodes=150000,importance=T)

Model_miss<-randomForest(x=subset(dat2_miss,select=-c(high,AOD)), y=dat2_miss$high, 
                         ntree=200, nodesize=4, maxnodes=150000,importance=T)


# train the second layer model that predict the total PM2.5 concentrations
dat$DOW<-format(strptime(paste0(dat$Year,"-",dat$DOY),format = "%Y-%j"),format="%u")
dat$DOW<-factor(dat$DOW)
dat_obs<-dat[!is.na(dat$AOD),]

## make predictions of the first-layer model as a predictor in the second layer model
dat_obs$pred_H <- predict (Model_obs,dat_obs)
dat_obs$pred_H[dat_obs$Density>0]<-1

dat_miss<-dat[is.na(dat$AOD),]
dat_miss$pred_H <- predict (Model_miss,subset(dat_miss,select=-c(AOD)))
dat_miss$pred_H[dat_miss$Density>0]<-1

## training of the second layer model
fit.obs<- foreach(ntree = rep(20,6), .combine = combine, .packages = "randomForest") %dopar%
  randomForest(x=subset(dat_obs,select=-c(GridID,Year,PM25)),
               y=dat_obs$PM25,ntree = ntree,nodesize=4, maxnodes=150000,importance=T)

fit.miss<-foreach(ntree = rep(20,6), .combine = combine, .packages = "randomForest") %dopar%
  randomForest(x=subset(dat_miss,select=-c(GridID,Year,PM25,AOD)),
               y=dat_miss$PM25,ntree = ntree,nodesize=4, maxnodes=150000)

# training the third layer model that predict the residual in total PM2.5 concentrations
## make predictions of the second-layer model and calculate the residual in total PM2.5 concentrations
dat_obs$pred<-predict(fit.obs,dat_obs)
dat_obs$pred[dat_obs$pred<dat_obs$PM25_idw & (dat_obs$Density>0 | dat_obs$CombustionRate>0)]<-dat_obs$PM25_idw[dat_obs$pred<dat_obs$PM25_idw & (dat_obs$Density>0 | dat_obs$CombustionRate>0)]
dat_miss$pred<-predict(fit.miss,subset(dat_miss,select=-c(AOD)))
dat_miss$pred[dat_miss$pred<dat_miss$PM25_idw & (dat_miss$Density>0 | dat_miss$CombustionRate>0)]<-dat_miss$PM25_idw[dat_miss$pred<dat_miss$PM25_idw & (dat_miss$Density>0 | dat_miss$CombustionRate>0)]
dat<-rbind(dat_obs,dat_miss)
dat$diff<-dat$PM25-dat$pred
## training of the third layer model
sel1<-dat[!is.na(dat$diff) & (dat$CombustionRate>0 | dat$Density>0),]
fit1<-foreach(ntree = rep(20,6), .combine = combine, .packages = "randomForest") %dopar%
  randomForest(x=subset(sel1,select=-c(GridID,Year,diff,PM25,AOD,pred,Density,CombustionRate)),
               y=sel1$diff,ntree = ntree,nodesize=4, maxnodes=150000)

sel2<-dat[!is.na(dat$diff)& (dat$CombustionRate==0 & dat$Density==0),]
fit2<-foreach(ntree = rep(20,6), .combine = combine, .packages = "randomForest") %dopar%
  randomForest(x=subset(sel2,select=-c(GridID,Year,diff,PM25,AOD,pred,Density,CombustionRate)),
               y=sel2$diff,ntree = ntree,nodesize=4, maxnodes=150000)

stopCluster(cl)

################################################################################################################
#####                                         Making PM2.5 predictions                                    ######
#####   This code section was used to predict gridded total PM2.5 concentrations from the model trained    #####
#####   by above code section                                                                              #####
#####   Input: 1.Data_for_prediction_2023_176_GFED_NA.csv that is the dataframe with required predictors   #####
#####          on the 181th day of 2023 covering North America                                             #####
#####          2. the model object saved in this R workspace                                               #####
#####   Output: PM2_5_prediction_2023_176_GFED_NA.csv that is the total PM2.5 predictions covering         #####
#####           North America on the 181th day of 2023                                                     #####
################################################################################################################

# read in the input dataframe 
match<-read.csv("/Data_for_prediction_2023_176_GFED_NA.csv")

# making predictions
match$DOW<-factor(match$DOW,levels=c(1,2,3,4,5,6,7))
match_obs<-match[!is.na(match$AOD),]
if(nrow(match_obs)>0){
  match_obs$pred_H <- predict (Model_obs,match_obs)
  match_obs$pred_H[match_obs$Density>0]<-1
  match_obs$pred <- predict (fit.obs,match_obs)
  match_obs$pred[match_obs$pred<match_obs$PM25_idw & (match_obs$Density>0 | match_obs$CombustionRate>0)]<-match_obs$PM25_idw[match_obs$pred<match_obs$PM25_idw & (match_obs$Density>0 | match_obs$CombustionRate>0)]
} else {
  match_obs<-c()
}
match_miss<-match[is.na(match$AOD),]
match_miss$pred_H <- predict (Model_miss,subset(match_miss,select=-c(AOD)))
match_miss$pred_H[match_miss$Density>0]<-1
match_miss$pred <- predict (fit.miss,subset(match_miss,select=-c(AOD)))
match_miss$pred[match_miss$pred<match_miss$PM25_idw & (match_miss$Density>0 | match_miss$CombustionRate>0)]<-match_miss$PM25_idw[match_miss$pred<match_miss$PM25_idw & (match_miss$Density>0 | match_miss$CombustionRate>0)]
match<-rbind(match_obs,match_miss)
  
sel<-match[match$CombustionRate>0 | match$Density>0,]
if(nrow(sel)>0){
  sel$diff<-predict(fit1,subset(sel,select=-c(AOD)))
  sel$pred2<-sel$pred+sel$diff
} else {
  sel<-c()
}
sel2<-match[!(match$CombustionRate>0 | match$Density>0),]
sel2$diff<-predict(fit2,subset(sel2,select=-c(AOD)))
sel2$pred2<-sel2$pred+sel2$diff
dat<-rbind(sel[,c("GridID","pred2","lon","lat")],sel2[,c("GridID","pred2","lon","lat")])
  
write.csv(dat,paste0("/Pred_2023_176_GFED.csv"),row.names=F)
