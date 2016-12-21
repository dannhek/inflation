##Comparing Core inflation to medical inflation


libs = c('blsAPI','zoo','ggplot2','data.table')
for (i in libs){
  if( !is.element(i, .packages(all.available = TRUE)) ) {
    install.packages(i)
  }
  library(i,character.only = TRUE)
}
# library(blsAPI)
# library(zoo)
# library(ggplot2)
# library(data.table)



####Get the Data using the BLS API####
#The BLS API can only retrieve 10 years at a time, so we need to loop
#through the decades to get it all. 
#Series 1: 'CUUR0000SA0L1E' - Core CPI
#Series 2: 'CUUR0000SAM' - Medical CPI


rm(full.df)
for(year in c(seq(from=1960, to=2010, by=10))) {
     payload=list(
          'seriesid'=c('CUUR0000SA0L1E','CUUR0000SAM'),
          'startyear'=year,
          'endyear'=year+9)
     if(exists('full.df')) {
          full.df <- rbind(full.df,blsAPI(payload,1,TRUE))
     }
     else {full.df <- blsAPI(payload,1,TRUE)}
}

full.df <- blsAPI(payload, 1,TRUE) ;full.df
full.df$value <- as.numeric(full.df$value)
full.df$year  <- as.numeric(full.df$year)

med.df <- subset(full.df,seriesID=='CUUR0000SAM' & periodName=='December',c('seriesID','year','value'))
cor.df <- subset(full.df,seriesID=='CUUR0000SA0L1E' & periodName=='December',c('seriesID','year','value')) 


setDT(med.df) ; setDT(cor.df)
med.df <- med.df[order(med.df$year)]
cor.df <- cor.df[order(cor.df$year)]
med.df$rate_increase <- med.df$value/shift(med.df$value,1)-1
cor.df$rate_increase <- cor.df$value/shift(cor.df$value,1)-1
med.df <- med.df[!is.na(med.df$rate_increase)]
cor.df <- cor.df[!is.na(cor.df$rate_increase)]

ggplot(data=rbind(med.df,cor.df),aes(x=year,y=rate_increase,colour=seriesID)) + 
      geom_line() +
      scale_color_brewer(palette="Set1")

