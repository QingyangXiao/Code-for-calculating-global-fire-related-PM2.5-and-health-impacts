################################################################################################################
#####                               Acute premature moralities assessment                                  #####
#####   This code was used to estimate the acute premature moralities attributable to the 2023             #####
#####   Canadian-fire-related PM2.5 on the 176th day of 2023 in the U.S. and Canada.                       #####
#####   Input: PM25Daily_NA_Grid_2023_176_GFED_Fire.csv (The daily mean PM2.5 exposure data on the 176th   #####
#####          day of 2023 in the U.S. and Canada.)                                                        #####
#####          Pop_2023_NA_Region_Grid.csv (Gridded total population data of the U.S. and Canada.)         #####
#####          IHME-GBD_2019_DATA-NA_AllDeath.csv (National all-cause baseline death rate from GBD.)       #####
#####   Output: The estimated acute premature deaths of the U.S. and Canada on the 176th day of 2023.      #####
################################################################################################################

#Read in exposure data
PM<-read.csv("./PM25Daily_NA_Grid_2023_176_GFED_Fire.csv")
#Read in gridded Population
Pop<-read.csv("./Pop_2023_NA_Region_Grid.csv")
# read in baseline all-cause death rate
mortality<-read.csv("./IHME-GBD_2019_DATA-NA_AllDeath.csv")
# matching data for the premature death calculation
Pop<-merge(Pop,mortality,by=c("Country"))
Pop$val<-Pop$val/365 #estimated daily death rate
dat<-merge(Pop,PM[,c("GridID","Pred_CAN")],by="GridID")
#calculate the relative risk of each grid according to the the exposure level
dat$RR<-dat$Pred_CAN/10*0.021+1
#calculate the number of deaths according to the relative risk, population, and baseline death rate at grid level
dat$Death_CAfire<-dat$Pop/100000*dat$val*((dat$RR-1)/dat$RR)
#sum the number of deaths in grids belong to the same country
sum<-aggregate(dat[,c("Death_CAfire")],by=list(dat$Region),sum)
colnames(sum)<-c("Region","Death_CAfire")
write.csv(sum,"./Acute_death_NA_Region_GFED.csv",row.names=F)