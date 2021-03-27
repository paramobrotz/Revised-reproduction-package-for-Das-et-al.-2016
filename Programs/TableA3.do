clear
set more off
	
	
	
use "Data\ProviderData2.dta", clear
drop if pvttype==.

	
* Make TABLE

mat table = J(16,4,.)

* Counts
count 
mat table[1,1]=r(N)
forvalues i=1/3{
	count if pvttype == `i'
	mat table[1,`i'+1]=r(N)
	}

* Degree Details

replace internship_duration = . if internship!=1

local j=3
foreach x in degreeduration internship internship_duration{
	replace `x'=0 if pvttype==3 & `x'==.
	forvalues i=1/3{
		sum `x'
		mat table[`j',1]=r(mean)
		sum `x' if pvttype == `i'
		mat table[`j',`i'+1]=r(mean)
		}
	local j=`j'+1
	}

* Additional Training

gen trainingduration_c = trainingduration if training_binary==1
gen trainingduration3_c = trainingduration if training3==1
gen trainingduration4_c = trainingduration if training4==1
gen trainingduration5_c = trainingduration if training5==1

local j=`j'+1
foreach x in training_binary trainingduration_c training3 trainingduration3_c training4 trainingduration4_c training5 trainingduration5_c{
	forvalues i=1/3{
		sum `x'
		mat table[`j',1]=r(mean)
		sum `x' if pvttype == `i'
		mat table[`j',`i'+1]=r(mean)
		}
	local j=`j'+1
	}

* Training Others
local j = `j'+1
forvalues i=1/3{
	sum trainedothers
	mat table[`j',1]=r(mean)
	sum trainedothers if pvttype == `i'
	mat table[`j',`i'+1]=r(mean)
	}
		
matlist table	

xml_tab table, ///
	save("Output\TableA3.xml") replace sheet(TableA3) format(SCLR0 (SCCR0 NCCR3 NCCR3))
