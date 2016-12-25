##Comparing Core inflation to medical inflation

####Loading Needed Libraries####
for (i in c('blsAPI','zoo','ggplot2','data.table','plyr')){
  if( !is.element(i, .packages(all.available = TRUE)) ) {
    install.packages(i) }
  library(i,character.only = TRUE)}

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

####Format the Data Frames####
######Classes
full.df$value <- as.numeric(full.df$value)
full.df$year  <- as.numeric(full.df$year)
full.df$seriesID <- as.factor(full.df$seriesID)
levels(full.df$seriesID) <- c("Core CPI","Medical CPI")
######Splitting DFs and getting year-by-year
med.df <- subset(full.df,seriesID=='Medical CPI' & periodName=='December',c('seriesID','year','value'))
cor.df <- subset(full.df,seriesID=='Core CPI' & periodName=='December',c('seriesID','year','value')) 
######Sorting DFs and getting year-over-year rate increases
setDT(med.df) ; setDT(cor.df)
med.df <- med.df[order(med.df$year)]
cor.df <- cor.df[order(cor.df$year)]
med.df$rate_increase <- 100*(med.df$value/shift(med.df$value,1)-1)
cor.df$rate_increase <- 100*(cor.df$value/shift(cor.df$value,1)-1)
med.df <- med.df[!is.na(med.df$rate_increase)]
cor.df <- cor.df[!is.na(cor.df$rate_increase)]

####Graph 1: Colored Medical vs. Core Inflation Over Time
plot1 <- ggplot(data=rbind(med.df,cor.df),aes(x=year,y=rate_increase,colour=seriesID)) + 
      geom_line() +
      scale_color_brewer(palette="Set1") +
      labs(title="Core and Health Services Inflation, 1960-2015",
           subtitle="Figure 1",
           x="Year (Price Level as of December)",
           y="Year-over-year Percent Change",
           caption="Source: Bureau of Labor Statistics",
           colour='Inflation Subset') +
      scale_x_continuous(breaks=c(seq(from=1960,to=2015,by=5)))

####Graph 2: Ratio over time with guardrails
######Renaming DFs and joining tables to get ratio of increases
names(med.df) <- c("seriesID","year","med_value","med_rate_increase")
names(cor.df) <- c("seriesID","year","cor_value","cor_rate_increase")
byyear.df <- join(med.df,cor.df,by="year")
byyear.df$med_cor_ratio <- byyear.df$med_rate_increase/byyear.df$cor_rate_increase
######Setting "Normal" channels
hlines <- list('avg' = mean(byyear.df$med_cor_ratio),
               'sdv' = sd(byyear.df$med_cor_ratio))
          hlines$df <- data.frame(yint = c(hlines$avg + 1.5*hlines$sd, 
                                           hlines$avg - 1.5*hlines$sd),
                                  lt="1.5 Standard Deviations")
          byyear.df$lt <- "Ratio"

                                           
######GGPlot
plot2 <- ggplot(data=byyear.df, aes(x=year,y=med_cor_ratio,linetype=lt)) +
    geom_line(color="black",show.legend=TRUE) +
    geom_hline(data=hlines$df,aes(yintercept=yint,linetype=lt),colour="darkred",alpha=0.5,show.legend=TRUE) +
    geom_hline(data=hlines$df,aes(yintercept=yint,linetype=lt),colour="darkred",alpha=0.5,show.legend=TRUE) +
    scale_x_continuous(breaks=c(seq(from=1960,to=2015,by=5))) +
    guides(linetype = guide_legend(reverse = TRUE,title=NULL)) +
    theme(legend.position = "bottom") +
    scale_linetype_manual(values=c(3,1)) + 
    labs(title="Ratio between Medical and Core Inflation, 1960-2015",
       subtitle="Figure 2",
       x="Year (Price Level as of December)",
       y="Ratio of Year-over-year Percent Change",
       caption="Source: Bureau of Labor Statistics") 
plot2

####Save off Images####
jpeg("Inflation_Figure1.jpg") ; plot1 ; dev.off()
jpeg("Inflation_FIgure2.jpg") ; plot2 ; dev.off()
