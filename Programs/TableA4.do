/*

Table A4: Randomization Balance for dual sample providers' assignment of Unstable Angina Cases

*/

use "Data\SPDataset.dta", clear
keep if round==2 & dual==1

foreach var in timespent percent_recqe correct_treat helpful_treat wrong_treat said_diagnosis correct_diag {
	
	gen temp=`var' if case==2
	bys finprovid finclinid: egen c2_`var'=max(temp)
	drop temp
	
	gen temp=`var' if case==3
	bys finprovid finclinid: egen c3_`var'=max(temp)
	drop temp
	
	}
	
	
bys finprovid finclinid: keep if _n==1
keep finprovid finclinid c3_timespent c3_percent_recqe c3_said_diagnosis c3_correct_diag c3_correct_treat c3_helpful_treat c3_wrong_treat c2_timespent c2_percent_recqe
tempfile temp
save `temp', replace

use "Data\ProviderData.dta", clear
keep if round==2
merge 1:1 finprovid finclinid using `temp', gen(merge)

gen temp1=1 if m_ssp1_c==1 & m_public==1
replace temp1=0 if m_ssp1_c==1 & m_public==0

gen temp2=1 if m_ssp1_c==1 & m_public==0
replace temp2=0 if m_ssp1_c==1 & m_public==1	

bys finprovid: egen mipublic=max(temp1)
bys finprovid: egen miprivate=max(temp2)

gen private=m_public==0
gen inter=private*miprivate

label var private "Is private"
label var miprivate "Received Unstable Angina in private"
label var inter "(Is private) x (Received Unstable Angina in private)"

estimates clear
local i=1	
foreach var in c3_timespent c3_percent_recqe c3_said_diagnosis c3_correct_diag c3_correct_treat c3_helpful_treat c3_wrong_treat c2_timespent c2_percent_recqe {
	
	areg `var' private miprivate inter, absorb(distid)
	est sto r`i'
	local i=`i'+1
	
	}
	
xml_tab r1 r2 r3 r4 r5 r6 r7 r8 r9, save("Output\TableA4.xml") replace below sheet(TableA4) font("garamond" 11) ///
	format(SCLR0 (SCCB0 NCCR3 NCCR3))
