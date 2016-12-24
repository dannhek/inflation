##Comparing Core inflation to medical inflation


libs = c('blsAPI','zoo','ggplot2','data.table','plyr')
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


if (file.exists("fulldf.RDS")) {loadRDS("fulldf.RDS")}
if (!exists('full.df')) {
    for(year in c(seq(from=1960, to=2015, by=10))) {
         payload=list(
              'seriesid'=c('CUUR0000SA0L1E','CUUR0000SAM'),
              'startyear'=year,
              'endyear'=min(2015,year+9))
         if(exists('full.df')) {
              full.df <- rbind(full.df,blsAPI(payload,1,TRUE))
         }
         else {full.df <- blsAPI(payload,1,TRUE)}
    }
    saveRDS(full.df,"fulldf.RDS")
}

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

names(med.df) <- c("seriesID","year","med_value","med_rate_increase")
names(cor.df) <- c("seriesID","year","cor_value","cor_rate_increase")
byyear.df <- join(med.df,cor.df,by="year")
byyear.df$med_cor_ratio <- byyear.df$med_rate_increase/byyear.df$cor_rate_increase

hlines <- list('avg' = mean(byyear.df$med_cor_ratio),
               'sdv' = sd(byyear.df$med_cor_ratio))
hlines$hi <- hlines$avg + hlines$sdv
hlines$lo <- hlines$avg - hlines$sdv
ggplot(data=byyear.df, aes(x=year,y=med_cor_ratio)) +
    geom_line() +
    geom_hline(yintercept=hlines$lo,color="darkred",alpha=0.5) +
    geom_hline(yintercept=hlines$hi,color="darkred",alpha=0.5) 
