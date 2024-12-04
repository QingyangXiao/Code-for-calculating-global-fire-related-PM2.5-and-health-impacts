###############################################################################################################
#####                      Chronic premature moralities assessment                                        #####
#####   This code was used to estimate the chronic premature moralities attributable to exposure to       #####
#####   Canadian wildfire PM2.5 in 2023 in Canada and the U.S.                                            #####
#####   Input:AnnualExposure_NA_Grid_PM25_FirebySource_2023_GFED.csv  The chronic exposure data in Canada #####
#####         and the U.S.                                                                                #####
#####         /mrbrt/ cause-specific exposure-response function from GBD study                            #####
#####         IHME-GBD_2019_DATA-Global_death.csv national cause- and age- specific baseline mortality    #####                                             #####
#####         Pop_2023_NA_Grid_byAge.csv  gridded age-specific population data  of U.S. and Canada        #####
#####   Output: The estimated chronic premature deaths of Canada and the U.S. of year 2023                #####
###############################################################################################################

library(FNN)
#Read in exposure data
unzip("/data/Demo_input_data_chronic_health_impacts.zip")
PM<-read.csv("/data/AnnualExposure_NA_Grid_PM25_FirebySource_2023_GFED.csv")
#directory of the exposure-response function MR-BRT spline from GBD
risk_dir<-"/data/mrbrt/"
#read in national cause-specific baseline mortality
mortality<-read.csv("/data/IHME-GBD_2019_DATA-Global_death.csv",as.is=T)
mortality<-mortality[mortality$location_name %in% c("Canada","United States of America"),c("location_name","age_id","cause_name","val")]
mortality<-mortality[mortality$cause_name %in% c("Stroke","Ischemic heart disease"),]
mortality$cause_name[mortality$cause_name=="Stroke"]<-"cvd_stroke"
mortality$cause_name[mortality$cause_name=="Ischemic heart disease"]<-"cvd_ihd"
# read in population data
Pop<-read.csv("/data/Pop_2023_NA_Grid_byAge.csv")
Pop<-Pop[Pop$age_group_id %in% c(10:20,30,31,32,235),]

age1<-c(10:20,30,31,32,235)
age2<-c("25 to 29","30 to 34","35 to 39","40 to 44","45 to 49","50 to 54","55 to 59","60 to 64","65 to 69",
        "70 to 74","75 to 79","80 to 84","85 to 89","90-94","95 plus")
all<-c()
for(d in c("cvd_ihd","cvd_stroke")){
  for(g in c(1:15)){
    risk<-read.csv(paste0(risk_dir,d,"_",substr(age2[g],1,2),"_filled2.csv"))
    risk<-risk[!is.na(risk$exposure_spline),]
    #a) matching the chronic exposure with population and baseline death rate of specific age group and cause at grid level 
    Pop_sel<-Pop[Pop$age_group_id==age1[g],]
    Pop_sel<-merge(Pop_sel,mortality[mortality$cause_name==d,],by.x=c("Country","age_group_id"),by.y=c("location_name","age_id"))
    Pop_PM<-merge(Pop_sel,PM[,c("GridID","All","Fire","CE","CW")],by="GridID")
    #b) search and calculate the relative risk of each grid in the cause-specific risk file according to the the exposure level
    match<-get.knnx(risk$exposure_spline,Pop_PM$All,k=1)
    Pop_PM$risk_total<-risk$mean[match$nn.index]
    risk_TMREL<-risk[risk$exposure_spline==4.1,"mean"]
    Pop_PM$RR_total<-Pop_PM$risk_total/risk_TMREL
    Pop_PM$RR_total[Pop_PM$RR_total<1]<-1
    #c) calculate the number of deaths according to the relative risk, population, proportion of Canadian fire PM2.5 in total PM2.5, and baseline death rate at grid level
    Pop_PM$Death_total<-Pop_PM$Pop2/100000*Pop_PM$val*((Pop_PM$RR_total-1)/Pop_PM$RR_total)
    Pop_PM$Death_totalfire<-Pop_PM$Death_total*Pop_PM$Fire/Pop_PM$All
    Pop_PM$Death_CAfire<-Pop_PM$Death_total*(Pop_PM$CE+Pop_PM$CW)/Pop_PM$All
    #d)sum the number of deaths in grids belong to the same country
    sum<-aggregate(Pop_PM[,c("Death_total","Death_totalfire","Death_CAfire")],
                   by=list(Pop_PM$Country,Pop_PM$age_group_id,Pop_PM$age_group_name,Pop_PM$cause_name),sum)
    colnames(sum)<-c("Country","age_group_id","age_group_name","cause_name","Total_Death","Death_totalfire","Death_CAfire")
    all<-rbind(all,sum)
    print(g)
  }
} 

