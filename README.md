# Game of Fitness (GOF) - The Statistics 

---
Historically, the CrossFit Game has crowned top fittest men and women on earth overwhelmingly to athletes from a small niche of countries, U.S., G.B, CA, Iceland. As the competition rules evolve and more widely spread of the sports around the globe, there seemed to be more appearance of top athletes from all other regions of the world. Through the global participation of the CrossFit Open event, top athletes from every country has a chance to compete in the glorious "CrossFit Olympic" - the CrossFit Game.

---



## Table of Contents

[Overview](#overview)

[Episode 1: Quest for data](#ep1)

[Episode 2: The champions](#ep2)

[Episode 3: (Statistical) Test of fitness](#ep3)

[Final Words](#outro)


## Overview <a name="overview"></a>
In this GOF statistical test, I investigated data of some top CrossFit athletes in the world. The exploration of data is divided into three episodes (just like a good trilogy) unfold the hidden statistics behind the numbers. Episode 1 covers the journey of data extraction and data wrangling that sets stage for the later statistical test. Episode 2 explores some key statistics and visualizations of the cleaned data. Finally, Episode 3 discusses the methods of two hypothesis tests being conducted on the dataset to find statistical evidence   

After discovering the large gap among the global ranks of Crossfit national champions in the Open Workout competition, it leads me to think: Do the top CrossFit athletes among different continents really have difference in their performance?
In other words, are the professional CrossFitters in one large geographic region better/worse than the ones in other regions? It is obvious that some countries/continent are good at certain sports and not so good at others, for example, the U.S. basketball team has always been number one in the world while team China has been dominating the world's ping pong game. Given that cultural influence and popularity of different sports are definitely contributing factors that allow different countries to prevail in certain sports, it would be interesting to see if competative Crossfitters in one country or continent can truly seprerate their performance from others under the test of statistics.

## Episode 1: Quest for data <a name="ep1"></a>
With the tasking of searching for the most comprehensive data that measures verified athletic scores, our quest landed on the home of the sport's web page crossfit.com.

The website has done an excellent job in displaying the leaderboard information on workout results for registered athletes. The CrossFit Leaderboard page is undoubtedly the first choice for the official records of standard CrossFit events. These CrossFit competition scores are then used for selecting qualifying athletes to compete for the crown of "The fittest on earth". With some changes in rules and format in 2019, there are a few options of competition scores, including "Open", 'Online Qualifier", "Sanctionals" and "Games". Our quest for data should attempt to use the most participated and comprehensive measurements that evaluate athletic performance across the world. For this purpose, the all-inclusive and most-participated "Open" events become the first choice. 
Since the data is hosted on the website as a format of interactive table. There are normally mainly two ways to extract the information. I prefer to check the XHR contents to be extracted visually before scraping for accuracy. This technique works perfectly here because the data table is sent to browsers in a JSON format, and it is quicker to use the JSON link to extract only the needed information with JSONlite, dplyr and other R libraries. 

For example, this [JSON url](https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=US&citizenship_display=United+States&sort=0&scaled=0&page=1) for our quest is 
```
https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&citizenship=US&citizenship_display=United+States&sort=0&scaled=0&page=1
```
It is easy to compare the URL query parameters (e.g. "division=1") and make requests using the API directly.
*(Another choice of web scraping in RStudio is to use Rselenium(R). The package makes use of Selenium to simulate a browser which executes all the javascript and AJAX requests. Then you can download the parsed page source and use rvest to parse the HTML.)*

### ***"Here comes data wrangling..."***

We have the data, and now the fun begins. There are tons of information included in the JSON: athletes' information, workout results, ranking, points, even the breakdown of the event descriptions. Since we are interested in the top athletes and their event performance, the necessary information is athletes' information and their scores. The data wrangling magic prepared two parts of data set for the rest of the study. One is solely for the data of 2019 CrossFit Open national champions and the other one is for top athletes in two continents (four countries). Details of this preparation can be found in the R script below. Note that since the data cleaning process for the top athletes contains eight separate dataset, I created a standardized procedure with tested functions to streamline the process. Since there are only 80 rows of data in total, the NAs can be browsed easily. Here, these missing data are only related to the athletes' physical information: such as weight, height and age. Instead of deleting observations (rows) or replacing with other values, I simply kept the NAs here because we are only concerned about the event performance rather than the physical conditions for these sets of data.
Now that all the variables in the data are obtained for further exploration and analysis, the quest for data is fulfilled. 

## Episode 2: The champions <a name="ep2"></a>

### ***"Know your champions!"***

Your CrossFit national champions spent hundreds of hours per month (if not more) of hard training to become the best of the elite athletes, it is worth to getting to know their names and share the pride! Using the scraped data of 2019 CrossFit Open national champions, I'm interested to see the spread of age of the champions. The boxplot here describes IQR (interquartile range) with outliers for each gender of the champions. There are 236 national champions (including males and females) from 123 participated countries, and the median age of both male and female champions are the same while female champions have wider range of age, from under 20 to over 45. *Although technically the RX age group for the competition if from 18-34, athletes from other age group could still register to compete in it.*
![age comparison - champions](https://github.com/Vvvinsanity/Game-of-Fitness-GOF--Statistics/blob/master/Age%20of%20champions.png)

It might be easier to find country on a world map, and yes, the global competition deserves a world map that showcases the national champions in each country! For mapping, I always love Carto for the convenience of integrating dataset to display geographic information. Check out the [2019 CrossFit Open Workout National Champions](https://vvvinsanity.carto.com/builder/1e298e8c-2c90-4e69-8662-259758cdb75f/embed "Who are your national champions?") map I created with Carto.


## Episode 3: (Statistical) Test of fitness <a name="ep3"></a>

As mentioned at the beginning, it seems that the sports performances among Crossfit athletes in different regions of the world are quite different. To explore this, for the last part of this fitness journey, I'm interested in using the knowledge of statistics to test whether there is a difference in sports performance between top North American and Asian CrossFit athletes.

### ***"Sampling"***

Since we want to test the best top athletic representation in CrossFit from the two continents, we picked top two countries with the most event participants from North America and Asia:
For selecting North American athletes, it is obvious that U.S. and Canada play a lead role;
For Asian athletes, China and South Korea have seen huge numbers of the event participants in the Open workouts. 

There are 4 sampling groups (4 countries) with 10 samples in each group (n=10). This means that the sample size is small (n<30) and we cannot assume normal distribution of the samples, therefore, it indicates that we will use non-parametric methods in hypothesis testing to find potential statistical evidence.

### ***"Cooking new data..."***

With the scraped data from top 10 athletes in these four countries, it is still difficult to compare their performance because each athlete has 5 scores for 5 separate events in the competition. The official CrossFit rule uses athletes' ranking as points in each event, that is, an athlete who ranks #6 will get 6 points for that event, therefore the less points the better they do overall. However, it might be misleading in our analysis and hypothesis test. We might need to re-invent the wheel here.
To do this, I combined all 5 events in their data into a new score, represented by the total number of repetitions athletes completed in all the events. The challenge is converting data of 'time' into data of 'rep' based on the event rule book and specific workouts. This transformation of data could be subjective, but based on my participation in these events and general experience, here is list of rules of thumb I followed in converting the data:

*The goal is to convert event finish 'time' into 'reps' for athletes who finished the time-capped workout with score of time instead of reps* 

| Event  |  Workout Cap | Conversion Rule of Thumb |
| ------- | ----------- | ------------------------------------------- |
| Event 1 | AMRAP (as many reps as possible) | Unchanged |
| Event 2 | 430 reps / 20min cap | 430 reps + 1 rep per 10 seconds before time cap |
| Event 3 | 180 reps / 10min cap | 180 reps + 1 rep per 5 seconds before time cap |
| Event 4 | 132 reps / 12min cap | 132 reps + 1 rep per 4 seconds before time cap |
| Event 5 | 210 reps / 20min cap | 210 reps + 1 rep per 4 seconds before time cap |


After the conversion of scores, the data now contains 6 variables: athletes' name, age, height and weight, nationality, and a new score measured in total repetitions. Let's take a look at the distribution of the new scores.

```
> CF_new_score%>%print(n=80)
# A tibble: 80 x 7
   Name                 Gender Country   Age `Height (inch)` Weight_in_lb Total_Score
   <chr>                <chr>  <chr>   <dbl>           <dbl>        <dbl>       <dbl>
 1 Mathew Fraser        M      US         29              67          195        1646
 2 Jacob Heppner        M      US         29              68          192        1616
 3 Jean-Simon Roy-Lema~ M      CA         25              69          195        1607
 4 Richard Froning Jr.  M      US         31              69          198        1603
 5 George Sterner       M      US         20              69          185        1591
 6 Cole Sager           M      US         28              70          202        1588
 7 Patrick Vellner      M      CA         29              71          195        1584
 8 Scott Panchik        M      US         31              69          187        1583
 9 Zachery Buntin       M      US         25              72          205        1583
10 Travis Mayer         M      US         28              71          198        1582
11 Jason Carroll        M      US         30              70          185        1581
12 Samuel Cournoyer     M      CA         23              71          195        1579
13 Alex Vigneault       M      CA         27              71          208        1575
14 Richard Paul Castil~ M      US         29              71          200        1572
15 Jeffrey Adler        M      CA         25              69          197        1569
16 Karissa Pearce       F      US         30              63          139        1568
17 Brooke Wells         F      US         24              66          150        1558
18 Paul Tremblay        M      CA         32              70          200        1554
19 Dani Speegle         F      US         25              66          168        1550
20 Amanda Barnhart      F      US         27              67          155        1549
21 Tyler Lee            M      CA         29              70          195        1546
22 Josh Gervais         M      CA         27              70          190        1538
23 Carol-Ann Reason-Th~ F      CA         31              65          145        1536
24 Alexandre Caron      M      CA         23              71          200        1534
25 Kyle Cant            M      CA         30              68          175        1534
26 McKenzie Flinchum    F      US         27              65          147        1528
27 Mekenzie Riley       F      US         31              64          155        1523
28 Danielle Brandon     F      US         23              67          150        1521
29 Brooke Haas          F      US         30              63          152        1519
30 Carolyne Prevost     F      CA         29              63          144        1517
31 Ant Haynes           M      CN         29              70          194        1512
32 JiMoo Son            M      KR         28              67          174        1506
33 Alexis Johnson       F      US         28              62          140        1496
34 Chantelle Loehner    F      US         27              66          145        1474
35 Sunjae Han           M      KR         31              68          182        1466
36 Seokbeom Kim         M      KR         26              69          175        1462
37 Chloe Gauvin-David   F      CA         27              67          146        1454
38 Jihong Park          M      KR         27              NA           NA        1452
39 Amy Morton           F      CA         31              64          154        1450
40 Jaedeok Kim          M      KR         26              69          180        1436
41 ZhenHua Zhou         M      CN         25              NA          161        1430
42 Kim Jae Hong         M      KR         26              73          196        1422
43 Marie-Pier Bonneau   F      CA         19              64          130        1421
44 Leigha Dean          F      CA         27              63          137        1420
45 Kang Kyungsun        M      KR         27              70          198        1419
46 Hyeokjae Yang        M      KR         34              68          163        1411
47 Hyeongjae PARK       M      KR         36              70          196        1408
48 Ashley Werner        F      CA         32              63          145        1405
49 Yu-sen Zhu           M      CN         22              NA           NA        1404
50 Karine Shrum         F      CA         30              68          152        1399
51 Kaitlyn Anapolsky    F      CA         28              63          150        1397
52 Sandra Hamilton      F      CA         30              65          158        1374
53 Min Jong Baek        M      KR         32              70          195        1370
54 Chen Sheng           M      CN         22              67          165        1309
55 Hongda Jin           M      CN         24              70          179        1307
56 Chia Le Liao         M      CN         23              67          150        1300
57 Jung Dawon           F      KR         24              67          143        1276
58 Jianchen Luo         M      CN         26              69          165        1275
59 Sikai Xiao           M      CN         22              70          192        1274
60 Haoqin Ma            M      CN         27              72          200        1263
61 Cai Cheng            M      CN         30              66          176        1260
62 Bityeoul Hwang       F      KR         24              64          123        1250
63 Heidi Choi           F      KR         33              64          128        1235
64 Seung-a Woo          F      KR         20              62          126        1211
65 Tsai-Jui Hung        F      CN         26              64          139        1202
66 Aichan Chen          F      CN         30              NA           NA        1182
67 Kay Isabell Wolfe    F      CN         25              NA           NA        1181
68 Choi Mi-Jung         F      KR         30              66          125        1176
69 Gyeong Hae Shin      F      KR         26              63          140        1169
70 Seungyeon Choi       F      KR         20              NA           NA        1153
71 Yang Hyeonhye        F      KR         25              61          118        1139
72 Jiyoon Lee           F      KR         26              65          119        1120
73 Wang Xuanlin         F      CN         24              NA           NA        1078
74 Tina Pang            F      CN         22              NA           NA        1065
75 Carmen Fung          F      CN         37              62          123        1033
76 유정 Jeong           F      KR         28              NA           NA        1026
77 Rikki Yuan           F      CN         32              66           NA         971
78 Yiqun Ning           F      CN         34              64          127         970
79 Wen Huang            F      CN         28              64          145         943
80 Danna Li             F      CN         26              NA           NA         936
```

The density plot below allows us to see how the new total scores distributed. It appears that scores from top Korean male and female athletes and American male athletes have roughly normal shaped distributions. The most interesting fact is from this plot is that the average sports performance (both male and female) ranks from highest to lowest in the order of U.S., Canada, Korea and China. This roughly illustrates the initial hypothesis: Top North American and Asian athletes have very different sports performance in CrossFit.

![distribution of scores](https://github.com/Vvvinsanity/Game-of-Fitness-GOF--Statistics/blob/master/new%20score%20distribution.png)


### ***"Hypothesis tests"***
> ***Wilcoxon rank sum test***

In the universe of statistics, we are interested in finding statistical evidence to support hypothesis. From these sets of data, we want to know if there is any significant difference between the scores of North American and Asian athletes.

We have two groups of unpaired samples with sample sizes of 20 each. Since we cannot assume that data is normally distributed based on the small sample size, Wilcoxon rank sum test (or called Mann-Whitney test) can be used. It is a non-parametric alternative to the unpaired two-samples t-test, which can be used to compare two independent groups of samples. The result of the p-values in the test determine whether there is significant statistical evidence against the null hypothesis (the critical value a=0.05). 

**Null hypothesis**: There is no significant difference between scores of North American and Asian athletes.

**Alternative hypothesis**: There is a significant difference between scores of North American and Asian athletes.

**Test results**: The p-values of these tests are significant (<0.05) for both male and female groups, meaning that there is a significant difference between scores of North American and Asian athletes.

```
> wilcox.test(American_M,Asian_M,exact = FALSE)

	Wilcoxon rank sum test with continuity correction

data:  American_M and Asian_M
W = 400, p-value = 6.776e-08
alternative hypothesis: true location shift is not equal to 0

> wilcox.test(American_F,Asian_F,exact = FALSE)

	Wilcoxon rank sum test with continuity correction

data:  American_F and Asian_F
W = 400, p-value = 6.796e-08
alternative hypothesis: true location shift is not equal to 0
```

### ***"Dive deeper - more hypothesis tests"***
> ***Kruskal-Wallis rank sum test***

> ***Pairwise comparisons using Wilcoxon rank sum test***

Our initial tests provides some statistical evidence that there is truly a difference between North American and Asian athletes in CrossFit performance in competitions. Let's look further to see if there is any significant difference between the scores of athletes in four countries.

**Null hypothesis**: There is no significant difference between the scores of athletes in four countries.

**Alternative hypothesis**: There is a significant difference between the scores of athletes in four countries.

Since each country only has 10 samples (athletes' scores) in our data, a non-parametric method Kruskal-Wallis test will be used. Kruskal-Wallis test by rank is a non-parametric alternative to one-way ANOVA test, which extends the two-samples Wilcoxon test in the situation where there are more than two groups. It is recommended when the assumptions of one-way ANOVA test are not met.

**Test results**: with a p-value less than 0.05, we reject the null hypothesis, therefore, there is statistical evidence of a significant difference between the scores of athletes in four countries for both males and females.

```
> kruskal.test(`Total_Score` ~ Country, data = newscore_M)

	Kruskal-Wallis rank sum test

data:  Total_Score by Country
Kruskal-Wallis chi-squared = 32.759, df = 3, p-value = 3.621e-07

> kruskal.test(`Total_Score` ~ Country, data = newscore_F)

	Kruskal-Wallis rank sum test

data:  Total_Score by Country
Kruskal-Wallis chi-squared = 33.08, df = 3, p-value = 3.097e-07
```

From the Kruskal-Wallis test, we are informed that there is a significant difference between groups, but we don't know which pairs of groups are different.

It is possible to use the pairwise comparisons of Wilcoxon rank sum test to find out. **Basically, we pair up data from any two countries for all the possible combinations, and the test returns the lower triangle of the matrix that contains the p-values of the
pairwise comparisons. **

```
> pairwise.wilcox.test(newscore_M$`Total_Score`,newscore_M$Country, p.adjust.method = 'bonferroni')

	Pairwise comparisons using Wilcoxon rank sum test 

data:  newscore_M$Total_Score and newscore_M$Country 

   CA     CN     KR    
CN 0.0011 -      -     
KR 0.0011 0.0536 -     
US 0.0543 0.0011 0.0011

P value adjustment method: bonferroni 

> pairwise.wilcox.test(newscore_F$`Total_Score`,newscore_F$Country, p.adjust.method = 'bonferroni')

	Pairwise comparisons using Wilcoxon rank sum test 

data:  newscore_F$Total_Score and newscore_F$Country 

   CA      CN      KR     
CN 6.5e-05 -       -      
KR 6.5e-05 0.1728  -      
US 0.0044  6.5e-05 6.5e-05

P value adjustment method: bonferroni 
```
By checking the lower triangle of the p-values matrix in these tests, it informs some interesting results: for males' athletic performance, there is no significant difference between of U.S. and Canada or between China and Korea, while there is a significant difference between U.S. and Chinese/Korean athletes, as well as between Canadian and Chinese/Korean athletes. 
For females' athletic performance, there is no significant difference between China and Korea, while there is a significant difference between U.S. and Chinese/Korean athletes, between Canadian and Chinese/Korean athletes, as well as between U.S. and Canadian athletes.

## Final Words <a name="outro"></a>
The statistics has spoken. Although each country has national champions, their performance and physical conditions vary tremendously. As the 2019 data has shown, the top CrossFit athletes in North America have shown significant different performance than from top CrossFit athletes in Asia. This difference is also seen in athletes of individual countries' from the two continents. There are many reasons for the different sports performance among athletes: different cultural diet habits, popularity of the sports in different countries, or perhaps even geographic location of athletes could play a role... In another perspective, scores from one major CrossFit event in a particular year in far from enough to evaluate the fitness level of athletes. Other metrics such as weight lifting records for strength evaluations, or records of multiple CrossFit benchmark workouts for metabolic conditioning/endurance evaluation could provide much more accurate and reliable data.

While I mainly focused on the statistical test part of the show, there are other interesting visualizations that explore the weight, height, scores of athletes and their correlations in the R script. 
