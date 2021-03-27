clear 
set more off
cd "C:\Users\amohpal\Desktop\AER Submission\20151138_data"

use "Data\Paper2_SSPDataset_wIRT_final.dta", clear

* Additional coding

replace correct_diag=. if said_diagnosis==0
gen correct_uncond=correct_diag
replace correct_uncond=0 if correct_diag==.

gen referaway_askchild=referaway
replace referaway_askchild=askchild if case==2
la var referaway_askchild "Referred/Asked to see child"
egen totalmeds_disp=rownonmiss(t1_?codepc)
egen totalmeds_pres=rownonmiss(t2_?codepc)
gen prescribe=t2

* Keep only required variables

keep round distid villid finclinid finprovid case case1 case2 case3 ssp1-ssp15 wt ///
	market* mbbs qual age gender numafter private public dual provtag ///
	dist1-dist5 ///
	timespent percent_recqe theta_mle theta_pv1-theta_pv5 ///
	said_diagnosis correct_diag correct_uncond ///
	correct_treat helpful_treat wrong_treat correct_only antibiotic totalmeds ///
	totalmeds_disp totalmeds_pres price referaway_askchild ///
	c1h1 c1h2 c1h3 c1h4 c1h5 c1h6 c1h7 c1h9 c1h10 c1h11 c1h12 c1h13 c1h22 c1h25 c1e1 c1e2 c1e3 c1e4 ekg c2h1 c2h2 c2h3 c2h4 c2h5 c2h6 c2h7 c2h8 c2h9 c2h11 c2h13 c2h14 c3h1 c3h2 c3h3 c3h4 c3h5 c3h6 c3h7 c3h8 c3h9 c3h10 c3h12 c3h13 c3h14 c3h15 c3h16 c3h17 c3h19 c3h21 c3e1 c3e2 c3e3 c3e5 ///
	correct_treat2 aspirin antiplateletagents ors c2seechild bronchodilators theophylline oralcorticosteroids facilitiesindex ///
	askchild didnothing unknownmeds dispense prescribe refermi provseen


* Save Dataset

save "Data\SPDataset.dta", replace
