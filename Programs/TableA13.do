/*

Table A13: Differential case completion in the dual practice sample

*/

set more off

use "Data\DualDifferentialCompletion.dta", clear
drop case1 case2 case3 ssp1-ssp15
drop private
gen private=public
recode private (1=0) (0=1)
ta case, gen(case)
ta sspname, gen(ssp)
gen private_oneshot = private * oneshot
gen public_oneshot = public * oneshot

label var case2 "Dysentery"
label var case3 "Asthma"
label var numafter "Patient load during visit"
egen providertag=tag(finprovid private)

local i=1

* PANEL A: Summary Statistics

mat table=J(8,12,.)
mat table_STARS=J(8,12,.)


count if private==0
local N=r(N)

count if completed==1 & oneshot==1 & private==0
mat table[1,1]=r(N)/`N'

count if completed==1 & oneshot==0 & private==0
mat table[2,1]=r(N)/`N'

count if completed==0 & private==0
mat table[3,1]=r(N)/`N'

count if private==1
local N=r(N)
count if completed==1 & oneshot==1 & private==1
mat table[5,1]=r(N)/`N'

count if completed==1 & oneshot==0 & private==1
mat table[6,1]=r(N)/`N'

count if completed==0 & private==1
mat table[7,1]=r(N)/`N'


local i=1
local j=2
foreach var in timespent percent_recqe{
	ttest `var' if dual==1 & private==0, by(oneshot)
	mat table[`i',`j']=r(mu_2)
	mat table[`i'+1,`j']=r(mu_1)
	mat table[`i'+3,`j']=r(mu_2)-r(mu_1)
		local pval=min(`r(p_u)', `r(p_l)', `r(p)')
		if `pval'<.01{
			local star=1
			}
		else if `pval'>0.01 & `pval'<.05 {
			local star=2
			}
		else if `pval'>0.05 & `pval'<.1 {
			local star=3
			}
		else if `pval'>0.1 {
			local star=0
			}	
	mat table_STARS[`i'+3,`j']=`star'

	ttest `var' if dual==1 & private==1, by(oneshot)
	mat table[`i'+4,`j']=r(mu_2)
	mat table[`i'+5,`j']=r(mu_1)
	mat table[`i'+7,`j']=r(mu_2)-r(mu_1)
		local pval=min(`r(p_u)', `r(p_l)', `r(p)')
		if `pval'<.01{
			local star=1
			}
		else if `pval'>0.01 & `pval'<.05 {
			local star=2
			}
		else if `pval'>0.05 & `pval'<.1 {
			local star=3
			}
		else if `pval'>0.1 {
			local star=0
			}	
	mat table_STARS[`i'+7,`j']=`star'
	
	local i=1
	local j=`j'+1
}

egen theta_pv=rowmean(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5)
local i=1
local j=4
foreach var in theta_pv{
	ttest `var' if dual==1 & private==0 & providertag==1, by(oneshot)
	mat table[`i',`j']=r(mu_2)
	mat table[`i'+1,`j']=r(mu_1)
	mat table[`i'+3,`j']=r(mu_2)-r(mu_1)
		local pval=min(`r(p_u)', `r(p_l)', `r(p)')
		if `pval'<.01{
			local star=1
			}
		else if `pval'>0.01 & `pval'<.05 {
			local star=2
			}
		else if `pval'>0.05 & `pval'<.1 {
			local star=3
			}
		else if `pval'>0.1 {
			local star=0
			}	
	mat table_STARS[`i'+3,`j']=`star'

	ttest `var' if dual==1 & private==1 & providertag==1, by(oneshot)
	mat table[`i'+4,`j']=r(mu_2)
	mat table[`i'+5,`j']=r(mu_1)
	mat table[`i'+7,`j']=r(mu_2)-r(mu_1)
		local pval=min(`r(p_u)', `r(p_l)', `r(p)')
		if `pval'<.01{
			local star=1
			}
		else if `pval'>0.01 & `pval'<.05 {
			local star=2
			}
		else if `pval'>0.05 & `pval'<.1 {
			local star=3
			}
		else if `pval'>0.1 {
			local star=0
			}	
	mat table_STARS[`i'+7,`j']=`star'
	
	local i=1
	local j=`j'+1
}


