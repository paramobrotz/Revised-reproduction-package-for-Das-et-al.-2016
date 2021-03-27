/*

Table 6: This do-file generates results for Table 6 of Paper

Produces four sub-tables: Panel A, Panel A means, Panel B, Panel C

*/

use "Data\SPDataset.dta", clear

local c1 "timespent percent_recqe"
local c2 "correct_uncond correct_treat helpful_treat wrong_treat"
local c3 "totalmeds_disp totalmeds_pres"
local c4 "referaway_askchild"
local c5 "mbbs qual"
local c6 "numafter age gender"

tempfile master 
save `master', replace



* Representative Sample

	cap: estimates clear
	use `master', clear
	keep if round==1 & private==1

	* Binary Regressions
	foreach var of varlist `c1' `c2' `c3' `c4' `c5' `c6' {
		areg price `var' case2 case3, clus(villid) robust absorb(distid)
		est store b1`var'
		}

	xml_tab b1*, save("Output\Table6.xml") replace sheet(Table6A) font("garamond" 11) ///
		keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))			
	cap: estimates clear			

	* Multiple regressions with district fixed effects
		
	areg price `c1' `c2' `c3' `c4' `c5' `c6' case2 case3, clus(villid) robust absorb(distid)
	est store m
	sum price if e(sample)==1
	mat mm=r(mean)\r(sd)
		
	xml_tab m, save("Output\Table6.xml") append sheet(Table6B) font("garamond" 11) ///
		keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
		
	mat means=mm
	xml_tab means, save("Output\Table6.xml") append sheet(Table6B_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))

* Dual Practice Sample

	cap: estimates clear
	use `master', clear
	keep if round==2 & private==1 & dual==1

	* Binary Regressions
	foreach var of varlist `c1' `c2' `c3' `c4' `c5' `c6' {
		areg price `var' case2 case3, clus(villid) robust absorb(distid)
		est store b1`var'
		}

	xml_tab b1*, save("Output\Table6.xml") append sheet(Table6C) font("garamond" 11) ///
		keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
				
	cap: estimates clear			
	* Multiple regressions with district fixed effects
		
	areg price `c1' `c2' `c3' `c4' `c5' `c6' case2 case3, clus(villid) robust absorb(distid)
	est store m
	sum price if e(sample)==1
	mat m6m=r(mean)\r(sd)
		
	xml_tab m, save("Output\Table6.xml") append sheet(Table6D) font("garamond" 11) ///
		keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
		
	mat means=mm
	xml_tab means, save("Output\Table6.xml") append sheet(Table6D_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))


* Pooled Sample

	cap: estimates clear
	use `master', clear
	keep if (round==1 & private==1)|(round==2 & private==1 & dual==1)

	* Binary Regressions
	foreach var of varlist `c1' `c2' `c3' `c4' `c5' `c6' {
		areg price `var' case2 case3, clus(villid) robust absorb(distid)
		est store b1`var'
		}

	xml_tab b1*, save("Output\Table6.xml") append sheet(Table6E) font("garamond" 11) ///
		keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
				
	cap: estimates clear			
	* Multiple regressions with district fixed effects
	
	areg price `c1' `c2' `c3' `c4' `c5' `c6' case2 case3, clus(villid) robust absorb(distid)
	est store m
	sum price if e(sample)==1
	mat mm=r(mean)\r(sd)
		
	xml_tab m, save("Output\Table6.xml") append sheet(Table6F) font("garamond" 11) ///
		keep(`c1' `c2' `c3' `c4' `c5' `c6' _cons) stats(r2 N) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
		
	mat means=mm
	xml_tab means, save("Output\Table6.xml") append sheet(Table6F_means) font("garamond" 11) format(SCLR0 (SCCR0 NCCR3 NCCR3))

