/*

Table A18: Difference between dual and non-dual providers' treatment of SPs

*/

set more off
use "Data\SPDataset", clear
keep if public==1 & round==2 // For the Dual public sample only
drop if case==2 // Unstable Angina and Asthma Cases only

	foreach yvar in timespent percent_recqe{
		
		reg `yvar' dual case2 case3 ssp2-ssp15, robust cl(finprovid)
		est store `yvar'
		sum `yvar' if e(sample)==1 & dual==0 // Mean of non-dual
		mat `yvar'_mean=r(mean)
		sum `yvar' if e(sample)==1 & dual==1 // Mean of dual
		mat `yvar'_mean=`yvar'_mean\[r(mean)]
		sum `yvar' if e(sample)==1
		mat `yvar'_mean=`yvar'_mean\[r(mean)]
		
		areg `yvar' dual case2 case3 age gender numafter ssp2-ssp15, absorb(distid) robust cl(finprovid)
		est store `yvar'_fe
		sum `yvar' if e(sample)==1 & dual==0 // Mean of non-dual
		mat `yvar'_fe_mean=r(mean)
		sum `yvar' if e(sample)==1 & dual==1 // Mean of dual
		mat `yvar'_fe_mean=`yvar'_fe_mean\[r(mean)]
		sum `yvar' if e(sample)==1
		mat `yvar'_fe_mean=`yvar'_fe_mean\[r(mean)]
		}

	foreach yvar in said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds referaway{
		
		reg `yvar' dual case2 case3 ssp2-ssp15, robust cl(finprovid)
		est store `yvar'
		sum `yvar' if e(sample)==1 & dual==0 // Mean of non-dual
		mat `yvar'_mean=r(mean)
		sum `yvar' if e(sample)==1 & dual==1 // Mean of dual
		mat `yvar'_mean=`yvar'_mean\[r(mean)]
		sum `yvar' if e(sample)==1
		mat `yvar'_mean=`yvar'_mean\[r(mean)]
		
		areg `yvar' dual case2 case3 age gender numafter ssp2-ssp15, absorb(distid) robust cl(finprovid)
		est store `yvar'_fe
		sum `yvar' if e(sample)==1 & dual==0 // Mean of non-dual
		mat `yvar'_fe_mean=r(mean)
		sum `yvar' if e(sample)==1 & dual==1 // Mean of dual
		mat `yvar'_fe_mean=`yvar'_fe_mean\[r(mean)]
		sum `yvar' if e(sample)==1
		mat `yvar'_fe_mean=`yvar'_fe_mean\[r(mean)]
		}
	
xml_tab timespent percent_recqe said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds referaway timespent_fe percent_recqe_fe said_diagnosis_fe correct_diag_fe correct_uncond_fe correct_treat_fe helpful_treat_fe wrong_treat_fe correct_only_fe antibiotic_fe totalmeds_fe referaway_fe, ///
	save("Output\TableA18.xml") replace sheet(TableA18) font("garamond" 11) ///
	keep(dual age gender numafter) below stats(r2 N) ///
	title("Table 5: Dual providers' effort in the public sector") ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) 
	
mat means=timespent_mean, percent_recqe_mean, said_diagnosis_mean, correct_diag_mean, correct_uncond_mean, correct_treat_mean, helpful_treat_mean, wrong_treat_mean, correct_only_mean, antibiotic_mean, totalmeds_mean, referaway_mean, timespent_fe_mean, percent_recqe_fe_mean, said_diagnosis_fe_mean, correct_diag_fe_mean, correct_uncond_fe_mean, correct_treat_fe_mean, helpful_treat_fe_mean, wrong_treat_fe_mean, correct_only_fe_mean, antibiotic_fe_mean, totalmeds_fe_mean, referaway_fe_mean


xml_tab means, save("Output\TableA18.xml") append sheet(TableA18_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))
	

	
* IRT SCORES		
	use "Constructed\Paper2\AnalysisFiles\Paper2_SSPDataset_wIRT_final.dta", clear
	keep if provtag==1
	keep if public==1 & round==2
	tab villid, gen(v)
	pvreg dual if round==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
	mat s1=est
	
	use "Constructed\Paper2\AnalysisFiles\Paper2_SSPDataset_wIRT_final.dta", clear
	keep if provtag==1
	keep if public==1 & round==2
	pvreg dual age gender numafter dist1-dist5 if round==2 & dual==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
	mat s2=est
	
	matlist s1
	matlist s2
	