count if private==0 & case!=2
local N=r(N)

count if completed==1 & oneshot==1 & private==0 & case!=2
mat table[1,6]=r(N)/`N'

count if completed==1 & oneshot==0 & private==0 & case!=2
mat table[2,6]=r(N)/`N'

count if completed==0 & private==0 & case!=2
mat table[3,6]=r(N)/`N'

count if private==1
local N=r(N)
count if completed==1 & oneshot==1 & private==1 & case!=2
mat table[5,6]=r(N)/`N'

count if completed==1 & oneshot==0 & private==1 & case!=2
mat table[6,6]=r(N)/`N'

count if completed==0 & private==1 & case!=2
mat table[7,6]=r(N)/`N'

		
local i=1
local j=7
foreach var in correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds {	
	ttest `var' if dual==1 & private==0 & case!=2, by(oneshot)
	mat table[`i',`j']=r(mu_2)
	mat table[`i'+1,`j']=r(mu_1)
	mat table[`i'+3,`j']=r(mu_2)-r(mu_1)
		local pval=min(`r(p_u)', `r(p_l)', `r(p)')
		if `pval'<.01{
			local star=1
			}
		else if `pval'>0.01 & `pval'<.05 {
			local star=2
			}
		else if `pval'>0.05 & `pval'<.1 {
			local star=3
			}
		else if `pval'>0.1 {
			local star=0
			}	
	mat table_STARS[`i'+3,`j']=`star'

	ttest `var' if dual==1 & private==1 & case!=2, by(oneshot)
	mat table[`i'+4,`j']=r(mu_2)
	mat table[`i'+5,`j']=r(mu_1)
	mat table[`i'+7,`j']=r(mu_2)-r(mu_1)
		local pval=min(`r(p_u)', `r(p_l)', `r(p)')
		if `pval'<.01{
			local star=1
			}
		else if `pval'>0.01 & `pval'<.05 {
			local star=2
			}
		else if `pval'>0.05 & `pval'<.1 {
			local star=3
			}
		else if `pval'>0.1 {
			local star=0
			}	
	mat table_STARS[`i'+7,`j']=`star'
	
	local i=1
	local j=`j'+1
}	

xml_tab table, ///
	save("Output\TableA13.xml") replace sheet(Table1) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) mv("")


* PANEL B: Differential Completion

local k=1
foreach var in timespent percent_recqe theta_mle {
		
	* 1. Differential Attrition
	reg `var' public oneshot public_oneshot case2 case3 ssp2-ssp8 if dual==1, cl(finprovid)
	est sto r`k'
	local k=`k'+1
	
	}
		
foreach var in correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds {	
	
	* 1. Differential Attrition
	reg `var' public oneshot public_oneshot case2 case3 ssp2-ssp8 if dual==1 & case!=2, cl(finprovid)
	est sto r`k'
	local k=`k'+1
	
	}
	
xml_tab r1 r2 r3 r4 r5 r6 r7 r8 r9, ///
	save("Output\TableA13.xml") append sheet(Table2) font("garamond" 11) ///
	keep(public oneshot public_oneshot) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
* Plausible values Regressions - Results cannot be outputted. Have to be done manually
* Note at the moment these include Audit 1 private vs. Audit 2 public also - these are not needed. 	
	
	ren oneshot temp
	bys finprovid private: egen oneshot=mode(temp), maxmode
	drop temp public_oneshot
	gen public_oneshot = public * oneshot
	
	keep if providertag==1

	estimates clear
	
	* 1. Differntial Attrition
	preserve
		keep if dual==1
		pvreg public oneshot public_oneshot if dual==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
		mat r4=est
	restore
	
	clear matrix
	
