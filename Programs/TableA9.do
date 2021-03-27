/*

Table A9: Summary of Treatment by Case

*/
set more off

use "Data\SPDataset.dta", clear
/* TOC
	
This do-file generates the following tables in checklist analysis for SP data

[1] Table 1 - Alternate Definitions of Treatment - Means, SD, N, Missing - Full Sample	

Note: These have to copied manually for results or Log File
	
*/

* [1] Table 1 - Alternate Definitions of Treatment - Means, SD, N, Missing - Full Sample
	
	mat table=J(29,7,.)
	mat table_STARS=J(29,7,.)

	gen ekgrefer=0 if case==1 & ekg!=. & referaway!=.
	replace ekgrefer=1 if case==1 & (ekg==1 & referaway==1)
	
	local i=2
	* MI
	foreach x in correct_treat correct_treat2 helpful_treat wrong_treat aspirin antiplateletagents referaway ekg ekgrefer antibiotic {
		
		// Audit 1
		ttest `x' if case==1 & round==1, by(public)
		mat table[`i',1]=r(mu_2)
		mat table[`i',2]=r(mu_1)
		local diff=r(mu_1)-r(mu_2)
		mat table[`i',3]=`diff'
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star=3
				}
			else if `pval'>0.1 {
				local star=0
				}	
		mat table_STARS[`i',3]=`star'		
		
		// Dual sample
		ttest `x' if case==1 & round==2 & dual==1, by(public)
		mat table[`i',5]=r(mu_2)
		mat table[`i',6]=r(mu_1)
		local diff=r(mu_1)-r(mu_2)
		mat table[`i',7]=`diff'
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star=3
				}
			else if `pval'>0.1 {
				local star=0
				}	
		mat table_STARS[`i',7]=`star'	

		local i=`i'+1
		
		}	
	
	* Number of observations
	qui: count if case==1 & round==1 & public==1
	mat table[`i',1]=r(N)
	qui: count if case==1 & round==1 & public==0
	mat table[`i',2]=r(N)
	
	qui: count if case==1 & round==2 & dual==1 & public==1
	mat table[`i',5]=r(N)
	qui: count if case==1 & round==2 & dual==1 & public==0
	mat table[`i',6]=r(N)
	
	local i=`i'+2	
	
	* Dysentery
	foreach x in correct_treat helpful_treat wrong_treat ors c2seechild antibiotic {
		
		// Audit 1
		ttest `x' if case==2 & round==1, by(public)
		mat table[`i',1]=r(mu_2)
		mat table[`i',2]=r(mu_1)
		local diff=r(mu_1)-r(mu_2)
		mat table[`i',3]=`diff'
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star=3
				}
			else if `pval'>0.1 {
				local star=0
				}	
		mat table_STARS[`i',3]=`star'		
		
		// Dual sample
		ttest `x' if case==2 & round==2 & dual==1, by(public)
		mat table[`i',5]=r(mu_2)
		mat table[`i',6]=r(mu_1)
		local diff=r(mu_1)-r(mu_2)
		mat table[`i',7]=`diff'
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star=3
				}
			else if `pval'>0.1 {
				local star=0
				}	
		mat table_STARS[`i',7]=`star'	

		local i=`i'+1
		}			
	
	* Number of observations
	qui: count if case==2 & round==1 & public==1
	mat table[`i',1]=r(N)
	qui: count if case==2 & round==1 & public==0
	mat table[`i',2]=r(N)
	
	qui: count if case==2 & round==2 & dual==1 & public==1
	mat table[`i',5]=r(N)
	qui: count if case==2 & round==2 & dual==1 & public==0
	mat table[`i',6]=r(N)
	
	local i=`i'+2	
	
	* Asthma	
	foreach x in correct_treat helpful_treat wrong_treat bronchodilators theophylline oralcorticosteroids antibiotic {
		
		// Audit 1
		ttest `x' if case==3 & round==1, by(public)
		mat table[`i',1]=r(mu_2)
		mat table[`i',2]=r(mu_1)
		local diff=r(mu_1)-r(mu_2)
		mat table[`i',3]=`diff'
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star=3
				}
			else if `pval'>0.1 {
				local star=0
				}	
		mat table_STARS[`i',3]=`star'		
		
		// Dual sample
		ttest `x' if case==3 & round==2 & dual==1, by(public)
		mat table[`i',5]=r(mu_2)
		mat table[`i',6]=r(mu_1)
		local diff=r(mu_1)-r(mu_2)
		mat table[`i',7]=`diff'
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star=3
				}
			else if `pval'>0.1 {
				local star=0
				}	
		mat table_STARS[`i',7]=`star'	

		local i=`i'+1	
		}		
	* Number of observations
	qui: count if case==3 & round==1 & public==1
	mat table[`i',1]=r(N)
	qui: count if case==3 & round==1 & public==0
	mat table[`i',2]=r(N)
	
	qui: count if case==3 & round==2 & dual==1 & public==1
	mat table[`i',5]=r(N)
	qui: count if case==3 & round==2 & dual==1 & public==0
	mat table[`i',6]=r(N)

	xml_tab table, save("Output\TableA9.xml") replace sheet(TableA9) font("garamond" 11) ///
		cnames("Public" "Private" "Difference" " " "Public" "Private" "Difference") ///
 		rnames("UNSTABLE ANGINA" "Correct treatment" "Correct treatment (alternate)" "helpful treat" "wrong treat" "Aspirin" "Anti-platelet agents" "Referred" "ECG" "ECG & Referred" "Antibiotic" "Number of observations" ///
			"DYSENTERY" "Correct treatment"  "helpful treat" "wrong treat" "ORS" "Asked to see child" "Antibiotic" "Number of observations" ///
			"ASTHMA" "Correct treatment"  "helpful treat" "wrong treat" "Bronchodilators" "Theophylline" "Oral Corticosteroids" "Antibiotic" "Number of observations") ///
		mv("") title("Table A9. Treatment of Standardized Patients by Case") ///
		format(SCLR (SCCR0 NCCR2))
	
