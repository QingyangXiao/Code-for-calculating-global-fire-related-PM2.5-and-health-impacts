################################################################################################################
#####                             Chronic premature moralities assessment                                  #####
#####   This code was used to estimate the chronic premature moralities attributable to the 2023           #####
#####   Canadian-fire-related PM2.5 for the chronically wildfire affected areas in the U.S. and Canada.    #####
#####   Input: PM25Annual_NA_Grid_2023_GFED_Fire.csv (The annual mean PM2.5 data for the chronically       #####
#####          wildfire affected areas in the U.S. and Canada.)                                            #####
#####          Pop_2023_NA_Region_Grid.csv (Gridded total population data of the U.S. and Canada.)         #####
#####          IHME-GBD_2019_DATA-NA_AllDeath.csv (National all-cause baseline death rate from GBD.)       #####
#####   Output: The estimated chronic premature deaths of the U.S. and Canada of 2023.                     #####
################################################################################################################

#Read in exposure data
PM<-read.csv("./PM25Annual_NA_Grid_2023_GFED_Fire.csv")
#Read in gridded Population
Pop<-read.csv("./Pop_2023_NA_Region_Grid.csv")
# read in baseline all-cause death rate
mortality<-read.csv("./IHME-GBD_2019_DATA-NA_AllDeath.csv")
# matching data for the premature death calculation
Pop<-merge(Pop,mortality,by=c("Country"))
dat<-merge(Pop,PM[,c("GridID","Pred_All","Pred_CAN")],by="GridID")
#calculate the relative risk of each grid according to the the exposure level
dat$RR<-dat$Pred_All/10*0.08+1
#calculate the nubmer of deaths according to the relative risk, population, and baseline death rate at grid level
dat$Death_CAfire<-dat$Pop/100000*dat$val*((dat$RR-1)/dat$RR)*dat$Pred_CAN/dat$Pred_All
#sum the number of deaths in grids belong to the same country
sum<-aggregate(dat[,c("Death_CAfire")],by=list(dat$Region),sum)
colnames(sum)<-c("Region","Death_CAfire")
write.csv(sum,"./Chronic_death_NA_Region_GFED.csv",row.names=F)
