/*

Table 3: This do-file generates results for Table 3 of Paper

Produces four sub-tables: Panel A, Panel A means, Panel B, Panel C

The ado file pvreg.ado is used for IRT score regressions. The ado file MUST be installed in the appropriate ado folder for this file to run

Note that results in Panels A, B, and C report MLE scores, these are later replaced with PV scores regressions from running the pvreg.do file manually

*/

use "Data\SPDataset.dta", clear

* PANEL A: with SP fixed effects
foreach yvar in timespent percent_recqe theta_mle {

	* Audit 1
	reg `yvar' private case2 case3 ssp2-ssp15 if round==1 [weight=wt], cluster(villid) robust
	est store s1_`yvar'
	
	sum `yvar' if e(sample)==1 & private==0 [weight=wt]
	mat s1_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1 [weight=wt]
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1 [weight=wt]
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)]
		
	* Dual
	reg `yvar' private case2 case3 ssp2-ssp15 if dual==1 & round==2, robust cl(finprovid)
	est store s2_`yvar'
	
	sum `yvar' if e(sample)==1 & private==0
	mat s2_`yvar'_mean=r(mean)
	sum `yvar' if e(sample)==1 & private==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	sum `yvar' if e(sample)==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)]
	
	}
	
xml_tab s1_timespent s1_percent_recqe s1_theta_mle s2_timespent s2_percent_recqe s2_theta_mle, ///
	save("Output\Table3.xml") replace sheet(Table3A) font("garamond" 11) ///
	keep(private) below stats(r2 N) mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=s1_timespent_mean,s1_percent_recqe_mean,s1_theta_mle_mean,s2_timespent_mean,s2_percent_recqe_mean,s2_theta_mle_mean	

xml_tab means, save("Output\Table3.xml") append sheet(Table3A_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))


* PANEL B: with SP fixed effects and market/district fixed effects	
foreach yvar in timespent percent_recqe theta_mle {

	reg `yvar' private case2 case3 ssp2-ssp15 market* if round==1 [weight=wt], robust cluster(villid) 
	est store s1_`yvar'
	
	areg `yvar' private case2 case3 ssp2-ssp15 if dual==1 & round==2, absorb(distid) cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_timespent s1_percent_recqe s1_theta_mle s2_timespent s2_percent_recqe s2_theta_mle, ///
	save("Output\Table3.xml") append sheet(Table3B) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3)) 	


* PANEL C: with SP fixed effects, market/district fixed effects	and provider controls
foreach yvar in timespent percent_recqe theta_mle {

	reg `yvar' private case2 case3 mbbs qual age gender numafter ssp2-ssp15 market* if round==1 [weight=wt], robust cluster(villid) 
	est store s1_`yvar'

	areg `yvar' private age gender numafter case2 case3 ssp2-ssp15 if dual==1 & round==2, absorb(distid) cl(finprovid)
	est store s2_`yvar'
	
	}
	
xml_tab s1_timespent s1_percent_recqe s1_theta_mle s2_timespent s2_percent_recqe s2_theta_mle, ///
	save("Output\Table3.xml") append sheet(Table3C) font("garamond" 11) ///
	keep(private mbbs qual age gender numafter) below stats(r2 N)  mv("") format(SCLR0 (SCCR0 NCCR3 NCCR3))

			
* Plausible values Regressions		
	* PANEL A: Wihout controls
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if round==1
	pvreg private ssp2-ssp15 if round==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
	mat s1=est

	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if dual==1 & round==2
	pvreg private ssp2-ssp15 if dual==1 & round==2, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
	mat s2=est
	matrix drop est
	
	* PANEL B: Without controls and market/district fixed effects
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if round==1
	tab villid, gen(v)
	pvreg private ssp2-ssp15 market2-market60 if round==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
	mat s1_fe1=est
	
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if dual==1 & round==2
	pvreg private ssp2-ssp15 dist1-dist5 if dual==1 & round==2, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
	mat s2_fe1=est
	
	* PANEL C: With controls and market/district fixed effects
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if round==1
	tab villid, gen(v)
	pvreg private mbbs qual age gender numafter ssp2-ssp15 market2-market60 if round==1, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
	mat s1_fe2=est
	
	use "Data\SPDataset.dta", clear
	keep if provtag==1
	keep if dual==1 & round==2
	pvreg private age gender numafter ssp2-ssp15 dist1-dist5 if dual==1 & round==2, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(finprovid)
	mat s2_fe3=est
	

		

