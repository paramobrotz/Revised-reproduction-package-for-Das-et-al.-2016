/*

Table A14: Reweighted estimates for differential case completion in the dual sample

*/
use "Data\DualDifferentialCompletion.dta", clear
drop case1 case2 case3 ssp1-ssp15
drop private
gen private=public
recode private (1=0) (0=1)
ta case, gen(case)
ta sspname, gen(ssp)
gen private_oneshot = private * oneshot

label var case2 "Dysentery"
label var case3 "Asthma"
label var numafter "Patient load during visit"


local i=1

* PANEL A: with SP fixed effects
foreach var in timespent percent_recqe theta_mle {
		
	* A. Original Regression
	reg `var' private case2 case3 ssp2-ssp8 if dual==1, robust cluster(finprovid)
	est store r1
	
	* E. Corrected Estimate
		
		* Impute Public
		gen `var'_i=`var'
		gen temp1=`var' if oneshot==0 & private==0
		egen temp1a=mean(temp1) if private==0
		sum temp1a
		local m1=r(mean)
		replace `var'_i = temp1a if _m==1 & private==0
		
		* Impute Private
		gen temp2=`var' if oneshot==0 & private==1
		egen temp2a=mean(temp2) if private==1
		sum temp2a
		local m2=r(mean)
		replace `var'_i = temp2a if _m==1 & private==1

		drop temp1 temp1a temp2 temp2a
		
	reg `var'_i private case2 case3 ssp2-ssp8 if isdual==1, cluster(finprovid) // Corrected Estimate
	est sto r2
	
	xml_tab r1 r2, ///
		save("Output\TableA14.xml") replace sheet(Table`i') font("garamond" 11) ///
		keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3))
	local i=`i'+1
	estimates clear
	}

tempfile master
save `master', replace	
			
* Plausible values Regressions - Results cannot be outputted. Have to be done manually
* Note at the moment these include Audit 1 private vs. Audit 2 public also - these are not needed. 	
	
	egen providertag=tag(finprovid private)
	ren oneshot temp
	bys finprovid private: egen oneshot=mode(temp), maxmode
	drop temp private_oneshot
	gen private_oneshot = private * oneshot
	
	keep if providertag==1
	
	foreach var in theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5{
		* Impute Public
		gen `var'_i=`var'
		gen temp1=`var' if oneshot==0 & private==0
		egen temp1a=mean(temp1) if private==0
		sum temp1a
		local m1=r(mean)
		replace `var'_i = temp1a if _m==1 & private==0
		
		* Impute Private
		gen temp2=`var' if oneshot==0 & private==1
		egen temp2a=mean(temp2) if private==1
		sum temp2a
		local m2=r(mean)
		replace `var'_i = temp2a if _m==1 & private==1
		
		drop temp1 temp1a temp2 temp2a
	}
	
	estimates clear
	
	* A. Original Regression
	preserve
		keep if dual==1
		pvreg private if dual==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
		mat r1=est
	restore
	
	* E. Corrected Estimate	
	preserve
		pvreg private, theta(theta_pv1_i theta_pv2_i theta_pv3_i theta_pv4_i theta_pv5_i) cluster(finprovid)
		mat r5=est	
	restore
	
	clear matrix
	

use `master', clear	
* TREATMENT VARIABLES	
drop if case==2

* PANEL A: with SP fixed effects
foreach var in correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds {
		
	* A. Original Regression
	reg `var' private case2 case3 ssp2-ssp8 if dual==1, robust cl(finprovid)
	est store r1
	
	* E. Corrected Estimate
		
		* Impute Public
		gen `var'_i=`var'
		gen temp1=`var' if oneshot==0 & private==0
		egen temp1a=mean(temp1) if private==0
		sum temp1a
		local m1=r(mean)
		replace `var'_i = temp1a if _m==1 & private==0
		
		* Impute Private
		gen temp2=`var' if oneshot==0 & private==1
		egen temp2a=mean(temp2) if private==1
		sum temp2a
		local m2=r(mean)
		replace `var'_i = temp2a if _m==1 & private==1

		drop temp1 temp1a temp2 temp2a
		
	reg `var'_i private case2 case3 ssp2-ssp8 if isdual==1, cluster(finprovid) // Corrected Estimate
	est sto r2
	
	xml_tab r1 r2, ///
		save("Output\TableA14.xml") append sheet(Table`i') font("garamond" 11) ///
		keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3))
	local i=`i'+1
	estimates clear
	}
	
