/*

Table A11: Robustness of provider effort to exclusion of dysentery cases

*/

set more off
use "Data\SPDataset", clear

* PANEL A: with SP fixed effects
foreach yvar in timespent percent_recqe {

	* Audit 1
	reg `yvar' private case2 case3 ssp2-ssp15 if round==1 & case!=2 [weight=wt], cluster(villid) robust
	est store s1_`yvar'
	sum `yvar' if e(sample)==1 & private==0 [weight=wt] // Mean of public
	mat s1_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1 [weight=wt] // Mean of private
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1 [weight=wt]
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)] // Mean of sample
		
	* Dual
	reg `yvar' private case2 case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, robust cl(finprovid)
	est store s2_`yvar'
	sum `yvar' if e(sample)==1 & private==0 // Mean of public
	mat s2_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1 // Mean of private
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1 // Mean of sample
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	}
	
xml_tab s1_timespent s1_percent_recqe s2_timespent s2_percent_recqe, ///
	save("Output\TableA11.xml") replace sheet(TableA11A) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=s1_timespent_mean,s1_percent_recqe_mean,s2_timespent_mean,s2_percent_recqe_mean	

xml_tab means, save("Output\TableA11.xml") append sheet(TableA11A_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

* PANEL B: with SP fixed effects and market/district fixed effects	
foreach yvar in timespent percent_recqe {

	reg `yvar' private case2 case3 ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cl(villid)
	est store s1_`yvar'

	areg `yvar' private case2 case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, absorb(distid) cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_timespent s1_percent_recqe s2_timespent s2_percent_recqe, ///
	save("Output\TableA11.xml") append sheet(TableA11B) font("garamond" 11) ///
	keep(private) below stats(r2 N) lines(0 2 LAST_ROW 2) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) 


* PANEL C: with SP fixed effects, market/district fixed effects	and provider controls
foreach yvar in timespent percent_recqe {

	reg `yvar' private case2 case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 & case!=2 [weight=wt], robust cl(villid)
	est store s1_`yvar'

	areg `yvar' private age gender numafter case2 case3 ssp2-ssp15 if dual==1 & round==2 & case!=2, absorb(distid) cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_timespent s1_percent_recqe s2_timespent s2_percent_recqe, ///
	save("Output\TableA11") append sheet(TableA11C) font("garamond" 11) ///
	keep(private mbbs qual age gender numafter) below stats(r2 N) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))
