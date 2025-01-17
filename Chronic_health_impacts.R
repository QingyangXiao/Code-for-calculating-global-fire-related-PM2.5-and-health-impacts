################################################################################################################
#####                             Chronic premature moralities assessment                                  #####
#####   This code was used to estimate the chronic premature moralities attributable to the 2023           #####
#####   Canadian-fire-related PM2.5 in the U.S. and Canada.                                                #####
#####   Input: AnnualExposure_NA_Grid_PM25_FirebySource_2023_GFED.csv  The chronic exposure data in Canada #####
#####         and the U.S.                                                                                 #####
#####          Pop_2023_NA_Region_Grid.csv (Gridded total population data of the U.S. and Canada.)         #####
#####          IHME-GBD_2019_DATA-NA_AllDeath.csv (National all-cause baseline death rate from GBD.)       #####
#####   Output: The estimated chronic premature deaths of the U.S. and Canada of 2023.                     #####
################################################################################################################

#Read in exposure data
PM<-read.csv("./AnnualExposure_NA_Grid_PM25_FirebySource_2023_GFED.csv")
#Read in gridded Population
Pop<-read.csv("./Pop_2023_NA_Region_Grid.csv")
# read in baseline all-cause death rate
mortality<-read.csv("./IHME-GBD_2019_DATA-NA_AllDeath.csv")
# matching data for the premature death calculation
Pop<-merge(Pop,mortality,by=c("Country"))
dat<-merge(Pop,PM[,c("GridID","All","Fire_CAN")],by="GridID")
#calculate the relative risk of each grid according to the the exposure level
dat$RR<-dat$All/10*0.08+1
#calculate the nubmer of deaths according to the relative risk, population, and baseline death rate at grid level
dat$Death_CAfire<-dat$Pop/100000*dat$val*((dat$RR-1)/dat$RR)*dat$Fire_CAN/dat$All
#sum the number of deaths in grids belong to the same country
sum<-aggregate(dat[,c("Death_CAfire")],by=list(dat$Country),sum)
colnames(sum)<-c("Country","Death_CAfire")
write.csv(sum,"./Chronic_death_NA_Country_GFED.csv",row.names=F)
