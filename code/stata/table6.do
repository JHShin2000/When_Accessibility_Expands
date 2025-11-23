/*
This program runs for the  variety of specifications for the table 5 of "When Accessibility Expands" paper. 
estimation stratages.

The table above estimates changes in various labor market outcomes due to the new subway line by education.

Basic empirical strategy is 
	\hat{\tau}^{sdid}=
		\argmin_{\tau,\mu,\alpha,\beta}
		\Bigl[\sum^N_{i=1} \sum^T_{t=1}\bigl( Y_{it}-\left(\mu+\alpha_i+\beta_t+X_{it}^\prime \gamma
				+\tau D_{it}\right)^2 \hat{w}^{sdid}\hat{\lambda}^{sdid}\bigr) \Bigr]
	

To run this program, you need to install sdid and estout packages.
To install, run:
ssc install sdid, replace
ssc install estout, replace
*/

clear all
set more off

use "input\lastcollapse.dta", clear

local control col marriage manufacture population

*synthetic control
foreach y of varlist emp_fem emp_mal workhour_fem workhour_mal workhour_mar lnrealwage_fem lnrealwage_mal lnrealwageperhour_fem lnrealwageperhour_mal {
sdid `y' city_id year did, ///
	vce(placebo) covariates(`control') seed(42)
	quietly summarize `y' if treat==1 & post==0, meanonly 
	estadd scalar premean = r(mean)
    eststo `y'
}

esttab emp_fem workhour_fem lnwg_2564 lnwgph_2564 ///
	using "output/table6.tex", /// 
	replace bookt fragment ///
    label keep(did)  ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01)  

esttab emp_high_25_65 workhour_high_25_65 lnwg_high_2564 lnwgph_high_2564 ///
	using "output/table5.tex", /// 
	append bookt fragment ///
    label keep(did)  ///
    cells(b(fmt(3) star) se(par fmt(3))) ///
    starlevels(* 0.10 ** 0.05 *** 0.01)  
set more on