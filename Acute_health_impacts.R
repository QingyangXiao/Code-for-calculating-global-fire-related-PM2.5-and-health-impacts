###############################################################################################################
#####                      Acute premature moralities assessment                                          #####
#####   This code was used to estimate the acute premature moralities attributable to exposure to         #####
#####   Canadian wildfire PM2.5 on the 176th day of year 2023 in the U.S. and Canada                      #####
#####   Input: Fire_Grid_PM_2023_176_NA_GFED.csv  The daily exposure data in the U.S. and Canada          #####
#####          Pop_2023_NA_Grid.csv gridded total population data  of U.S. and Canada                     #####
#####          IHME-GBD_2019_DATA-Global_AllDeath.csv  National all-cause baseline death rate from GBD    #####
#####   Output: The estimated acute premature deaths of U.S. and Canada on the 176th day of year 2023     #####
###############################################################################################################

#Read in exposure data
PM<-read.csv("/Fire_Grid_PM_2023_176_NA_GFED.csv")
#Read in gridded Population
Pop<-read.csv("/Pop_2023_NA_Grid.csv")
# read in baseline all-cause death rate
mortality<-read.csv("/IHME-GBD_2019_DATA-Global_AllDeath.csv",as.is=T)
mortality<-mortality[mortality$location_name %in% c("Canada","United States of America"),c("location_name","val")]

# matching data for the premature death calculation
Pop<-merge(Pop,mortality,by.x=c("Country"),by.y=c("location_name"))
Pop$val<-Pop$val/365 #estimated daily death rate
dat<-merge(Pop,PM[,c("GridID","Pred_CAN")],by="GridID")
#calculate the relative risk of each grid according to the the exposure level
dat$RR[dat$GID_0=="USA"]<-(dat$Pred_CAN[dat$GID_0=="USA"])/10*0.0098+1
dat$RR[dat$GID_0=="CAN"]<-(dat$Pred_CAN[dat$GID_0=="CAN"])/10*0.009+1
#calculate the numer of deaths according to the relative risk, population, and baseline death rate at grid level
dat$Death_CAfire<-dat$Pop/100000*dat$val*((dat$RR-1)/dat$RR)
#sum the number of deaths in grids belong to the same country
avg<-aggregate(dat[,c("Death_CAfire")],by=list(dat$Country),sum)
colnames(avg)<-c("Country","Death_CAfire")
write.csv(avg,"/Shortterm_death_NA_national_GFED.csv",row.names=F)
