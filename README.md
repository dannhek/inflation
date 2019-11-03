# Medical Inflation in Context  
## Motivation
It is often claimed that The Patient Protection and Affordable Care Act (ACA) lowered medical inflation. For evidence of this, people will often point to the fact that medical inflation is at "historic" lows:   

| Year| Percent Medical Inflation|
|----:|-----------------:|
| 2013|          2.01%|
| 2014|          2.95%|
| 2015|          2.58%|
| 2016|          4.07%|
| 2017|          1.77%|
| 2018|          2.01%|  

Compared to the early-mid 1990s, these are, indeed, low numbers. However, it is disingenuous to claim that this is the whole story. This simple repository attempts to add context to this simplistic story. Most importantly, inflation as a whole is at historic lows, therefore medical inflation being low is neither surprising nor obviously the result of the ACA.    

## Analysis  
For this analysis, I didn't do any fancy regressions; my goal is merely to put the above numbers in context. Namely, the context of the last 60 years and in context of the core CPI as a whole. To do this, I use the Bureau of Labor Statistics data on medical inflation and core inflation from 1960 through 2018 to construct two graphs. The first shows the trend of these two measures of inflation over time. The second is the actual context. What we care about is not medical inflation _per se_. We care about medical inflation in the context of prices overall. Since the 1960s and before, medical inflation has generally been between 1.5 and 2.0 times core inflation. This overall trend __has not changed__ with the ACA.  
There are three notable exceptions to this:  
1. 1980: In the wake of massive, economy-wide inflation, medical inflation was lower than core inflation. See Graph 1 for details on that context.  
2. 2011: Immediately following the passage of the ACA (I measure inflation from January to January), we see a massive spike in medical inflation relative to core inflation, which is most likely due to core CPI falling dramatically and in the wake of the Great Recession and Medical inflation either being robust to broader economic downturns or increases in prices in response to the possibility of the ACA (probably the former).   
3. 2018: Medical inflation is lower than Core CPI. Like a good economist, I will tell you tomorrow why the predictions I made yesterday didn't come true today. Still, this is a curious data point that does corroborate the hypothesis that the ACA set in motion a trend that is, ever so slowly, curbing costs. Nevertheless, many things have happened since 2010, so to say that this "good" data point from 2018 is directly attributable to the 2010 ACA is just naive.  

## Using this code
If you would like to use these images or fork this repo, please, go right ahead. I just ask that you cite me.  

__Suggested Citation__: Hekman, D. J. (2019). _Medical Inflation In Context_. (github repository) https://github.com/dannhek/inflation.git (SHA: \[Commit SHA you used\]). \[date you acessed this\].

##### Using Keyring to account for your password  
If you want to fork this repo, read this.   
The BLS API has limits on how much data you can pull per day ([see website](https://www.bls.gov/developers/api_faqs.htm)). You can substantially increase that limit by registering with them and getting a user key. User keys are free, but they are uniquely identifiable, so I don't recommend hard-coding them. Use `keyring` instead:  
```r
library(keyring)
key_set('blsAPI')
# Enter your key into prompt
# BLS documentation uses 995f4e779f204473aa565256e8afe73e as an example key, so I will too
```  
This will allow you to replace this example
```r
#Example from BLS API Website:
payload <- list(
'seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'),
    'startyear'=2010,
    'endyear'=2012,
    'registrationKey'='995f4e779f204473aa565256e8afe73e')
```  
with this example:  
```r
library(keyring)
#Example from BLS API Website:
payload <- list(
'seriesid'=c('LAUCN040010000000005','LAUCN040010000000006'),
    'startyear'=2010,
    'endyear'=2012,
    'registrationKey'=get_key('blsAPI'))
```