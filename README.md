# When Accessibility Expands: Commuting Behaviors and Labor Market Outcomes after a New Subway Line

Urban rail projects are often assessed by in-vehicle time savings, yet faster networks also expand job accessibility and reshape labor supply. 
South Korean workers commute nearly twice as long as the OECD average, making this setting especially relevant. 
I exploit the September 2019 opening of the Gimpo Gold Line as a natural experiment to estimate causal effects on commuting and labor market outcomes using the Gyeonggi-do Social Survey and the Regional Employment Survey. 

Three main findings emerge. First, subway use among Gimpo residents increased by 7.8 percentage points, largely displacing car and bus travel. 
Second, commuting responses were heterogeneous: high-skilled workers shortened one-way trips by about 13 minutes, whereas low-skilled workers lengthened theirs by more than 20 minutes as they expanded their job search toward distant destinations. 
Third, these behavioral adjustments translated into labor market gains: the employment probability of non-college workers rose by roughly 1.3 percentage points, with only modest changes in working hours and wages. 
Overall, the findings demonstrate that transit investments reshape commuting and labor market performance, with especially strong benefits for low-skilled workers.

---

## Data

The original microdata come from the Gyeonggi-do Social Survey and the Regional Employment Survey.  
Due to data-provider restrictions, raw microdata cannot be redistributed.  
This repository provides processed, anonymized datasets sufficient to reproduce all tables and figures.

Download processed data here:  
<https://www.dropbox.com/scl/fo/gb2bxfq1ve7m3atge49ak/AH_vqTP16nAlTRjJhLsEbD4?rlkey=o2q1d5fge6eeqau4zz82o9eaq&st=yl4r8jbe&dl=0>

## Software requirements

- Stata/MP 19
- Packages: `reghdfe`, `ftools`, `parallel`, `estout`, `sdid`.

Install packages by running:

```stata
ssc install ftools, replace
ssc install reghdfe, replace
net install parallel, from("https://raw.github.com/gvegayon/parallel/stable/") replace
ssc install estout, replace
ssc install sdid, replace


