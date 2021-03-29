/*

Table A10: Robustness of treatment results to alternative definition for correct treatment for unstable angina

*/

set more off
use "Data\SPDataset.dta", clear

* Panel A: Regressions without controls and with SP fixed effects

	* Audit 1
	reg correct_treat2 private case3 ssp2-ssp15 if round==1 & case!=2 [weight=wt], cluster(villid) robust
	est store s1
	sum correct_treat2 if e(sample)==1 & private==0 [weight=wt]
	mat s1_mean=r(mean)
	sum correct_treat2 if e(sample)==1 & private==1 [weight=wt]
	mat s1_mean=s1_mean\[r(mean)]
	sum correct_treat2 if e(sample)==1 [weight=wt]
	mat s1_mean=s1_mean\[r(mean)]
	
	* Dual
	reg correct_treat2 private case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, robust
	est store s2
	sum correct_treat2 if e(sample)==1 & private==0
	mat s2_mean=r(mean)
	sum correct_treat2 if e(sample)==1 & private==1
	mat s2_mean=s2_mean\[r(mean)]
	sum correct_treat2 if e(sample)==1
	mat s2_mean=s2_mean\[r(mean)]
	
	* Audit 1 - MI Only
	reg correct_treat2 private case3 ssp2-ssp15 if round==1 & case==1 [weight=wt], cluster(villid) robust
	est store s3
	sum correct_treat2 if e(sample)==1 & private==0 [weight=wt]
	mat s3_mean=r(mean)
	sum correct_treat2 if e(sample)==1 & private==1 [weight=wt]
	mat s3_mean=s3_mean\[r(mean)]
	sum correct_treat2 if e(sample)==1 [weight=wt]
	mat s3_mean=s3_mean\[r(mean)]
	
	* Dual - MI Only
	reg correct_treat2 private case3 ssp2-ssp15 if dual==1 & round==2 & case==1, robust
	est store s4
	sum correct_treat2 if e(sample)==1 & private==0
	mat s4_mean=r(mean)
	sum correct_treat2 if e(sample)==1 & private==1
	mat s4_mean=s4_mean\[r(mean)]
	sum correct_treat2 if e(sample)==1
	mat s4_mean=s4_mean\[r(mean)]
	
* Panel B: Regressions without controls and with SP and market/district fixed effects

	* Audit 1
	reg correct_treat2 private case3 ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], cluster(villid) robust
	est store s5
	
	* Dual
	areg correct_treat2 private case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, robust absorb(distid) cl(finprovid)
	est store s6
	
	* Audit 1 - MI Only
	reg correct_treat2 private case3 ssp2-ssp15 market* if round==1 & case==1 [weight=wt], cluster(villid) robust
	est store s7
	
	* Dual - MI Only
	areg correct_treat2 private case3 ssp2-ssp15 if dual==1 & round==2 & case==1, robust absorb(distid) cl(finprovid)
	est store s8

	
* Panel C: Regressions with controls and with SP fixed effects

	* Audit 1
	reg correct_treat2 private case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], cluster(villid) robust
	est store s9
	
	* Dual
	areg correct_treat2 private age gender case3 numafter ssp2-ssp15 if dual==1 & round==2 & case!=2, robust absorb(distid) cl(finprovid)
	est store s10
	
	* Audit 1 - MI Only
	reg correct_treat2 private case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 & case==1 [weight=wt], cluster(villid) robust
	est store s11
	
	* Dual - MI Only
	areg correct_treat2 private age gender case3 numafter ssp2-ssp15 if dual==1 & round==2 & case==1, robust absorb(distid) cl(finprovid)
	est store s12
	
	
xml_tab s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12, ///
	save("Output\TableA10.xml") replace sheet(TableA10) font("garamond" 11) ///
	keep(private  mbbs qual age gender numafter) below stats(r2 N) ///
	cnames("Audit 1" "Dual" "Audit 1 MI Only" "Dual MI Only" "Audit 1 Controls" "Dual Controls" "Audit 1 MI Only Controls" "Dual MI Only Controls") ///
	title("Table 5. Treatment in the public and private sectors") ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) 
	
	
mat means=s1_mean, s2_mean, s3_mean, s4_mean

xml_tab means, save("Output\TableA10.xml") append sheet(TableA10_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) 
estimates clear		
	
