/*
This program runs for the  variety of specifications for the table 4 of "When Accessibility Expands" paper. 
estimation stratages.

The table above estimates changes in various commuting patterns due to the new subway line by gender.

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
local control age i.married i.col pop ratio_mar ratio_col ratio_manu city_id#c.year

foreach y of varlist car bus subway walk others incheon seoul gyeonggi within other_dest {

reghdfe `y' did `control' if female == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize `y' if treat==1 & post==0 & female == 1 , meanonly
    estadd scalar premean = r(mean)    
	eststo `y'_fe
	 
reghdfe `y' did `control' if female == 0 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize `y' if treat==1 & post==0 & female == 0 , meanonly
    estadd scalar premean = r(mean)
	eststo `y'_ma
}

*female
*average
reghdfe commutetime did `control' if female == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 1, meanonly
    estadd scalar premean = r(mean)
    eststo c1_fe
*subw
reghdfe commutetime  did `control' if female == 1 & subway == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 1 & subway == 1, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo csub_fe
*bus
reghdfe commutetime did `control' if female == 1 & bus== 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 1 & bus == 1, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo cbus_fe

*car
reghdfe commutetime did `control' if female == 1 &car == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 1 & car == 1, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo ccar_fe

*walk
reghdfe commutetime did `control' if walk== 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & female == 1 & walk == 1, ///
	meanonly
	estadd scalar premean = r(mean)
    eststo cwalk_fe
	
*male
*average
reghdfe commutetime did `control' if female == 0  [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 0, meanonly
    estadd scalar premean = r(mean)
    eststo c1_ma
	
*subway
reghdfe commutetime  did `control' if female == 0& subway == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 0 & subway == 1, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo csub_ma
*bus
reghdfe commutetime did `control' if female == 0& bus== 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 0 & bus == 1, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo cbus_ma

*car
reghdfe commutetime did `control' if female == 0&car == 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
    quietly summarize commutetime if treat==1 & post==0 & female == 0 & car == 1, ///
	meanonly
    estadd scalar premean = r(mean)
    eststo ccar_ma

*walk
reghdfe commutetime did `control' if walk== 1 [aweight=pop],  ///
	absorb(city_id year) vce(cluster city_id)
	quietly summarize commutetime if treat==1 & post==0 & female == 0 & walk == 1, ///
	meanonly
	estadd scalar premean = r(mean)
    eststo cwalk_ma

*estimation out
esttab subway_fe bus_fe car_fe walk_fe seoul_fe incheon_fe gyeonggi_fe within_fe ///
	c1_fe csub_fe cbus_fe ccar_fe cwalk_fe ///
	using "output/table4.tex", /// 
	replace bookt fragment ///
    label keep(did)  ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01)  ///
    stats(N premean, fmt(%9.0fc %9.2fc) labels("N" "Mean"))
	  
esttab subway_ma bus_ma car_ma walk_ma seoul_ma incheon_ma gyeonggi_ma within_ma ///
	c1_ma csub_ma cbus_ma ccar_ma cwalk_ma ///
	using "output/table4.tex", /// 
	append bookt fragment ///
    label keep(did)  ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01)  ///
    stats(N premean, fmt(%9.0fc %9.2fc) labels("N" "Mean"))
	
set more off