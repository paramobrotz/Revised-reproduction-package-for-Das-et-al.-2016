clear
set more off 
clear 
cap clear matrix
set mem 400m
set matsize 5000
set more off
cap: log clos
cd "C:\Users\amohpal\Desktop\AER Submission\20151138_data"


* Table 2: Characteristics of providers and practices	
* This do-file produces one single table. Note that "fees" statistics come from PO data. The do-file first uses Census data to produce (incorrect) fees statistics. It later replaces them with PO data.	
set more off	
	
	* Import data, keep only data from three SP districts for the representative sample
	use "Data\Paper2_ProviderDataset.dta", clear
	drop if m_eligible==0
	drop if m_round==1 & (distid==16|distid==24)
	rename m_round round
	
	preserve
		use "Data\Paper2_SSPDataset_wIRT_final.dta", clear
		keep finprovid finclinid
		duplicates drop
		drop if finprovid==-99 | finprovid==.
		tempfile spcomplete
		save `spcomplete', replace
	restore
	
	merge 1:1 finprovid finclinid using `spcomplete'
	gen spcomplete=1 if _m==3
	replace spcomplete=0 if _m!=3
	drop _m
	la var spcomplete "At least one SP completed"
	
	cap: drop age
	rename m_age age 
	label var age "Age of Provider"
	
	cap: drop education
	rename m_education education
	recode education 1=0 2=0 3=1
	label var education "More than 12 years of basic education"
	
	label var mbbs "Has MBBS degree"
	label var otherqual "Has alternative qualification"
	label var noqual "No medical training"
	
	* Training from another source
	gen training = 1 if s3q14 == 0 // None
	replace training = 2 if s3q14 == 1 // Family Member
	replace training = 3 if s3q14 == 2 | s3q14 == 4 // Practicising Physician or Learned by Observation
	replace training = 4 if s3q14 == 6 // Compounder or Learned by Observation
	replace training = 5 if s3q14 == 3 | s3q14 == 7 // Another Institution or Hospital
	replace training = 6 if s3q14 == 8 | s3q14 == 9 | s3q14 == 10 | s3q14 == 5 | s3q14 == 12 // ANM/MPW/ASHA or Pharmacist or Other

	gen training_binary = training
	recode training_binary 1=0 2=1 3=1 4=1 5=1 6=1 *=.

	gen nclinics=m_nclinics
	label var nclinics "Has multiple clinics"
	
	label var pracyears "Provider tenure in current location"
	label var dispmed "Dispenses medicine"
	
	label var feewomed "Provider consultation fees (Rs.)"

	egen spsampled=rowmax(m_ssp1_s m_ssp2_s m_ssp3_s)
	replace spsampled=1 if m_ssp==1 & round==1
	
	* Dual variable: for Round 2 only
	bys finprovid: egen temp=mean(public) if round==2
	gen dual=0 if temp==1 & round==2
	replace dual=1 if (temp>0 & temp<1) & round==2
	drop temp
	
	
* T-test of fees - comes from PO data	

	preserve
		use "Data\Paper2_PoExitDataset.dta", clear
		drop if round==1 & (distid==16|distid==24)
		
		bys finprovid finclinid: egen fees = mean(po_s7q1)
		la var fees "Fees in POs"
		
		bys finprovid finclinid: gen patients=_N
		label var patients "Patients per day in POs"
		bys finprovid finclinid: keep if _n==1
		
		tempfile po
		save `po', replace
	restore
	
	merge 1:1 finprovid finclinid using `po'
	
	gen male=1 if gender==1
	replace male=0 if gender==2
	
keep distid finprovid finclinid round public spcomplete dual qual age male ///
	education mbbs otherqual noqual training_binary nclinics pracyears dispmed ///
	fees patperday patients electricity stethoscope bpmachine thermometer scale handwash ///
	m_ssp1_c m_public location
	
	
save "Data\ProviderData.dta", replace
