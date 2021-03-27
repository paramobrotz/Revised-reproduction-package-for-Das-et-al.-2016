/*

Table A7: Effort in public and private sectors by checklist item discrimination terciles

*/


use "Data\SPDataset.dta", clear
	
* Discrimination Quantiles
egen rec1=rowmean(c1h2 c1h4 c1h7 c1h10 c1h22 c1e1 c1e3		c2h1 c2h2 c2h8 c2h9		c3h2 c3h3 c3h8 c3h14 c3h15 c3e1 c3e3 c3e5)
egen rec2=rowmean(c1h6 c1h11 c1h12 c1e2 c1e4 ekg			c2h3 c2h7 c2h13 c2h14	c3h1 c3h5 c3h6 c3h9 c3h12 c3h21 c3e2)
egen rec3=rowmean(c1h1 c1h3 c1h5 c1h9 c1h13 c1h25			c2h4 c2h5 c2h6 c2h11	c3h4 c3h7 c3h10 c3h13 c3h16 c3h17 c3h19)	
forvalues i=1/3{
	replace rec`i'=rec`i'*100
	}			
	

		
	
	
* PANEL A: with SP fixed effects
foreach yvar in rec1 rec2 rec3 {

	* Audit 1
	reg `yvar' private case2 case3 ssp2-ssp15 if round==1 [weight=wt], cluster(villid) robust
	est store s1_`yvar'
	
	sum `yvar' if e(sample)==1 & private==0 [weight=wt] // Mean of public
	mat s1_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1 [weight=wt] // Mean of private
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1 [weight=wt]
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)] // Mean of sample
		
	* Dual
	reg `yvar' private case2 case3 ssp2-ssp15 if dual==1 & round==2, robust cl(finprovid)
	est store s2_`yvar'
	
	sum `yvar' if e(sample)==1 & private==0 // Mean of public
	mat s2_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1 // Mean of private
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1 // Mean of sample
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	}
	
xml_tab s1_rec1 s1_rec2 s1_rec3 s2_rec1 s2_rec2 s2_rec3, ///
	save("Output\TableA7.xml") replace sheet(TableA7A) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3))	
	
mat means=s1_rec1_mean,s1_rec2_mean,s1_rec3_mean,s2_rec1_mean,s2_rec2_mean,s2_rec3_mean	

xml_tab means, save("Output\TableA7.xml") append sheet(TableA7A_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

* PANEL B: with SP fixed effects and market/district fixed effects	
foreach yvar in rec1 rec2 rec3 {

	reg `yvar' private case2 case3 ssp2-ssp15 market* if round==1 [weight=wt], robust cl(villid)
	est store s1_`yvar'

	areg `yvar' private case2 case3 ssp2-ssp15 if dual==1 & round==2, absorb(distid) cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_rec1 s1_rec2 s1_rec3 s2_rec1 s2_rec2 s2_rec3, ///
	save("Output\TableA7.xml") append sheet(TableA7B) font("garamond" 11) ///
	keep(private) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3))


* PANEL C: with SP fixed effects, market/district fixed effects	and provider controls
foreach yvar in rec1 rec2 rec3 {

	reg `yvar' private case2 case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 [weight=wt], robust cl(villid)
	est store s1_`yvar'

	areg `yvar' private age gender numafter case2 case3 ssp2-ssp15 if dual==1 & round==2, absorb(distid) cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_rec1 s1_rec2 s1_rec3 s2_rec1 s2_rec2 s2_rec3, ///
	save("Output\TableA7.xml") append sheet(TableA7C) font("garamond" 11) ///
	keep(private mbbs qual age gender numafter) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3))

clear matrix	
		
