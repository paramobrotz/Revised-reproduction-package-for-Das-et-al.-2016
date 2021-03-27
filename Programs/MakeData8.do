clear
set more off 
clear 
cap clear matrix
set mem 400m
set matsize 5000
set more off
cap: log clos
cd "C:\Users\amohpal\Desktop\AER Submission\20151138_data"

use "Data\Paper2_VillageDataset.dta", clear
keep distid villid np_market np_location location ///
	np_market_pubmbbs np_market_pubqual np_market_pubpara np_market_pubnoqual ///
	np_market_pvtmbbs np_market_pvtqual np_market_pvtnoqual ///
	np_location_pubmbbs np_location_pubqual np_location_pubpara np_location_pubnoqual ///
	np_location_pvtmbbs np_location_pvtqual np_location_pvtnoqual population
	
save "Data\VillageDataset.dta", replace


use "Data\Paper2_HouseholdDataset1.dta", clear
keep distid villid hhid s2q18 ///
	finprovid finclinid distance

save "Data\HouseholdDataset.dta", replace	
