/*

Table 4: This do-file generates results for Table 4 of Paper

Produces four sub-tables: Panel A, Panel A means, Panel B, Panel C

*/

use "Data\SPDataset.dta", clear

* PANEL A: Regressions without controls and with SP fixed effects
foreach yvar in said_diagnosis correct_diag correct_uncond {

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
	
xml_tab s1_said_diagnosis s1_correct_diag s1_correct_uncond s2_said_diagnosis s2_correct_diag s2_correct_uncond, ///
	save("Output\Table4.xml") replace sheet(Table4A) font("garamond" 11) ///
	keep(private) below stats(r2 N) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=s1_said_diagnosis_mean, s1_correct_diag_mean, s1_correct_uncond_mean, s2_said_diagnosis_mean, s2_correct_diag_mean, s2_correct_uncond_mean	

xml_tab means, save("Output\Table4.xml") append sheet(Table4A_means) font("garamond" 11) ///
	cnames("Said Diagnosis" "Correct diagnosis (conditional)" "Correct diagnosis (unconditional)" "Said Diagnosis" "Correct diagnosis (conditional)" "Correct diagnosis (unconditional)") format(SCLR0 (SCCR0 NCCR3 NCCR3))


* PANEL B: Regressions without controls, SP fixed effects, district/provider fixed effects	
foreach yvar in said_diagnosis correct_diag correct_uncond {

	* Audit 1
	reg `yvar' private case3 ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cluster(villid)
	est store s1_`yvar'
		
	* Dual
	areg `yvar' private case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, absorb(distid) robust cl(finprovid)
	est store s2_`yvar'
		
	}
	
xml_tab s1_said_diagnosis s1_correct_diag s1_correct_uncond s2_said_diagnosis s2_correct_diag s2_correct_uncond, ///
	save("Output\Table4.xml") append sheet(Table4B) font("garamond" 11) ///
	keep(private) below stats(r2 N) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

	
* PANEL C: Regressions with controls, SP fixed effects, district/provider fixed effects	
foreach yvar in said_diagnosis correct_diag correct_uncond {

	* Audit 1
	reg `yvar' private case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cluster(villid)
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private case3 age gender numafter ssp2-ssp15 if dual==1 & round==2 & case!=2, absorb(distid) robust cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_said_diagnosis s1_correct_diag s1_correct_uncond s2_said_diagnosis s2_correct_diag s2_correct_uncond, ///
	save("Output\Table4.xml") append sheet(Table4C) font("garamond" 11) ///
	keep(private mbbs qual age gender numafter) below stats(r2 N) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

