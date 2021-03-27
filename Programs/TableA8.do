/*

Table A8: Effort, diagnosis and treatment by case

*/
set more off

use "Data\SPDataset.dta", clear

* Unstable Angina

foreach yvar in timespent percent_recqe said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds {

	* Audit 1
	reg `yvar' private ssp2-ssp15 if round==1 & case==1 [weight=wt], robust cl(villid)
	est store s1c1_`yvar'
	sum `yvar' if e(sample)==1 & private==0
	mat s1c1_`yvar'_mean=r(mean)
	
	* Dual
	reg `yvar' private age gender numafter ssp2-ssp15 if dual==1 & round==2 & case==1, robust cl(finprovid)
	est store s2c1_`yvar'
	sum `yvar' if e(sample)==1 & private==0
	mat s2c1_`yvar'_mean=r(mean)
	}
	
	
* Asthma

foreach yvar in timespent percent_recqe said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds  {

	* Audit 1
	reg `yvar' private ssp2-ssp15 if round==1 & case==3 [weight=wt], robust cl(villid)
	est store s1c3_`yvar'
	sum `yvar' if e(sample)==1 & private==0
	mat s1c3_`yvar'_mean=r(mean)
	
	* Dual
	reg `yvar' private age gender numafter ssp2-ssp15 if dual==1 & round==2 & case==3, robust cl(finprovid)
	est store s2c3_`yvar'
	sum `yvar' if e(sample)==1 & private==0
	mat s2c3_`yvar'_mean=r(mean)
	
	}	

	
* Dysentery

foreach yvar in timespent percent_recqe {

	* Audit 1
	reg `yvar' private ssp2-ssp15 if round==1 & case==2 [weight=wt], robust cl(villid)
	est store s1c2_`yvar'
	sum `yvar' if e(sample)==1 & private==0
	mat s1c2_`yvar'_mean=r(mean)
	
	* Dual
	reg `yvar' private age gender numafter ssp2-ssp15 if dual==1 & round==2 & case==2, robust cl(finprovid)
	est store s2c2_`yvar'
	sum `yvar' if e(sample)==1 & private==0
	mat s2c2_`yvar'_mean=r(mean)
	}		
	
	
* Output Angina	
	
xml_tab s1c1_timespent s1c1_percent_recqe s1c1_said_diagnosis s1c1_correct_diag s1c1_correct_uncond s1c1_correct_treat s1c1_helpful_treat s1c1_wrong_treat s1c1_correct_only s1c1_antibiotic s1c1_totalmeds ///
		s2c1_timespent s2c1_percent_recqe s2c1_said_diagnosis s2c1_correct_diag s2c1_correct_uncond s2c1_correct_treat s2c1_helpful_treat s2c1_wrong_treat s2c1_correct_only s2c1_antibiotic s2c1_totalmeds, ///
	save("Output\TableA8.xml") replace sheet(TableA8c1) font("garamond" 11) ///
	keep(private) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5 11 13 16)
	
mat mean1=[s1c1_timespent_mean, s1c1_percent_recqe_mean, s1c1_said_diagnosis_mean, s1c1_correct_diag_mean, s1c1_correct_uncond_mean, s1c1_correct_treat_mean, s1c1_helpful_treat_mean, s1c1_wrong_treat_mean, s1c1_correct_only_mean, s1c1_antibiotic_mean, s1c1_totalmeds_mean, ///
	s2c1_timespent_mean, s2c1_percent_recqe_mean, s2c1_said_diagnosis_mean, s2c1_correct_diag_mean, s2c1_correct_uncond_mean, s2c1_correct_treat_mean, s2c1_helpful_treat_mean, s2c1_wrong_treat_mean, s2c1_correct_only_mean, s2c1_antibiotic_mean, s2c1_totalmeds_mean]		
xml_tab mean1, save("Output\TableA8.xml") append sheet(TableA8c1_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5 11 13 16)
	
* Output Asthma	

xml_tab s1c3_timespent s1c3_percent_recqe s1c3_said_diagnosis s1c3_correct_diag s1c3_correct_uncond s1c3_correct_treat s1c3_helpful_treat s1c3_wrong_treat s1c3_correct_only s1c3_antibiotic s1c3_totalmeds ///
		s2c3_timespent s2c3_percent_recqe s2c3_said_diagnosis s2c3_correct_diag s2c3_correct_uncond s2c3_correct_treat s2c3_helpful_treat s2c3_wrong_treat s2c3_correct_only s2c3_antibiotic s2c3_totalmeds, ///
	save("Output\TableA8.xml") append sheet(TableA8c3) font("garamond" 11) ///
	keep(private) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5 11 13 16)

mat mean2=[s1c3_timespent_mean, s1c3_percent_recqe_mean, s1c3_said_diagnosis_mean, s1c3_correct_diag_mean, s1c3_correct_uncond_mean, s1c3_correct_treat_mean, s1c3_helpful_treat_mean, s1c3_wrong_treat_mean, s1c3_correct_only_mean, s1c3_antibiotic_mean, s1c3_totalmeds_mean, ///
	s2c3_timespent_mean, s2c3_percent_recqe_mean, s2c3_said_diagnosis_mean, s2c3_correct_diag_mean, s2c3_correct_uncond_mean, s2c3_correct_treat_mean, s2c3_helpful_treat_mean, s2c3_wrong_treat_mean, s2c3_correct_only_mean, s2c3_antibiotic_mean, s2c3_totalmeds_mean]		
xml_tab mean2, save("Output\TableA8.xml") append sheet(TableA8c3_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5 11 13 16)

* Output Dysentery
		
xml_tab s1c2_timespent s1c2_percent_recqe ///
		s2c2_timespent s2c2_percent_recqe, ///	
	save("Output\TableA8.xml") append sheet(TableA8c2) font("garamond" 11) ///
	keep(private) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5 11 13 16)
	
mat mean3=[s1c2_timespent_mean, s1c2_percent_recqe_mean, ///
	s2c2_timespent_mean, s2c2_percent_recqe_mean]		
xml_tab mean3, save("Output\TableA8.xml") append sheet(TableA8c2_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5 11 13 16)
	
