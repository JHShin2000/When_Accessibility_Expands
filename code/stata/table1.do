/*
This program runs a descriptive statistics table for the 
"When Accessibility Expands" paper. 
To run this program you nedd estout pacakge
to install:
ssc install estout, replace
*/
clear all
set more off


*frame

use "input\distance.dta", clear
frame rename default micro    

frame create gyeonggi
frame change gyeonggi
use "input\gyeonggi.dta", clear   

frame create aggregate
frame change aggregate
use "input\collapsed.dta", clear

*check the frame is akay or not
frames dir

*creating descriptive statistics table
frame change gyeonggi
   
estpost summarize subway bus car walk ///
	time_com time_sub time_bus time_car time_walk ///
	seoul incheon gyeonggi wit_dis out_sma, listwise

scalar N_gsum = e(N)
eststo gsum

frame change micro
*variables to summarize 
local vars distance emp workhour realwage realwageperhour

*summarize
frame micro : estpost summarize `vars', listwise
scalar N_all = e(N)  
eststo all

frame micro : estpost summarize `vars' if col==1, listwise
scalar N_col = e(N)
eststo col

frame micro : estpost summarize `vars' if col==0, listwise
scalar N_high = e(N)
eststo high

frame aggregate : estpost summarize  emp_25_65 emp_college_25_65 emp_high_25_65 workhour_25_65 workhour_college_25_65 workhour_high_25_65 realwage_25_65 realwage_college_25_65 realwage_high_25_65 realwageperhour_25_65 realwageperhour_college_25_65 realwageperhour_high_25_65
eststo agg_sum


* estout table
esttab gsum  using "output\table1.tex", replace          ///
    cells("mean(fmt(%12.0fc)) sd(fmt(2))")   ///
    nonote label collabels("Mean" "SD")     ///
    booktabs fragment
	
esttab agg_sum using  "output\table1.tex", append         ///
    cells("mean(fmt(%12.0fc)) sd(fmt(2))") ///
    nonote label collabels("Mean" "SD")     ///
    booktabs fragment
	

esttab all col high using "output\table1.tex", append         ///
    cells("mean(fmt(%12.0fc)) sd(fmt(2))")  ///
    nonote label collabels("Mean" "SD")     ///
    booktabs fragment

set more on
