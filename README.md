# Game of Fitness (GOF) - Season 1 The Statistics 
---
### Table of Contents
Intro

Overview

Episode 1: Quest for data

Episode 2: The champions

Episode 3: (Statistical) Test of fitness

Outro :Seanson 2 preview

---
## Intro
Historically, the CrossFit Game has crowned top fittest men and women on earth overwhelmingly to athletes from a small nitche of countries, U.S., G.B, CA, Iceland. As the competition rules envolve and more widely spread of the sports around the globe, there seemed to be more appearance of top athletes from all other regions of the world. Through the global participation of the CrossFit Open event, top athletes from every country has a chance to compete in the glorious "CrossFit Olympic" - the CrossFit Game.

## Overview
In the first season of the GOF, I investigated data of some top CrossFit athletes in the world. The exploration of data is divided into three episodes (just like a good trilogy) unfold the hidden statistics behind the numbers. Episode 1 covers the journey of data extraction and data wrangling that sets stage for the later statistical test. Episode 2 explores some key statistics and visualizations of the cleaned data. Finally, Episode 3 discusses the methods of two hypothesis tests being conducted on the dataset to find statistical evidence   

After discovering the large gap among the global ranks of Crossfit national champions in the Open Workout competition, it leads me to think: Do the top CrossFit athletes among different continents really have difference in their performance?
In other words, are the professional CrossFitters in one large geographic region really better/worse than the ones in other regions? This question leads me to think about countries/continent that are good at other international sports (soccer, basketball, tennis, swmming, etc.) and the ones that are not so good. As a Chinese, although we are pretty good at scoring gold metals in the Olympic, I quickly think of the difference between the fame of asian sports athletes and american sports teams in other sports (Chinese basketball team vs. U.S. basketball team, for example). It would be interesting to use statistics to test whether there is a performance difference between top American and Asian CF athletes.

## Episode 1: Quest for data
With the tasking of searching for the most comprehensive data that measures verified athletic scores, our quest landed on the home of the sport's web page crossfit.com.

The website has done an excellent job in displaying the leaderboard information on workout results for registered athletes. So the CrossFit Leaderboard page is undoubtly the first choice for the official records of standard CrossFit events. These CrossFit competition scores are then used for selecting qualifying athletes to compete for the crown of "The fittest on earth". With some changes in rules and format in 2019, there are a few options of competition scores, including "Open", 'Online Qualifier", "Sanctionals" and "Games". Our quest for dat should attempt to use the most participated and comprehensive measurements that evaluate athletic performance across the world. For this purpose, the all-inclusive and most-participated "Open" events become the first choice. 
Since the data is hosted on the website as a format of interactive table. There are normally mainly two ways to extract the information. I prefer to check the XHR contents to be extracted visually before scraping for accuracy. This technique works perfectly here because the data table is actually sent to browsers in a JSON format. So it is quicker to use the JSON link to extract only the needed information with JSONlite, dplyr and other R libraries. 

For example, this [JSON url](https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=US&citizenship_display=United+States&sort=0&scaled=0&page=1) for our quest is 
```
https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=US&citizenship_display=United+States&sort=0&scaled=0&page=1
```
It is easy to compare the URL query parameters (e.g. "division=1") and make requests using the API directly.
*(Another choice of web scraping in RStudio is to use Rselenium(R). The package makes use of Selenium to simulate a browser which executes all the javascript and AJAX requests. Then you can download the parsed page source and use rvest to parse the HTML.)*

> *Here comes data wrangling...*

We have the data, and now the fun begins. There are tons of information included in the JSON: athletes' information, workout results, ranking, points, even the breakdown of the event descriptions. Since we are interested in the top athletes and their event performance, the necessary information is athletes' information and their scores. The data wrangling magic prepared two parts of data set for the rest of the study. One is solely for the data of 2019 CrossFit Open national champions and the other one is for top athletes in two continents (four countries). Details of the this preparation can be found in the R script below. Note that since the data cleaning process for the top athletes contains eight seperate dataset, I created a standardized procedure with tested functions to streamline the process. Since there are only 80 rows of data in total, the NAs can be browsed easily. Here, these missing data are only related to the athletes' physical information: such as weight, height and age. Instead of deleting observations (rows) or replacing with other values, I simply kept the NAs here because we are only concerned about the event performance rather than the physical conditions for these sets of data.
Now that all the variables in the data are obtained for further exploration and analysis, the quest for data is fullfilled. 

## Episode 2: The champions

> *Know your champions!*

