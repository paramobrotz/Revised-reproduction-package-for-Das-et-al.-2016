/*

Table A19: Robustness to alternative metrics for public-private comparison

*/


set more off
set matsize 3000

use "Data\SPDataset.dta", clear
keep if round==1
isid finprovid finclinid case provseen, sort missok
gen sortorder=_n // Required to replicate results
tempfile master
save `master', replace

local vars1 = "timespent percent_recqe" 
local vars2 = "said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds"

* Best public vs. best private by correct treatment

use `master', clear
estimates clear

bys finprovid finclinid: egen temp1=mean(correct_treat) if correct_treat!=.
bys villid private: egen temp2=max(temp1)
keep if (private==0 & temp1==temp2)|(private==1 & temp1==temp2)
ta private case

foreach var in `vars1'{
	reg `var' private case2 case3 ssp2-ssp15 market*, cl(villid) r
	est sto `var'
	
	sum `var' if e(sample)==1 & private==0 // Mean of public
	mat `var'_mean=r(mean)
	sum `var' if e(sample)==1 & private==1 // Mean of private
	mat `var'_mean=`var'_mean\[r(mean)]
	sum `var' if e(sample)==1 // Mean of sample
	mat `var'_mean=`var'_mean\[r(mean)]	
	}
	
foreach var in `vars2'{
	replace `var'=. if case==2
	reg `var' private case3 ssp2-ssp15 market*, cl(villid) r
	est sto `var'
	
	sum `var' if e(sample)==1 & private==0 // Mean of public
	mat `var'_mean=r(mean)
	sum `var' if e(sample)==1 & private==1 // Mean of private
	mat `var'_mean=`var'_mean\[r(mean)]
	sum `var' if e(sample)==1 // Mean of sample
	mat `var'_mean=`var'_mean\[r(mean)]
	}	

xml_tab timespent percent_recqe said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds, ///
	save("Output\TableA19.xml") append sheet(TableA19A) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5)	
	
mat means=timespent_mean, percent_recqe_mean, said_diagnosis_mean, correct_diag_mean, correct_uncond_mean, correct_treat_mean, helpful_treat_mean, wrong_treat_mean, correct_only_mean, antibiotic_mean, totalmeds_mean
xml_tab means, save("Output\TableA19.xml") append sheet(TableA19A_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))


* Best vs. Best. Checklist

use `master', clear
estimates clear

bys finprovid finclinid: egen temp1=mean(percent_recqe) if percent_recqe!=.
bys villid private: egen temp2=max(temp1)
keep if (private==0 & temp1==temp2)|(private==1 & temp1==temp2)
ta private case

foreach var in `vars1'{
	reg `var' private case2 case3 ssp2-ssp15 market*, cl(villid) r
	est sto `var'
	
	sum `var' if e(sample)==1 & private==0 // Mean of public
	mat `var'_mean=r(mean)
	sum `var' if e(sample)==1 & private==1 // Mean of private
	mat `var'_mean=`var'_mean\[r(mean)]
	sum `var' if e(sample)==1 // Mean of sample
	mat `var'_mean=`var'_mean\[r(mean)]	
	}
	
foreach var in `vars2'{
	replace `var'=. if case==2
	reg `var' private case3 ssp2-ssp15 market*, cl(villid) r
	est sto `var'
	
	sum `var' if e(sample)==1 & private==0 // Mean of public
	mat `var'_mean=r(mean)
	sum `var' if e(sample)==1 & private==1 // Mean of private
	mat `var'_mean=`var'_mean\[r(mean)]
	sum `var' if e(sample)==1 // Mean of sample
	mat `var'_mean=`var'_mean\[r(mean)]
	}	

xml_tab timespent percent_recqe said_diagnosis correct_diag correct_uncond correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds, ///
	save("Output\TableA19.xml") append sheet(TableA19B) font("garamond" 11) ///
	keep(private) below stats(r2 N) format(SCLR0 (SCCR0 NCCR3 NCCR3)) cblanks(2 5)	
	
mat means=timespent_mean, percent_recqe_mean, said_diagnosis_mean, correct_diag_mean, correct_uncond_mean, correct_treat_mean, helpful_treat_mean, wrong_treat_mean, correct_only_mean, antibiotic_mean, totalmeds_mean
xml_tab means, save("Output\TableA19.xml") append sheet(TableA19B_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))
