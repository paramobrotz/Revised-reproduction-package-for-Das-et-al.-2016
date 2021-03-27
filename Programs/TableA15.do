/*

Table A15: Correlates of prices charged

*/

set more off
use "Data\SPDataset", clear

* Referral variable for price regressions -- all referrals
g referaway_price=referaway
replace referaway_price=askchild if case==2
la var referaway_price "Referred/Asked to see child"

label var correct_uncond "Correct diagnosis (unconditional)"

local c1 "timespent percent_recqe"
local c2 "correct_uncond correct_treat helpful_treat wrong_treat" 
local c3 "dispense prescribe totalmeds"
local c4 "referaway_price"
local c5 "mbbs qual"
local c6 "numafter age gender"

ta didnothing
gen problem=0
replace problem=1 if totalmeds==unknownmeds & unknownmeds!=0
ta problem

count if didnothing==1 & ((round==1 & private==1)|(round==2 & private==1 & dual==1)) // 32 obs
count if problem==1 & ((round==1 & private==1)|(round==2 & private==1 & dual==1)) // 47 obs

drop if problem==1 // 57 observations

tempfile master 
save `master', replace


cap: estimates clear
use `master', clear
keep if round==1 & private==1

* Binary Regressions - ALL OBSERVATIONS
foreach var of varlist `c1' `c2' `c3' `c4' `c5' `c6' {
	areg price `var' case2 case3, clus(villid) robust absorb(distid)
	est store b1`var'
	}

xml_tab b1*, save("Output\TableA15.xml") replace sheet(TableA15A) font("garamond" 11) ///
	keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
			
cap: estimates clear			
* Multiple regressions with district fixed effects

	areg price `c1' case2 case3, clus(villid) robust absorb(distid)
	est store m1
	sum price if e(sample)==1
	mat m1m=r(mean)\r(sd)

	areg price `c1' `c2' case2 case3, clus(villid) robust absorb(distid)
	est store m2
	sum price if e(sample)==1
	mat m2m=r(mean)\r(sd)

	areg price `c1' `c2' `c3' case2 case3, clus(villid) robust absorb(distid)
	est store m3
	sum price if e(sample)==1
	mat m3m=r(mean)\r(sd)

	areg price `c1' `c2' `c3' `c4' case2 case3, clus(villid) robust absorb(distid)
	est store m4
	sum price if e(sample)==1
	mat m4m=r(mean)\r(sd)
	
	areg price `c1' `c2' `c3' `c4' `c5' case2 case3, clus(villid) robust absorb(distid)
	est store m5
	sum price if e(sample)==1
	mat m5m=r(mean)\r(sd)
	
	areg price `c1' `c2' `c3' `c4' `c5' `c6' case2 case3, clus(villid) robust absorb(distid)
	est store m6
	sum price if e(sample)==1
	mat m6m=r(mean)\r(sd)
	
xml_tab m1 m2 m3 m4 m5 m6, save("Output\TableA15.xml") append sheet(TableA15B) font("garamond" 11) ///
	keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=m1m,m2m,m3m,m4m,m5m,m6m
xml_tab means, save("Output\TableA15.xml") append sheet(TableA15B_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))



cap: estimates clear
use `master', clear
keep if round==2 & private==1 & dual==1

* Binary Regressions - ALL OBSERVATIONS
foreach var of varlist `c1' `c2' `c3' `c4' `c5' `c6' {
	areg price `var' case2 case3, clus(villid) robust absorb(distid)
	est store b1`var'
	}

xml_tab b1*, save("Output\TableA15.xml") append sheet(TableA15C) font("garamond" 11) ///
	keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
			
cap: estimates clear			
* Multiple regressions with district fixed effects

	areg price `c1' case2 case3, clus(villid) robust absorb(distid)
	est store m1
	sum price if e(sample)==1
	mat m1m=r(mean)\r(sd)

	areg price `c1' `c2' case2 case3, clus(villid) robust absorb(distid)
	est store m2
	sum price if e(sample)==1
	mat m2m=r(mean)\r(sd)

	areg price `c1' `c2' `c3' case2 case3, clus(villid) robust absorb(distid)
	est store m3
	sum price if e(sample)==1
	mat m3m=r(mean)\r(sd)

	areg price `c1' `c2' `c3' `c4' case2 case3, clus(villid) robust absorb(distid)
	est store m4
	sum price if e(sample)==1
	mat m4m=r(mean)\r(sd)
	
	areg price `c1' `c2' `c3' `c4' `c5' case2 case3, clus(villid) robust absorb(distid)
	est store m5
	sum price if e(sample)==1
	mat m5m=r(mean)\r(sd)
	
	areg price `c1' `c2' `c3' `c4' `c5' `c6' case2 case3, clus(villid) robust absorb(distid)
	est store m6
	sum price if e(sample)==1
	mat m6m=r(mean)\r(sd)
	
xml_tab m1 m2 m3 m4 m5 m6, save("Output\TableA15.xml") append sheet(TableA15D) font("garamond" 11) ///
	keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=m1m,m2m,m3m,m4m,m5m,m6m
xml_tab means, save("Output\TableA15.xml") append sheet(TableA15D_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))



cap: estimates clear
use `master', clear
keep if (round==1 & private==1)|(round==2 & private==1 & dual==1)

* Binary Regressions - ALL OBSERVATIONS
foreach var of varlist `c1' `c2' `c3' `c4' `c5' `c6' {
	areg price `var' case2 case3, clus(villid) robust absorb(distid)
	est store b1`var'
	}

xml_tab b1*, save("Output\TableA15.xml") append sheet(Table6E) font("garamond" 11) ///
	keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
			
cap: estimates clear			
* Multiple regressions with district fixed effects

	areg price `c1' case2 case3, clus(villid) robust absorb(distid)
	est store m1
	sum price if e(sample)==1
	mat m1m=r(mean)\r(sd)

	areg price `c1' `c2' case2 case3, clus(villid) robust absorb(distid)
	est store m2
	sum price if e(sample)==1
	mat m2m=r(mean)\r(sd)

	areg price `c1' `c2' `c3' case2 case3, clus(villid) robust absorb(distid)
	est store m3
	sum price if e(sample)==1
	mat m3m=r(mean)\r(sd)

	areg price `c1' `c2' `c3' `c4' case2 case3, clus(villid) robust absorb(distid)
	est store m4
	sum price if e(sample)==1
	mat m4m=r(mean)\r(sd)
	
	areg price `c1' `c2' `c3' `c4' `c5' case2 case3, clus(villid) robust absorb(distid)
	est store m5
	sum price if e(sample)==1
	mat m5m=r(mean)\r(sd)
	
	areg price `c1' `c2' `c3' `c4' `c5' `c6' case2 case3, clus(villid) robust absorb(distid)
	est store m6
	sum price if e(sample)==1
	mat m6m=r(mean)\r(sd)
	
xml_tab m1 m2 m3 m4 m5 m6, save("Output\TableA15.xml") append sheet(TableA15F) font("garamond" 11) ///
	keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
	
mat means=m1m,m2m,m3m,m4m,m5m,m6m
xml_tab means, save("Output\TableA15.xml") append sheet(TableA15F_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))