Your CrossFit national champions spent hundreds of hours per month (if not more) of hard trainning to become the best of the elite athletes, it is worth to getting to know their names and share the pride! Using the scraped data of 2019 CrossFit Open national champions, I'm interested to see the spread of age of the champions. The boxplot here describes IQR (interquartile range) with outliers for each gender of the champions. There are 236 national champions (including males and females) from 123 participated countries, and the median age of both male and female champions are the same while female champions have wider range of age, from under 20 to over 45. 
*Although technically the RX age group for the competition if from 18-34, athletes from other age group could still register to compete in it.
Enough of text, the global competition deserves a world map that showcases the national champions in each country! For mapping, I always love Carto for the convenience of intergrating dataset to display geographic information. Check out the [2019 CrossFit Open Workout National Champions](https://vinny-wang.carto.com/builder/478d1e62-21ca-4f27-b7b9-bd1390b8c811/embed "Who are your national champions?") map I created with Carto.
<iframe src="https://vinny-wang.carto.com/builder/478d1e62-21ca-4f27-b7b9-bd1390b8c811/embed" width="600" height="450" frameborder="0" style="border:0" allowfullscreen></iframe>

## Episode 3: (Statistical) Test of fitness

As mentioned at the beginning, it seems that the sports performances among Crossfit atheletes in different regions of the world are quite different. To explore this, for the last part of this fitness journey, I'm interested in using the knowledge of statistics to test whether there is a difference in sports performance between top North American and Asian CrossFit athletes.

> *Setting the stage for hypothesis test*

Since we want to test the absolutely best top athletic representation in CrossFit from the two continents, we picked top two countries with the most event participants from North America and Asia:
For selecting North American athletes, it is obvious that U.S. and Canada play a lead role;
For Asian athletes, China and South Korea have seen huge numbers of the event participants in the Open workouts. 

> *Speaking statistics*

There are 4 sampling groups (4 countries) with 10 samples in each group (n=10). This means that the sample size is small (n<30) and we cannot assume normal distribution of the samples, therefore, it indicates that we will use non-parametric methods in hypothesis testing to find potential statistical evidence.

> *Here is when my years' of CF experience comes to rescue the data...*

With the scraped data from top 10 athletes in these four countries, it is still difficult to compare their performance because each athletes have 5 scores for 5 seperate events in the competition. The official CrossFit rule uses athletes' ranking as points in each event, that is, an athlete who ranks #6 will get 6 points for that event, therefore the less points the better they do overall. However, it might be misleading in our analysis and hypothesis test. So we will need to re-invent the wheel here.
To do this, I combined all 5 events in their data into a new score, represented by the total number of repititions athletes completed in all the events. The challenge is converting data of 'time' into data of 'rep' based on the event rule book and specific workouts. This transformation of data could be subjective, but based on my participation in these events and general experience, here is list of rule of thumb I followed in converting the data:
| Goal: convert event finish 'time' into 'reps' |
| ------- | -------------------------------------------------------- |
| Event 1 | unchanged |
| Event 2 | 430 reps / 20min cap; rule of thumb: 10 seconds per rep |
| Event 3 | 180 reps / 10min cap; rule of thumb: 5 seconds per rep |
| Event 4 | 132 reps / 12min cap; rule of thumb: 4 seconds per rep |
| Event 5 | 210 reps / 20min cap; rule of thumb: 4 seconds per rep |

After the conversion of scores, the data now contains 6 variables: athletes' name, age, height and weight, nationanlity, and a new score measured in total repititions. Let's take a look at the distribution of the new scores. 
```
# density plot
```
In the density plot, it appears that scores from top Korean male and female atheltes and American male athletes have roughly normal shaped distributions. The most interesting fact is from this plot is that the average sports performance (both male and female) ranks from highest to lowest in the order of U.S., Canada, Korea and China. This roughly illustrates the initial hypothesis: Top North American and Asian athletes have very different sports performance in CrossFit.

> *Hypothesis test!*

In the world of statistics, we are interested in finding statistical evidence as a way to support hypothesis. From these sets of data, we want to know if there is any significant difference between the scores of North American and Asian athletes.

We have two groups of unpaired samples with sample sizes of 20 each. Since we cannot assume that data is normally distributed based on the small sample size, Wilcoxon rank sum test (or called Mann-Whitney test) can be used. It is a non-parametric alternative to the unpaired two-samples t-test, which can be used to compare two independent groups of samples.
Two-sided Wilcoxon rank sum test:

**Null hypothesis**: There is no significant difference between scores of North American and Asian athletes.
**Alternative hypothesis**: There is a significant difference between scores of North American and Asian athletes.

**Test results**: The p-values of these tests are significant for both male and female groups, meaning that there is a significant difference between scores of North American and Asian athletes.

> *Dive deeper - more hypothesis tests!*

Our inital tests provides some statistical evidence that there is truly a difference between North American and Asian athletes in CrossFit performance in compitiions. Let's look further to see if there is any significant difference between the scores of athletes in four countries.

**Null hypothesis**: There is no significant difference between the scores of athletes in four countries.
**Alternative hypothesis**: There is a significant difference between the scores of athletes in four countries.

Since each country only has 10 samples (athletes' scores) in our data, a non-parametric method Kruskal-Wallis test will be used. Kruskal-Wallis test by rank is a non-parametric alternative to one-way ANOVA test, which extends the two-samples Wilcoxon test in the situation where there are more than two groups. It is recommended when the assumptions of one-way ANOVA test are not met.

**Test results**: with a p-value less than 0.05, we reject the null hypothesis, therefore, there is statistical evidence of a significant difference between the scores of athletes in four countries for both males and females.

From the Kruskal-Wallis test, we know that there is a significant difference between groups, but we don't know which pairs of groups are different.

It is possible to use the pairwise comparisons of Wilcoxon rank sum test to find out.

Basically, we pair up data from any two countries for all the possible combinations, and the results are really interesting:
For males' athletic performance, there is no significant difference between of U.S. and Canada or between China and Korea, while there is a significant difference between U.S. and Chinese/Korean athletes, as well as between Canadian and Chinese/Korean athletes. 
For females' athletic performance, there is no significant difference between China and Korea, while there is a significant difference between U.S. and Chinese/Korean athletes, between Canadian and Chinese/Korean athletes, as well as between U.S. and Canadian athletes.
```
test result correlation matrix...
```

## Outro :Seanson 2 preview
Contributing factors in the difference in scores: physical conditions, use it and past scores to predict future scores# Game-of-Fitness-GOF--Statistics
