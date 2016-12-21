##Comparing Core inflation to medical inflation

library(blsAPI)
library(zoo)
library(ggplot2)



####Get the Data using the BLS API####
#The BLS API can only retrieve 10 years at a time, so we need to loop
#through the decades to get it all. 
#Series 1: 'CUUR0000SA0L1E' - Core CPI
#Series 2: 'CUUR0000SAM' - Medical CPI


for(decade in c(1960,1970,1980,1990,2000,2010)) {
     payload=list(
          'seriesid'=c('CPIMEDSL'),
          'startyear'=decade,
          'endyear'=decade+10)
     if(exists('full.df')) {
          full.df <- rbind(full.df,blsAPI(payload,1,TRUE))
     }
     else {full.df <- blsAPI(payload,1,TRUE)}
}
full.df$yearmonth <- as.yearmon(paste0(full.df$year,'-',gsub('M','',full.df$period)))
full.df$value <- as.numeric((full.df$value))

med.df <- subset(full.df,seriesID=='CUUR0000SAM',c('yearmonth','value'))
cor.df <- subset(full.df,seriesID=='CUUR0000SA0L1E',c('yearmonth','value')) 

qplot(yearmonth,value,geom="line",data=full.df, colour=seriesID)
