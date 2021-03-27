clear 
cap clear matrix
set more off
	
use "Data\PublicFacilitySurvey.dta", clear

replace s3q4=. if s3q4==0 | s3q4==15 | s3q4==17 // Designation
replace s3q8=. if s3q8==-99|s3q8==-77|s3q8==0 // Salary
drop if s3q4==7 // dropping 1 ASHA worker
tab s3q8 s3q4, m

gen desig=s3q4
gen salary=s3q8

replace desig=. if salary==.

recode desig (1=1) (2=1) (3=2) (4=2) (5=2) (6=3) (8=3) (9=4) (10=4) (11=5)
label define desiglab 1 "Doctor" 2 "GNM/ANM/VHN/LHV" 3 "MPW/MNA/Assistant/Compounder" 4 "Pharmacist/Chemist/Lab Assistant/ Technician" 5 "Paramedic/Other"
lab values desig desiglab

tab desig, gen(desig)
foreach x in desig1 desig2 desig3 desig4 desig5{
	bys phcid: egen total_`x'=sum(`x') // Total by facility
	}


* Number of facilities	
egen phctag=tag(phcid)
tab phctag	

* Provider count - NUMBER OF PROVIDERS
egen total = rowtotal(total_desig1 total_desig2 total_desig3 total_desig4 total_desig5)
tabstat total total_desig1 total_desig2 total_desig3 total_desig4 total_desig5 if phctag==1, stat(mean N)

* Average salary
tabstat salary, by(desig) // AVERAGE SALARY NUMBERS

* Total facility wage bill
bys phcid: egen monthlywagebill = sum(salary)

* Average monthly patients by year
recode s4q4a1 s4q4a2 s4q4a3 s4q4b1 s4q4b2 s4q4b3 s4q4c1 s4q4c2 s4q4c3 (-99=.) (-77=.)

egen yp_2010=rowtotal(s4q4a1 s4q4a2 s4q4a3), missing
egen yp_2009=rowtotal(s4q4b1 s4q4b2 s4q4b3), missing
egen yp_2008=rowtotal(s4q4c1 s4q4c2 s4q4c3), missing
gen mp_2010=yp_2010/12 if yp_2010!=. // Average number of patients per month
gen mp_2009=yp_2009/12 if yp_2009!=. // Average number of patients per month
gen mp_2008=yp_2008/12 if yp_2008!=. // Average number of patients per month

sum mp_2010 mp_2009 mp_2008 if phctag==1

gen cpp_2010 = monthlywagebill/mp_2010 if monthlywagebill!=. & mp_2010!=.
gen cpp_2009 = monthlywagebill/mp_2009 if monthlywagebill!=. & mp_2009!=.
gen cpp_2008 = monthlywagebill/mp_2008 if monthlywagebill!=. & mp_2008!=.

winsor cpp_2010, gen(cpp_2010_w) p(0.01) high
winsor cpp_2009, gen(cpp_2009_w) p(0.01) high
winsor cpp_2008, gen(cpp_2008_w) p(0.01) high

sum cpp_2010 cpp_2009 cpp_2008 if phctag==1 // Cost Per Patient
sum cpp_2010_w cpp_2009_w cpp_2008_w if phctag==1 // Cost Per Patient
