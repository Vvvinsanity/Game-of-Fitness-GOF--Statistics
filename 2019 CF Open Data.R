#load libraries
library(purrr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(readr)
library(tibble)
library(data.table)
library(stringr)
library(ggpubr)
library(ggsci)

#-------------- Episode 1 - Quest for Data --------------#

###data extraction###
#*** data was extracted from XHR content in Network using developer tools ***#
#national champions male
champoins_male='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=1&division=1'
#national champions female
champoins_female='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=1&division=2'
#US male
US_male='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=US&citizenship_display=United+States&sort=0&scaled=0&page=1'
#US female
US_female= 'https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=2&citizenship=US&citizenship_display=United+States&sort=0&scaled=0&page=1'
#CA male
CA_male='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=CA&citizenship_display=Canada&sort=0&scaled=0&page=1'
#CA female
CA_female='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=2&citizenship=CA&citizenship_display=Canada&sort=0&scaled=0&page=1'
#China male
CN_male='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=CN&citizenship_display=China&sort=0&scaled=0&page=1'
#China female
CN_female='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=2&citizenship=CN&citizenship_display=China&sort=0&scaled=0&page=1'
#KR male
KR_male='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=KR&citizenship_display=Korea%2C+Republic+of&sort=0&scaled=0&page=1'
#KR female
KR_female='https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=2&citizenship=KR&citizenship_display=Korea%2C+Republic+of&sort=0&scaled=0&page=1'
###data extraction### - end


###data wrangling###
#*** convert JSON into dataframe/tibble and extract useful columns with Athlete info, ranking and scores ***#

# - - - 1. national champions  - - - #
champ_M_raw = fromJSON(champoins_male)
champ_M = flatten(champ_M_raw$leaderboardRows)%>%type_convert()%>%unnest(scores,.drop = FALSE)%>%
  select(overallRank, overallScore, entrant.competitorName, entrant.countryOfOriginName, entrant.gender, entrant.age)%>%
  distinct(entrant.competitorName,.keep_all = TRUE)
champ_M
colnames(champ_M)=c('World Rank','Score','Name','Country','Gender','Age')

champ_F_raw = fromJSON(champoins_female)
champ_F = flatten(champ_F_raw$leaderboardRows)%>%type_convert()%>%unnest(scores,.drop = FALSE)%>%
  select(overallRank, overallScore, entrant.competitorName, entrant.countryOfOriginName, entrant.gender, entrant.age)%>%
  distinct(entrant.competitorName,.keep_all = TRUE)
head(champ_F)
colnames(champ_F)=c('World Rank','Score','Name','Country','Gender','Age')
champ_F = champ_F%>%select(-Gender)%>%mutate(Gender='F')%>%select('World Rank','Score','Name','Country','Gender','Age')

champions=bind_rows(champ_M,champ_F)
champions%>%distinct(`Country`)
summary(champions)
#optional save for visualization
#write_csv(champions,'Ep1_champions.csv')

# - - - 2. top athletes in 4 countries - - - #
#*** since there are 8 json file sources for the 4 countries, we will have 8 dataset to clean up, ***#
#*** to speed up the cleaning, we will clean the US_male dataset and create a function to automate the process ***#
#US_male dataset
cf_raw=fromJSON(US_male)
cf_raw=flatten(cf_raw$leaderboardRows)%>%type_convert()%>%unnest('scores',.drop=FALSE)
cf_tbl=as_tibble(cf_raw)
cf_open=cf_tbl[c('scores','entrant.competitorName',
                 'entrant.gender','entrant.countryOfOriginCode',
                 'entrant.age','entrant.height','entrant.weight')][1:10,]
Result=sapply(cf_tbl$scores,"[",4)[1:10]
#the event description and score evaluation info, less usefule than the details on website page#
#breakdown=sapply(cf_tbl$scores,"[",9)
#breakdown=breakdown[1:10]
#breakdown
cf_open= as_tibble(cbind(cf_open[,c('entrant.competitorName',
                                    'entrant.gender','entrant.countryOfOriginCode',
                                    'entrant.age','entrant.height','entrant.weight')],
                         do.call(rbind,Result),stringsAsFactors = FALSE))
#rename the columns
old_names=colnames(cf_open)
new_names=c('Name','Gender','Country','Age','Height','Weight','Event 1',
            'Event 2','Event 3','Event 4','Event 5')
cf_open%>%rename_at(vars(old_names),~ new_names)
#write a function to automate the cleaning process from other data sources
CF_score = function(country_gender){
  cf_raw=fromJSON(country_gender)
  cf_raw=flatten(cf_raw$leaderboardRows)%>%type_convert()%>%unnest('scores', .drop=FALSE)
  cf_tbl=as_tibble(cf_raw)
  cf_open=cf_tbl[c('scores','entrant.competitorName',
                   'entrant.gender','entrant.countryOfOriginCode',
                   'entrant.age','entrant.height','entrant.weight')][1:10,]
  Result=sapply(cf_tbl$scores,"[",4)[1:10]
  cf_open= as_tibble(cbind(cf_open[,c('entrant.competitorName',
                                      'entrant.gender','entrant.countryOfOriginCode',
                                      'entrant.age','entrant.height','entrant.weight')],
                           do.call(rbind,Result),stringsAsFactors = FALSE))
  old_names=colnames(cf_open)
  new_names=c('Name','Gender','Country','Age','Height','Weight','Event 1',
              'Event 2','Event 3','Event 4','Event 5')
  print(cf_open%>%rename_at(vars(old_names),~ new_names))
}
#get tibbles for other dataset using the function written
US_male_score = CF_score(US_male)
US_female_score = CF_score(US_female)
CA_male_score = CF_score(CA_male)
CA_female_score = CF_score(CA_female)
CN_male_score = CF_score(CN_male)
CN_female_score = CF_score(CN_female)
KR_male_score = CF_score(KR_male)
KR_female_score = CF_score(KR_female)

#further cleaning
#get gender info right
US_female_score = US_female_score%>%select(-Gender)%>%mutate(Gender='F')%>%select(Name,Gender,Country,Age,Height,Weight,'Event 1','Event 2','Event 3','Event 4','Event 5')
CA_female_score = CA_female_score%>%select(-Gender)%>%mutate(Gender='F')%>%select(Name,Gender,Country,Age,Height,Weight,'Event 1','Event 2','Event 3','Event 4','Event 5')
CN_female_score = CN_female_score%>%select(-Gender)%>%mutate(Gender='F')%>%select(Name,Gender,Country,Age,Height,Weight,'Event 1','Event 2','Event 3','Event 4','Event 5')
KR_female_score = KR_female_score%>%select(-Gender)%>%mutate(Gender='F')%>%select(Name,Gender,Country,Age,Height,Weight,'Event 1','Event 2','Event 3','Event 4','Event 5')
#combine 8 seperate dataset into one, later on we can split them if needed
CF_score_combined= bind_rows(US_male_score,US_female_score,CA_male_score,CA_female_score
                             ,CN_male_score,CN_female_score,KR_male_score,KR_female_score)
CF_score_combined[35:45,]
#optional: save the combined raw dataset
#write_csv(CF_score_combined,'CF_score_raw.csv')

#get height info right - here we will use inch instead of cm
CF_score_combined = CF_score_combined%>%mutate('Height (inch)' = as.numeric(vapply(strsplit(Height, ' '),'[',1,FUN.VALUE = character(1))))%>%
  select(-Height)%>%
  mutate(`Height (inch)` = round(ifelse(`Height (inch)`>100, `Height (inch)`/2.54,`Height (inch)`)))
#check results - the values of cm should be converted to values in inch below
CF_score_combined$`Height (inch)`[11:20]  
US_female_score$Height

#get weight info right - here we will use lb instead of kg
CF_score_combined = CF_score_combined%>%mutate('Weight_in_lb' = as.numeric(vapply(strsplit(Weight, ' '),'[',1,FUN.VALUE = character(1))))%>%
  select(-Weight)%>%
  mutate(`Weight_in_lb` = round(ifelse(`Weight_in_lb`<100, `Weight_in_lb`*2.20462,`Weight_in_lb`)))
#check results
CF_score_combined$`Weight_in_lb`[41:50]  
CN_male_score$Weight
#note that one guy incorrectly used kg instead of lb in the above checked result#

###data wrangling### - end

#-------------- Episode 1 - Quest for Data --------------# END



#-------------- Episode 2 - The Champions --------------#

#++++++++++++++++++++++++BOXPLOT+++++++++++++++++++++++++
ggboxplot(champions,x = 'Gender', y = 'Age',
          color = 'Gender', palette = c("#00AFBB","#FC4E07"),
          order = c('M','F'),
          main = 'Age of National Champoins',
          ggtheme = theme_gray()) + 
  rremove("x.grid")+
  theme(legend.position='none',
        plot.title = element_text(hjust = 0.5))
#++++++++++++++++++++++++BOXPLOT+++++++++++++++++++++++++

#++++++++++++++ world rank map - CartoDB ++++++++++++++++
#the champions' data needs to be saved in a readable format to be used in CartoDB
write_csv(champions,'Ep1_champions.csv')
https://vinny-wang.carto.com/builder/478d1e62-21ca-4f27-b7b9-bd1390b8c811/embed
#++++++++++++++ world rank map - CartoDB ++++++++++++++++

#-------------- Episode 2 - The Champions --------------# END



#-------------- Episode 3 - (Statistical) Test of Fitness --------------#

#++++++++++++++++++++++++Methodology for producing a new variable 'Total Score' for the Hypothesis Test+++++++++++++++++++++++++
#combine all events into one score
#goal: translate finish time into reps
#Event 1: AMRAP
#Event 2: 430 reps / 20min cap; rule of thumb: 10 seconds per rep
#Event 3: 180 reps / 10min cap; rule of thumb: 5 seconds per rep
#Event 4: 132 reps / 12min cap; rule of thumb: 4 seconds per rep
#Event 5: 210 reps / 20min cap; rule of thumb: 4 seconds per rep
#++++++++++++++++++++++++Methodology for producing a new variable 'Total Score' for the Hypothesis Test+++++++++++++++++++++++++

#Event 1
CF_score_combined = CF_score_combined%>%mutate(`Event 1`= as.numeric(vapply(strsplit(`Event 1`,' '),'[',1,FUN.VALUE = character(1))))
CF_score_combined
#Event 2
get_reps_2=function(x){
  rep_a= (19-as.numeric(vapply(strsplit(x,':'),'[',1,FUN.VALUE = character(1))))*60/10
  rep_b= (60-as.numeric(vapply(strsplit(x,':'),'[',2,FUN.VALUE = character(1))))/10
  rep_combined= 430+round(rep_a+rep_b)
  return(rep_combined)
}
#re-calculate event 2 by reps
copy = CF_score_combined
CF_score_combined_2a= copy%>%filter(str_detect(`Event 2`,'reps'))%>%mutate(`Event 2`= as.numeric(vapply(strsplit(`Event 2`,' '),'[',1,FUN.VALUE = character(1))))
CF_score_combined_2b= copy%>%filter(!str_detect(`Event 2`,'reps'))%>%mutate(`Event 2`= get_reps_2(`Event 2`))
copy= bind_rows(CF_score_combined_2a, CF_score_combined_2b)
copy%>%arrange(desc(`Event 2`))
#Event 3
get_reps_3=function(x){
  rep_a= (9-as.numeric(vapply(strsplit(x,':'),'[',1,FUN.VALUE = character(1))))*60/5
  rep_b= (60-as.numeric(vapply(strsplit(x,':'),'[',2,FUN.VALUE = character(1))))/5
  rep_combined= 180+round(rep_a+rep_b)
  return(rep_combined)
}
#re-calculate Event 3 by reps
CF_score_combined_3a= copy%>%filter(str_detect(`Event 3`,'reps'))%>%mutate(`Event 3`= as.numeric(vapply(strsplit(`Event 3`,' '),'[',1,FUN.VALUE = character(1))))
CF_score_combined_3b= copy%>%filter(!str_detect(`Event 3`,'reps'))%>%mutate(`Event 3`= get_reps_3(`Event 3`))
copy= bind_rows(CF_score_combined_3a, CF_score_combined_3b)
copy%>%arrange(desc(`Event 3`))
#Event 4
get_reps_4=function(x){
  rep_a= (11-as.numeric(vapply(strsplit(x,':'),'[',1,FUN.VALUE = character(1))))*60/4
  rep_b= (60-as.numeric(vapply(strsplit(x,':'),'[',2,FUN.VALUE = character(1))))/4
  rep_combined= 132+round(rep_a+rep_b)
  return(rep_combined)
}
#re-calculate Event 4 by reps
CF_score_combined_4a= copy%>%filter(str_detect(`Event 4`,'reps'))%>%mutate(`Event 4`= as.numeric(vapply(strsplit(`Event 4`,' '),'[',1,FUN.VALUE = character(1))))
CF_score_combined_4b= copy%>%filter(!str_detect(`Event 4`,'reps'))%>%mutate(`Event 4`= get_reps_4(`Event 4`))
copy= bind_rows(CF_score_combined_4a, CF_score_combined_4b)
copy%>%arrange(desc(`Event 4`))
#Event 5
get_reps_5=function(x){
  rep_a= (19-as.numeric(vapply(strsplit(x,':'),'[',1,FUN.VALUE = character(1))))*60/4
  rep_b= (60-as.numeric(vapply(strsplit(x,':'),'[',2,FUN.VALUE = character(1))))/4
  rep_combined= 210+round(rep_a+rep_b)
  return(rep_combined)
}
#re-calculate Event 5 by reps
CF_score_combined_5a= copy%>%filter(str_detect(`Event 5`,'reps'))%>%mutate(`Event 5`= as.numeric(vapply(strsplit(`Event 5`,' '),'[',1,FUN.VALUE = character(1))))
CF_score_combined_5b= copy%>%filter(!str_detect(`Event 5`,'reps'))%>%mutate(`Event 5`= get_reps_5(`Event 5`))
copy= bind_rows(CF_score_combined_5a, CF_score_combined_5b)
copy%>%arrange(desc(`Event 5`))
#optional save cleaned data for future use
#write.csv(copy,'CF_score_cleaned.csv')

#combine all events' scores into one new score for evaluation
CF_new_score = copy%>%mutate('Total_Score'= `Event 1`+`Event 2`+`Event 3`+`Event 4`+`Event 5`)%>%
                select(-c(`Event 1`,`Event 2`,`Event 3`,`Event 4`,`Event 5`))%>%arrange(desc(`Total_Score`))
CF_new_score
#optional save new score data for future use
#write.csv(CF_new_score,'CF_new_score.csv')

#*** Some visual comparison among athletes from 4 countries ***#
#++++++++++++++++++++++++BOXPLOT+++++++++++++++++++++++++
ggboxplot(CF_new_score,x = 'Country', y = 'Age',
          facet.by = 'Gender', fill = 'Country',
          color = 'Country', palette = c('blue','red','brown','green'),
          alpha = 0.2,
          order = c('US','CA','CN','KR'),
          main = 'Age Comparison of Top Athletes',
          ggtheme = theme_gray()) + 
  rremove("x.grid")+
  theme(legend.position='none',plot.title = element_text(hjust = 0.5))+
  stat_summary(fun.y=mean,shape=20, size= 3, col='yellow',geom='point')

ggboxplot(CF_new_score,x = 'Country', y = '`Weight_in_lb`',
          facet.by = 'Gender', fill = 'Country',
          color = 'Country', palette = c('blue','red','brown','green'),
          alpha = 0.2,
          order = c('US','CA','CN','KR'),
          main = 'Weight Comparison of Top Athletes',
          ggtheme = theme_gray()) + 
  rremove("x.grid")+
  theme(legend.position='none',plot.title = element_text(hjust = 0.5))+
  stat_summary(fun.y=mean,shape=20, size= 3, col='yellow',geom='point')

ggboxplot(CF_new_score,x = 'Country', y = '`Height (inch)`',
          facet.by = 'Gender', fill = 'Country',
          color = 'Country', palette = c('blue','red','brown','green'),
          alpha = 0.2,
          order = c('US','CA','CN','KR'),
          main = 'Height Comparison of Top Athletes', 
          ggtheme = theme_gray()) + 
  rremove("x.grid")+
  theme(legend.position='none',plot.title = element_text(hjust = 0.5))+
  stat_summary(fun.y=mean,shape=20, size= 3, col='yellow',geom='point')
#++++++++++++++++++++++++BOXPLOT+++++++++++++++++++++++++
###hold on - 'NA' problem###


#++++++++++++++++facet density plot for new score++++++++++++++++  
ggdensity(CF_new_score, x = "Total_Score", fill = 'Country', 
          facet.by = 'Gender', palette = "jco", 
          ggtheme = theme_light(), legend = "top",
          main = 'Distribution of (new) score by country')+
  theme(plot.title = element_text(hjust = 0.5))
#++++++++++++++++facet density plot for new score++++++++++++++++ 


#++++++++++++++++scatter plots between weight and total score ++++++++++++++++  
ggscatter(CF_new_score, x = "Weight_in_lb", y = "Total_Score",
          add = "reg.line",                        # Add regression line
          conf.int = TRUE,                         # Add confidence interval
          color = 'Country', palette = "jco",      # Color by Country 
          shape = 'Country', xlab = 'Weight', ylab = 'Total Score', # Change point shape by groups "Country"
          main = 'Correlation between weight and score')+
  theme(plot.title = element_text(hjust = 0.5))+
  stat_cor(aes(color = Country), label.x = 50)  # Add correlation coefficient
#++++++++++++++++scatter plots between weight and total score ++++++++++++++++ 
  
#subset data for hypothesis testing
newscore_M= CF_new_score%>%filter(Gender == 'M')
newscore_F= CF_new_score%>%filter(Gender == 'F')
American_M= as.matrix(newscore_M%>%filter(Country == "US" | Country == "CA")%>% select(`Total_Score`))
Asian_M= as.matrix(newscore_M%>%filter(Country == "CN" | Country == "KR")%>% select(`Total_Score`))
American_F= as.matrix(newscore_F%>%filter(Country == "US" | Country == "CA")%>% select(`Total_Score`))
Asian_F= as.matrix(newscore_F%>%filter(Country == "CN" | Country == "KR")%>% select(`Total_Score`))

#*** Non-parametric hypothesis tests ***#
# - - - 1. Wilcoxon rank sum test or Mann-Whitney test
wilcox.test(American_M,Asian_M,exact = FALSE)
wilcox.test(American_F,Asian_F,exact = FALSE)
# - - - 2. Kruskal-Wallis test to test statistical difference in total scores among 4 countries - - - #
kruskal.test(`Total_Score` ~ Country, data = newscore_M)
kruskal.test(`Total_Score` ~ Country, data = newscore_F)
# - - - 3. Multiple pairwise-comparison test between groups - - - #
pairwise.wilcox.test(newscore_M$`Total_Score`,newscore_M$Country, p.adjust.method = 'bonferroni')
pairwise.wilcox.test(newscore_F$`Total_Score`,newscore_F$Country, p.adjust.method = 'bonferroni')

#-------------- Episode 3 - (Statistical) Test of Fitness --------------# END