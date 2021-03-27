* Table 9: Wages in the Public Sector

clear 
cap clear matrix
set mem 400m
set more off 
cap: log clos
cd "C:\Users\amohpal\Desktop\AER Submission\20151138_data"

use "Data\Paper2_SSPDataset_wIRT_final.dta", clear
keep if public==1  
preserve
	use "Data\Paper2_ProviderDataset.dta", clear
	keep if public==1
	replace medincome=salary_public if salary_public!=.
	keep finprovid finclinid birthpl medincome practype
	tempfile provider
	save `provider', replace
restore
merge m:1 finprovid finclinid using `provider'
drop if _m==2
tab round _m // In 23 cases, no merge. Of these 17 are finprovid=-99 
drop _m

gen distbirth=0 if birthpl!=.
replace distbirth=1 if birthpl==1|birthpl==2|birthpl==3
label var distbirth "Born in same district"

gen logsalary=ln(medincome)
label var logsalary "Log of salary"

gen doctor=0
replace doctor=1 if practype==1
label var doctor "Is an MBBS doctor"

gen nurse=0 // 5 nurse observations
replace nurse=1 if practype==2
label var nurse "Is a nurse"
 
gen compounder=0 // 49 compounder observations
replace compounder=1 if practype==7
label var compounder "Is a compounder"

gen unknown=0
replace unknown=1 if (doctor==0 & nurse==0 & compounder==0)
label var unknown "Is unknown provider"
label var discussdiag "Provider discussed diagnosis"

replace correct_diag=. if said_diagnosis==0

* November 5th email. Use UNCONDITIONAL DIAGNOSIS. Easiest way to do this is change here. 
gen correct_uncond=correct_diag
replace correct_uncond=0 if correct_diag==.

* Get "desirability variables" from Public Facility Survey: Email dated Feb 27th from Jishnu
preserve
	use "Data\PublicFacilitySurvey_clean.dta", clear
	count
	bys phcid: gen staffcount=_n
	bys phcid: keep if _n==1
	isid phcid, sort

	* CHC vs. PHC
	replace phcname=subinstr(phcname, ".","",.)
	replace phcname=subinstr(phcname, "PRIMARY HEALTH CENTRE","PHC",.)
	replace phcname=subinstr(phcname, "COMMUNITY HEALTH CENTRE","CHC",.)
	gen chc=1 if strpos(phcname, "CHC")
	replace chc=0 if strpos(phcname, "PHC")
	replace chc=0 if chc==.
	la var chc "Is a CHC"

	* Accessibility Index - PCA of distance to 8 variables 
	foreach x in a b c d e f g h{
		gen dist_`x'=s6q`x'k+s6q`x'm/1000
		isid phcid, sort
		xtile median_`x'=dist_`x', nq(2)
		recode median_`x' 1=1 2=0
		}
		
	pca dist_a dist_b dist_c dist_f dist_g dist_h
	predict remote_pca
	label var remote_pca "Remoteness Index - PCA"

	* Inspections
	recode s5q1 (-99=0) (0=0)
	rename s5q1 visit
	label var visit "Number of BMO/CMO visits in past 1 month"
	
	* Staff toilet
	gen toilet=s8q1g
	recode toilet 1=1 2=0
	
	* Drinking water
	gen water=s8q1f
	recode water 1=1 2=0
	
	recode s8q1? (1=1) (2=0) (*=.)
	
	keep phcid chc remote_pca visit staffcount median_a median_b median_c median_d median_e median_f median_g median_h s4q4a1 ///
		s8q1a s8q1b s8q1c s8q1d s8q1f s8q1g s8q1h s8q1i s8q1j s8q1k s8q1l s8q1m s8q1n s8q1o s8q1p s8q1q s8q1r s8q1t s8q1u
	
	pca staffcount median_a median_b median_c median_d median_e median_f median_g median_h s4q4a1 ///
		s8q1a s8q1b s8q1c s8q1d s8q1f s8q1g s8q1h s8q1i s8q1j s8q1k s8q1l s8q1m s8q1n s8q1o s8q1p s8q1q s8q1r s8q1t s8q1u
	predict pca

	tempfile desirability
	save `desirability', replace
restore 

merge m:1 phcid using `desirability'
drop if _m==2
drop _m

keep distid finprovid finclinid villid distid round logsalary pca percent_recqe timespent correct_treat mbbs qual age gender distbirth dual

save "Data\PublicSalary.dta", replace
