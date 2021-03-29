/*

Table 5: This do-file generates results for Table 5 of Paper

Produces four sub-tables: Panel A, Panel A means, Panel B, Panel C

*/

use "Data\SPDataset.dta", clear

* PANEL A: Regressions without controls and with SP fixed effects
foreach yvar in correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds{

	* Audit 1
	reg `yvar' private case3 ssp2-ssp15 if round==1 & case!=2 [weight=wt], cluster(villid) robust
	est store s1_`yvar'
	
	sum `yvar' if e(sample)==1 & private==0 [weight=wt]
	mat s1_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1 [weight=wt]
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1 [weight=wt]
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)]
	
	* Dual
	reg `yvar' private case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, robust cl(finprovid)
	est store s2_`yvar'
	
	sum `yvar' if e(sample)==1 & private==0
	mat s2_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	
	}
	
xml_tab s1_correct_treat s1_helpful_treat s1_wrong_treat s1_correct_only s1_antibiotic s1_totalmeds s2_correct_treat s2_helpful_treat s2_wrong_treat s2_correct_only s2_antibiotic s2_totalmeds, ///
	save("Output\Table5.xml") replace sheet(Table5A) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=s1_correct_treat_mean, s1_helpful_treat_mean, s1_wrong_treat_mean, s1_correct_only_mean, s1_antibiotic_mean, s1_totalmeds_mean, s2_correct_treat_mean, s2_helpful_treat_mean, s2_wrong_treat_mean, s2_correct_only_mean, s2_antibiotic_mean, s2_totalmeds_mean
xml_tab means, save("Output\Table5.xml") append sheet(Table5A_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

estimates clear		
	
	
* PANEL B: Regressions without controls, SP fixed effects, district/provider fixed effects	 
foreach yvar in correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds{

	* Audit 1
	reg `yvar' private case3 ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cluster(villid) 
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, absorb(distid) robust cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_correct_treat s1_helpful_treat s1_wrong_treat s1_correct_only s1_antibiotic s1_totalmeds s2_correct_treat s2_helpful_treat s2_wrong_treat s2_correct_only s2_antibiotic s2_totalmeds, ///
	save("Output\Table5.xml") append sheet(Table5B) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3)) 
	
	
* PANEL C: Regressions with controls, SP fixed effects, district/provider fixed effects	
foreach yvar in correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds {

	* Audit 1
	reg `yvar' private case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cluster(villid) 
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private case3 age gender numafter ssp2-ssp15 if dual==1 & round==2 & case!=2, absorb(distid) robust cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_correct_treat s1_helpful_treat s1_wrong_treat s1_correct_only s1_antibiotic s1_totalmeds s2_correct_treat s2_helpful_treat s2_wrong_treat s2_correct_only s2_antibiotic s2_totalmeds, ///
	save("Output\Table5.xml") append sheet(Table5C) font("garamond" 11) ///
	keep(private mbbs qual age gender numafter) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3))

