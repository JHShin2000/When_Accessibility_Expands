/*
This program runs for the  variety of specifications for the table 2 of "When Accessibility Expands" paper. 
estimation stratages.

The table above estimates changes in various commuting patterns due to the new subway line by education.

Basic empirical strategy is 
	Y_{it}= \beta_0+\beta_1 \cdot \text{GGL}_{it} +  
			X_{it}^\prime \gamma+\alpha_i+\lambda_t+\delta_{it}+u_{it} 

To run this program, you need to install reghdfe, ftools, parallel, and estout packages.
To install, run:
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace
ssc install estout, replace
*/

clear all
set more off

use "input\merged.dta", clear
keep if age < 65 & age > 24
keep if commute == 1

label variable did "Effect of GGL"
local control age i.female i.married i.col pop ratio_mar ratio_col ratio_manu city_id#c.year

foreach y of varlist  car bus subway walk others incheon seoul gyeonggi within other_dest {

reghdfe `y' did `control'  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
 *pre-mean
     quietly summarize `y' if treat==1 & post==0, meanonly

    estadd scalar premean = r(mean)
    
    eststo `y'

reghdfe `y' did `control' if col == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
 *pre-mean
     quietly summarize `y' if treat==1 & post==0 & col == 1, meanonly
    estadd scalar premean = r(mean)
    eststo `y'_col
	
reghdfe `y' did `control' if col == 0 [aweight=pop],  ///
absorb(city_id year) vce(cluster city_id)
     quietly summarize `y' if treat==1 & post==0  & col == 0 , meanonly

    estadd scalar premean = r(mean)
    eststo `y'_high
}

*estimate commute time
*average
reghdfe commutetime did `control' [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0, meanonly
    estadd scalar premean = r(mean)
    eststo c1
*subway
reghdfe commutetime  did `control' if subway == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & subway == 1, meanonly
    estadd scalar premean = r(mean)
    eststo csub
*bus
reghdfe commutetime did `control' if bus== 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & bus == 1, meanonly
    estadd scalar premean = r(mean)
    eststo cbus

*car
reghdfe commutetime did `control' if car == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & car == 1, meanonly
    estadd scalar premean = r(mean)
    eststo ccar

*walk
reghdfe commutetime did `control' if walk== 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & walk == 1, meanonly
	estadd scalar premean = r(mean)
    eststo cwalk

* low-skilled
*average
reghdfe commutetime did `control' if col == 0 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & col == 0, meanonly
	estadd scalar premean = r(mean)
    eststo c11

*subway
reghdfe commutetime did `control' if subway == 1 & col == 0  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & subway == 1 & col == 0, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo csub1

*bus
reghdfe commutetime did  `control' if bus== 1 & col == 0  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & bus == 1& col == 0, /// 		
	meanonly
    estadd scalar premean = r(mean) 
    eststo cbus1
	
*car
reghdfe commutetime did  `control' if car == 1 & col == 0  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & car == 1 & col == 0 , ///
	meanonly
    estadd scalar premean = r(mean)
    eststo ccar1

*walk
reghdfe commutetime did  `control' if walk== 1 & col == 0  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & walk == 1 & col == 0 , /// 	
	meanonly
    estadd scalar premean = r(mean)
    eststo cwalk1 
	
* high skilled
*average
reghdfe commutetime did  `control' if col == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & col == 1 , meanonly
    estadd scalar premean = r(mean)
    eststo c1h

*subway
reghdfe commutetime did  `control' if subway == 1 & col == 1  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & subway == 1 & col == 1 , ///
	meanonly
    estadd scalar premean = r(mean)
	eststo csubh

*bus
reghdfe commutetime did  `control' if bus== 1 & col == 1  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & bus == 1& col == 1 , ///
	meanonly
    estadd scalar premean = r(mean)
    eststo cbush

*car
reghdfe commutetime did `control' if car == 1 & col == 1  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & car == 1 & col == 1 , ///
	meanonly
    estadd scalar premean = r(mean)
    eststo ccarh
*walk
reghdfe commutetime did  `control' if walk== 1 & col == 1  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & walk == 1 & col == 1 , ///
	meanonly
    estadd scalar premean = r(mean)
    eststo cwalkh
	
esttab subway bus car walk c1 csub cbus ccar cwalk ////
	using "output/table2.tex", /// 
	replace bookt fragment ///
    label keep(did) ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01) ///
    stats(N premean, fmt(%9.0fc %9.2fc) labels("N" "Mean"))
	  

esttab subway_high bus_high car_high walk_high c11 csub1 cbus1 ccar1 cwalk1 ////
	using "output/table2.tex", /// 
	append bookt fragment ///
    label keep(did)  ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01)  ///
    stats(N premean, fmt(%9.0fc %9.2fc) labels("N" "Mean"))
	  
	  
esttab subway_col bus_col car_col walk_col c1h  csubh cbush ccarh cwalkh ///
	using "output/table2.tex", /// 
	append bookt fragment ///
    label keep(did)  ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01)  ///
    stats(N premean, fmt(%9.0fc %9.2fc) labels("N" "Mean"))

set more on