/*

Table A12: Robustness of results to inclusion of facilities controls

*/

set more off
use "Data\SPDataset", clear


* Notice that IRT score is incorrect, generated here as a placeholder

foreach yvar in timespent percent_recqe theta_mle {

	* Audit 1
	reg `yvar' private mbbs qual age gender numafter facilitiesindex ssp2-ssp15 market* if round==1 [weight=wt], robust cl(villid)
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private age gender numafter facilitiesindex ssp2-ssp15 if round==2 & dual==1, absorb(distid) robust cl(finprovid)
	est store s2_`yvar'
	
	}
	
foreach yvar in said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds {

	* Audit 1
	reg `yvar' private mbbs qual age gender numafter facilitiesindex ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cl(villid)
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private age gender numafter facilitiesindex ssp2-ssp15 if round==2 & dual==1 & case!=2, absorb(distid) robust cl(finprovid)
	est store s2_`yvar'
	
	}	
	
	
xml_tab s1_timespent s1_percent_recqe s1_theta_mle s1_said_diagnosis s1_correct_diag s1_correct_uncond s1_correct_treat s1_helpful_treat s1_wrong_treat s1_correct_only s1_antibiotic s1_totalmeds s2_timespent s2_percent_recqe s2_theta_mle s2_said_diagnosis s2_correct_diag s2_correct_uncond s2_correct_treat s2_helpful_treat s2_wrong_treat s2_correct_only s2_antibiotic s2_totalmeds, ///
	save("Output\TableA12.xml") replace sheet(TableA12) font("garamond" 11) ///
	keep(private facilitiesindex) below stats(r2 N) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) 
	
		
* IRT SCORES		
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if round==1
	tab villid, gen(v)
	pvreg private mbbs qual age gender numafter facilitiesindex ssp2-ssp15 market* if round==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
	mat s1=est
	
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if round==2 & dual==1
	pvreg private age gender numafter facilitiesindex ssp2-ssp15 dist1-dist5 if round==2 & dual==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
	mat s2=est
	
	matlist s1
	matlist s2
	