Pop<-read.csv("/data/Pop_2023_NA_Grid_byAge.csv")
mortality<-read.csv("/data/IHME-GBD_2019_DATA-Global_death.csv",as.is=T)
mortality<-mortality[mortality$location_name %in% c("Canada","United States of America"),c("location_name","age_id","cause_name","val")]
mortality$cause_name[mortality$cause_name=="Chronic obstructive pulmonary disease"]<-"resp_copd"
mortality$cause_name[mortality$cause_name=="Diabetes mellitus type 2"]<-"t2_dm"
mortality$cause_name[mortality$cause_name=="Tracheal, bronchus, and lung cancer"]<-"neo_lung"
mortality$cause_name[mortality$cause_name=="Lower respiratory infections"]<-"lri"
mortality<-mortality[mortality$cause_name %in% c("resp_copd","t2_dm","neo_lung","lri"),]

for(d in c("resp_copd","t2_dm","neo_lung","lri")){
  risk<-read.csv(paste0(risk_dir,d,"_filled2.csv"))
  risk<-risk[!is.na(risk$exposure_spline),]
  if(d=="lri") {age_sel<-c(28,5,10:20,30:32,235)}
  else {age_sel<-c(10:20,30:32,235)}
  for(g in age_sel){
    #a) matching the chronic exposure with population and baseline death rate of specific age group and cause at grid level 
    Pop_sel<-Pop[Pop$age_group_id==g,]
    Pop_sel<-merge(Pop_sel,mortality[mortality$cause_name==d,],by.x=c("Country","age_group_id"),by.y=c("location_name","age_id"))
    Pop_PM<-merge(Pop_sel,PM[,c("GridID","All","Fire","CE","CW")],by="GridID")
    #b) search and calculate the relative risk of each grid in the cause-specific risk file according to the the exposure level
    match<-get.knnx(risk$exposure_spline,Pop_PM$All,k=1)
    Pop_PM$risk_total<-risk$mean[match$nn.index]
    risk_TMREL<-risk[risk$exposure_spline==4.1,"mean"]
    Pop_PM$RR_total<-Pop_PM$risk_total/risk_TMREL
    Pop_PM$RR_total[Pop_PM$RR_total<1]<-1
    #c) calculate the number of deaths according to the relative risk, population, proportion of Canadian fire PM2.5 in total PM2.5, and baseline death rate at grid level
    Pop_PM$Death_total<-Pop_PM$Pop2/100000*Pop_PM$val*((Pop_PM$RR_total-1)/Pop_PM$RR_total)
    Pop_PM$Death_totalfire<-Pop_PM$Death_total*Pop_PM$Fire/Pop_PM$All
    Pop_PM$Death_CAfire<-Pop_PM$Death_total*(Pop_PM$CE+Pop_PM$CW)/Pop_PM$All
    #d)sum the number of deaths in grids belong to the same country
    sum<-aggregate(Pop_PM[,c("Death_total","Death_totalfire","Death_CAfire")],
                   by=list(Pop_PM$Country,Pop_PM$age_group_id,Pop_PM$age_group_name,Pop_PM$cause_name),sum)
    colnames(sum)<-c("Country","age_group_id","age_group_name","cause_name","Total_Death","Death_totalfire","Death_CAfire")
    all<-rbind(all,sum)
    print(g)
  }
}
avg<-aggregate(all[,c("Total_Death","Death_totalfire","Death_CAfire")],by=list(all$Country),sum)
colnames(avg)<-c("Country","Death_total","Death_totalfire","Death_CAfire")
write.csv(avg,"/result/GBD_longterm_deaths_NA_national_GFED.csv",row.names=F)