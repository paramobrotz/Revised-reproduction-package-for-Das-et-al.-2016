clear 
set more off
cd "C:\Users\amohpal\Desktop\AER Submission\20151138_data"
clear
set more off

	use "Data\Paper2_PoExitDataset.dta", clear
	
	drop if round==1 & (distid==16|distid==24)
	

	preserve
		use "Data\Paper2_ProviderDataset.dta", clear
		keep finprovid finclinid age gender
		rename age provage
		label var provage "Age of Provider"
		rename gender provgender
		recode provgender 1=1 2=0
		label var provgender "Gender of Provider (1=Male)"
		tempfile provider
		save `provider', replace
	restore
	merge m:1 finprovid finclinid using `provider'
	drop if _m==2
	drop _m
	
	preserve
		use "Data\Paper2_SSPDataset_wIRT_final.dta", clear
		keep finprovid finclinid round dual haspublic hasboth
		rename round spround
		duplicates drop
		tempfile sp
		save `sp', replace
	restore
	merge m:1 finprovid finclinid using `sp'
	tab spround if _m==2 // For 105 providers we dont have POs, 41 from Round 1, 64 from Round 2
	gen sspyes=0
	replace sspyes=1 if _m==3
	drop spround _m
	
	preserve // Time spent by providers in the day
		bys finprovid finclinid: egen totaltime=sum(timespent)
		bys finprovid finclinid: gen totalpatients=_N
		bys finprovid finclinid: keep if _n==1
		gen private=public
		recode private 1=0 0=1
		lab def prilab 1 "Private" 0 "Public"
		la val private prilab
		la var private "Is a private provider"
		tabstat totaltime if round==1, by(private) stat(mean median p10 p90)
		tabstat totaltime if round==2, by(private) stat(mean median p10 p90)
		tabstat totalpatients if round==1, by(private) stat(mean median p10 p90)
		tabstat totalpatients if round==2, by(private) stat(mean median p10 p90)
	restore
		
	gen qual=0 if mbbs!=. & noqual!=.
	replace qual=1 if mbbs==0 & noqual==0
	label var qual "Has some qualification"
	
	* Days sick
	label var dayssick "Average days sick"

	* Patient Questions
	rename po_s4q1 questions
	label var questions "Number of patient questions"
	
	* Patient Education
	recode education 1=1 0=0 2/5=0 9=0
	label var education "Patient has no education"
	
	* Asset Index
	label var assetindex "Asset index (patient)"
	
	* This village
	recode thisvillage 1=100 0=0
	label var thisvillage "Patient from the village"
	
	* Came by foot
	recode ex_s1q8 -99=. 1=0 2=0 3=1 4=. 5=. 6=. 9=.
	rename ex_s1q8 byfoot
	label var byfoot "Patients came by foot"
	
	* ADL
	recode adl_dress adl_work adl_lift adl_walk (1=1) (2=0) (3=0)
		label var adl_dress "Patients that can easily dress themselves"
	label var adl_work "Patients that can easily do light work around the house"
	label var adl_lift "Patients that can lift a 5kg bucket and walk for 100m"
	label var adl_walk "Patients that can easily walk 200-300m"
	
	* Patient Symptoms
	foreach var in  fever cold diarrhea weakness injury vomitting dermatological pregnancy pain {
		label var `var' "Patient presenting with `var'"
		}
		
	* More variables
	label var totalquestions "Total questions asked by provider"
	rename po_s5a examination
	
	label var examination "Examination conducted (1=Yes)"
	
	rename po_s7q1 fees
	label var fees "Total charged"
	
	rename po_s6q14 referaway
	label var referaway "Referred to another provider"
	
	forvalues i=1/5{
		replace po_s6m`i'q1="" if po_s6m`i'q1=="-99"
		gen med`i'=0 if po_s6m`i'q1==""
		replace med`i'=1 if po_s6m`i'q1!=""
		}

	egen totalmeds=rowtotal(med1 med2 med3 med4 med5)
		
	* This was changed on 05082015 to say "medicines given/prescribed" 
	
	*gen dispense=0
	*replace dispense=1 if temp>.4 & temp!=. // Coded dispense if more than 50 percent of medicines dispensed
	
	gen dispense=0 if totalmeds==0
	replace dispense=1 if totalmeds!=0 & totalmeds!=.
	
	
	label var dispense "Dispensed medicine"
	
	label var mbbs "Has MBBS degree"
	label var public "Is a public provider"
	
	local controls = "dayssick questions education assetindex thisvillage byfoot adl_dress adl_work adl_lift adl_walk fever cold diarrhea weakness injury vomitting dermatological pregnancy pain"
	
	keep if sspyes==1
	replace villid=po_phcid if round==2
	
	gen private=public
	recode private 1=0 0=1
	lab def prilab 1 "Private" 0 "Public"
	la val private prilab
	la var private "Is a private provider"
	
	gen injection=po_s6q6a
	la var injection "Injection given"
	
	* 05082015
	
	replace distid=43 if villid==236 & dual==1 & round==2 & distid==.
	replace distid=24 if villid==318 & dual==1 & round==2 & distid==.

	
	
keep distid villid finprovid finclinid round dual `controls' private timespent totalquestions examination dispense totalmeds mbbs qual provage provgender newpatient ///
		age gender assetindex education questions thisvillage byfoot
	
save "Data\POData.dta", replace	
