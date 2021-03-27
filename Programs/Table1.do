* Table 1. Health Market Attributes

set more off
use "Data\VillageDataset.dta", clear

	* Number of Providers
	gen np_cluster=np_market-np_location
	tabstat np_market np_location np_cluster if location==1, stat(mean median sd) save
	mat table1=r(StatTotal)
	
	tabstat np_market np_location np_cluster if location==1, stat(mean sd N) save
	mat ttest1=r(StatTotal)
	mat ttest1a=r(StatTotal)
	
	egen np_market_pubtotal=rowtotal(np_market_pubmbbs np_market_pubqual np_market_pubpara np_market_pubnoqual)
	egen np_market_pvttotal=rowtotal(np_market_pvtmbbs np_market_pvtqual np_market_pvtnoqual)
	
	egen np_location_pubtotal=rowtotal(np_location_pubmbbs np_location_pubqual np_location_pubpara np_location_pubnoqual)
	egen np_location_pvttotal=rowtotal(np_location_pvtmbbs np_location_pvtqual np_location_pvtnoqual)
	
	* Provider Counts
	
	foreach var in pubmbbs pubqual pubpara pubnoqual pubtotal pvtmbbs pvtqual pvtnoqual pvttotal{
	
		gen np_cluster_`var'=np_market_`var'-np_location_`var'
		tabstat np_market_`var' np_location_`var' np_cluster_`var' if location==1, stat(mean median sd) save
		mat table1=table1\r(StatTotal)
		
		tabstat np_market_`var' np_location_`var' np_cluster_`var' if location==1, stat(mean sd N) save
		mat ttest1=ttest1\r(StatTotal)
		
		gen temp1=np_market_`var'/np_market
		replace temp1=0 if temp1==.
		gen temp2=np_location_`var'/np_location
		replace temp2=0 if temp2==.
		gen temp3=np_cluster_`var'/np_cluster
		replace temp3=0 if temp3==.
		
		tabstat temp1 temp2 temp3 if location==1, stat(mean sd N) save
		mat ttest1a=ttest1a\r(StatTotal)
			
		drop temp1 temp2 temp3
		}
	
	count if np_market_pubmbbs==1|np_market_pvtmbbs==1
	count if np_market_pubmbbs==1
	count if np_market_pvtmbbs==1
	
	* Population
	sum population if location==1
	local avgpop=round(r(mean),0.01)
	di `avgpop'
	
		* Generate variables to indicate if market has public providers
		egen haspub_mkt=rowtotal(np_market_pubmbbs np_market_pubqual np_market_pubnoqual)
		recode haspub_mkt 0=0 *=1
		
		egen haspub_loc=rowtotal(np_location_pubmbbs np_location_pubqual np_location_pubnoqual)
		recode haspub_loc 0=0 *=1
		
		gen haspubmbbs_mkt=np_market_pubmbbs
		gen haspubmbbs_loc=np_location_pubmbbs
		recode haspubmbbs_mkt haspubmbbs_loc (0=0) (*=1)
		
		keep villid location haspub_mkt haspub_loc haspubmbbs_mkt haspubmbbs_loc
		recode location 1=1 *=2
		collapse (max) haspub_mkt haspub_loc haspubmbbs_mkt haspubmbbs_loc, by(villid location)
		
		reshape wide haspub_loc haspubmbbs_loc, i(villid) j(location)
		replace haspub_loc2=0 if haspub_loc2==.
		replace haspubmbbs_loc2=0 if haspubmbbs_loc2==.
		rename haspub_loc1 haspub_inside
		rename haspub_loc2 haspub_outside
		rename haspubmbbs_loc1 haspubmbbs_inside
		rename haspubmbbs_loc2 haspubmbbs_outside
		tempfile haspub
		save `haspub', replace
	
	* Fraction of households that visited a provider in last 30 days
		
	use "Data\HouseholdDataset.dta", clear
	egen hhtag=tag(villid hhid)
	count if hhtag==1
	local households=r(N)
	local avghh=round(`households'/100,0.01)
	
	merge m:1 villid using `haspub'
	drop _m
	
	rename s2q18 visit
	replace visit=1 if visit==0 & (finprovid!=.|finclinid!=.) // 119 observations
	
	count if hhtag==1
	local totalhh=r(N)
	count if visit==1
	local totalvisits=r(N)
	local avgvisits=round(`totalvisits'/`households',0.01)
	di `avgvisits'
	di `totalvisits'
	di `households'

	gen x=. // blank variables just to get the right matrix size
	gen y=.
	bys villid hhid: egen visit_hh=max(visit)
	tabstat visit_hh x y if hhtag==1, stat(mean sd) save 
	mat table1=table1\r(StatTotal)
	
	* Visit Inside or Outside
	keep if visit==1
	renpfix "" hh_
	rename hh_finprovid finprovid
	rename hh_finclinid finclinid
	rename hh_villid villid
	rename hh_visit visit
	rename hh_haspub_mkt haspub
	rename hh_haspub_inside haspub_inside
	rename hh_haspub_outside haspub_outside
	rename hh_haspubmbbs_mkt haspubmbbs
	rename hh_haspubmbbs_inside haspubmbbs_inside
	rename hh_haspubmbbs_outside haspubmbbs_outside
	merge m:1 finprovid finclinid using "Data\ProviderData.dta", gen(join)
	sum finprovid finclinid if join==1 // 15 unmatched observations (wrong IDs) remaining unidentified providers, dropping the 485 unindentified visits
	keep if join==3

	gen total=1
	
	gen inside=1 if location==1
	replace inside=0 if (location==2|location==3|location==4)
	
	gen outside=0 if location==1
	replace outside=1 if (location==2|location==3|location==4)
	
	gen x=. // blank variables just to get the right matrix size
	tabstat x inside outside, stat(mean sd) save
	mat table1=table1\r(StatTotal)
	
	* Distance traveled to visit provider
	sum hh_distance, d
	local trim=r(p95)
	
	gen dist_total=hh_distance if hh_distance<=`trim' & inside!=.
	gen dist_inside=hh_distance if hh_distance<=`trim' & inside==1 
	gen dist_outside=hh_distance if hh_distance<=`trim' & outside==1 	
	tabstat dist_total dist_inside dist_outside, stat(mean sd) save
	mat table1=table1\r(StatTotal)
	
	
			* This part is for distance Table A10
			sum hh_distance if hh_distance<=`trim' & mbbs==1 & public==1
			sum hh_distance if hh_distance<=`trim' & mbbs==1 & public==0
			

	* Fraction visits to MBBS doctors
	gen total_mbbs=0 if mbbs==0
	replace total_mbbs=1 if mbbs==1
	gen inside_mbbs=0 if mbbs==0 & inside==1
	replace inside_mbbs=1 if mbbs==1 & inside==1
	gen outside_mbbs=0 if mbbs==0 & outside==1
	replace outside_mbbs=1 if mbbs==1 & outside==1

	tabstat total_mbbs inside_mbbs outside_mbbs, stat(mean sd) save
	mat table1=table1\r(StatTotal)
	
	* Fraction visits to private
	gen pvt_total=0 if public==1
	replace pvt_total=1 if public==0
	gen pvt_inside=0 if public==1 & inside==1
	replace pvt_inside=1 if public==0 & inside==1
	gen pvt_outside=0 if public==1 & outside==1
	replace pvt_outside=1 if public==0 & outside==1

	tabstat pvt_total pvt_inside pvt_outside, stat(mean sd) save
	mat table1=table1\r(StatTotal)
	
	* Fraction visits to private conditional on public in market/location
	drop pvt_total pvt_inside pvt_outside
	
	gen pvt_total=0 if public==1 & haspub==1
	replace pvt_total=1 if public==0 & haspub==1
	gen pvt_inside=0 if public==1 & inside==1 & haspub_inside==1
	replace pvt_inside=1 if public==0 & inside==1 & haspub_inside==1
	gen pvt_outside=0 if public==1 & outside==1 & haspub_outside==1
	replace pvt_outside=1 if public==0 & outside==1 & haspub_outside==1

	tabstat pvt_total pvt_inside pvt_outside, stat(mean sd) save
	mat table1=table1\r(StatTotal)

	* Fraction visits to private conditional on public MBBS in market/location
	drop pvt_total pvt_inside pvt_outside
	
	gen pvt_total=0 if public==1 & haspubmbbs==1
	replace pvt_total=1 if public==0 & haspubmbbs==1
	gen pvt_inside=0 if public==1 & inside==1 & haspubmbbs_inside==1
	replace pvt_inside=1 if public==0 & inside==1 & haspubmbbs_inside==1
	gen pvt_outside=0 if public==1 & outside==1 & haspubmbbs_outside==1
	replace pvt_outside=1 if public==0 & outside==1 & haspubmbbs_outside==1

	tabstat pvt_total pvt_inside pvt_outside, stat(mean sd) save
	mat table1=table1\r(StatTotal)

	* Fraction visits to Unqualified doctors
	gen total_noqual=0 if noqual==0
	replace total_noqual=1 if noqual==1
	gen inside_noqual=0 if noqual==0 & inside==1
	replace inside_noqual=1 if noqual==1 & inside==1
	gen outside_noqual=0 if noqual==0 & outside==1
	replace outside_noqual=1 if noqual==1 & outside==1

	tabstat total_noqual inside_noqual outside_noqual, stat(mean sd) save
	mat table1=table1\r(StatTotal)
	
	* Fraction visits to Unqualified doctors conditional on public in market/location
	drop total_noqual inside_noqual outside_noqual
	gen total_noqual=0 if noqual==0 & haspub==1
	replace total_noqual=1 if noqual==1 & haspub==1
	gen inside_noqual=0 if noqual==0 & inside==1 & haspub_inside==1
	replace inside_noqual=1 if noqual==1 & inside==1 & haspub_inside==1
	gen outside_noqual=0 if noqual==0 & outside==1 & haspub_outside==1
	replace outside_noqual=1 if noqual==1 & outside==1 & haspub_outside==1
	tabstat total_noqual inside_noqual outside_noqual, stat(mean sd) save
	mat table1=table1\r(StatTotal)

	* Fraction visits to Unqualified doctors conditional on public MBBS in market/location
	drop total_noqual inside_noqual outside_noqual
	gen total_noqual=0 if noqual==0 & haspubmbbs==1
	replace total_noqual=1 if noqual==1 & haspubmbbs==1
	gen inside_noqual=0 if noqual==0 & inside==1 & haspubmbbs_inside==1
	replace inside_noqual=1 if noqual==1 & inside==1 & haspubmbbs_inside==1
	gen outside_noqual=0 if noqual==0 & outside==1 & haspubmbbs_outside==1
	replace outside_noqual=1 if noqual==1 & outside==1 & haspubmbbs_outside==1
	tabstat total_noqual inside_noqual outside_noqual, stat(mean sd) save
	mat table1=table1\r(StatTotal)	
	
	mat stats=[100\ `avgpop'\ `avghh'\ `totalvisits'\ `avgvisits'],[.\.\.\.\.],[.\.\.\.\.]
	mat table1=table1\stats
	
	
	
	* SP SAMPLED VILLAGES - i.e. 46 Villages
	use "Data\VillageDataset.dta", clear
	keep if distid==4|distid==30|distid==43
	drop if inlist(villid,1,3,4,6,10,12,17,18,25,37,40,46,47,59)
	
	* Number of Providers
	gen np_cluster=np_market-np_location
	tabstat np_market np_location np_cluster if location==1, stat(mean median sd) save
	mat table3=r(StatTotal)
	
	tabstat np_market np_location np_cluster if location==1, stat(mean sd N) save
	mat ttest2=r(StatTotal)
	mat ttest2a=r(StatTotal)
	
	egen np_market_pubtotal=rowtotal(np_market_pubmbbs np_market_pubqual np_market_pubpara np_market_pubnoqual)
	egen np_market_pvttotal=rowtotal(np_market_pvtmbbs np_market_pvtqual np_market_pvtnoqual)
	
	egen np_location_pubtotal=rowtotal(np_location_pubmbbs np_location_pubqual np_location_pubpara np_location_pubnoqual)
	egen np_location_pvttotal=rowtotal(np_location_pvtmbbs np_location_pvtqual np_location_pvtnoqual)
	

	* Provider Counts
	foreach var in pubmbbs pubqual pubpara pubnoqual pubtotal pvtmbbs pvtqual pvtnoqual pvttotal{
		gen np_cluster_`var'=np_market_`var'-np_location_`var'
		tabstat np_market_`var' np_location_`var' np_cluster_`var' if location==1, stat(mean median sd) save
		mat table3=table3\r(StatTotal)
		
		tabstat np_market_`var' np_location_`var' np_cluster_`var' if location==1, stat(mean sd N) save
		mat ttest2=ttest2\r(StatTotal)
		
		gen temp1=np_market_`var'/np_market
		replace temp1=0 if temp1==.
		gen temp2=np_location_`var'/np_location
		replace temp2=0 if temp2==.
		gen temp3=np_cluster_`var'/np_cluster
		replace temp3=0 if temp3==.
		
		tabstat temp1 temp2 temp3 if location==1, stat(mean sd N) save
		mat ttest2a=ttest2a\r(StatTotal)
			
		drop temp1 temp2 temp3
		}
	
	count if np_market_pubmbbs==1|np_market_pvtmbbs==1
	count if np_market_pubmbbs==1
	count if np_market_pvtmbbs==1
		
	* Population
	sum population if location==1
	local avgpop=round(r(mean),0.01)
	di `avgpop'
		
	* Fraction of households that visited a provider in last 30 days
		
	use "Data\HouseholdDataset.dta", clear
	keep if distid==4|distid==30|distid==43
	drop if inlist(villid,1,3,4,6,10,12,17,18,25,37,40,46,47,59)
	merge m:1 villid using `haspub'
	drop if _m==2
	drop _m
		
	egen hhtag=tag(villid hhid)
	count if hhtag==1
	local households=r(N)
	local avghh=round(`households'/46,0.01)
	
	rename s2q18 visit
	replace visit=1 if visit==0 & (finprovid!=.|finclinid!=.) // 119 observations
	
	count if hhtag==1
	local totalhh=r(N)
	count if visit==1
	local totalvisits=r(N)
	local avgvisits=round(`totalvisits'/`households',0.01)
	
	gen x=. // blank variables just to get the right matrix size
	gen y=.
	bys villid hhid: egen visit_hh=max(visit)
	tabstat visit_hh x y if hhtag==1, stat(mean sd) save 
	mat table3=table3\r(StatTotal)
	
	* Visit Inside or Outside
	keep if visit==1
	renpfix "" hh_
	rename hh_finprovid finprovid
	rename hh_finclinid finclinid
	rename hh_villid villid
	rename hh_visit visit
	rename hh_haspub_mkt haspub
	rename hh_haspub_inside haspub_inside
	rename hh_haspub_outside haspub_outside
	rename hh_haspubmbbs_mkt haspubmbbs
	rename hh_haspubmbbs_inside haspubmbbs_inside
	rename hh_haspubmbbs_outside haspubmbbs_outside
	merge m:1 finprovid finclinid using "Data\ProviderData.dta", gen(join)
	sum finprovid finclinid if join==1 // 15 unmatched observations (wrong IDs) remaining unidentified providers, dropping the 485 unindentified visits
	keep if join==3

	gen total=1
	
	gen inside=1 if location==1
	replace inside=0 if (location==2|location==3|location==4)
	
	gen outside=0 if location==1
	replace outside=1 if (location==2|location==3|location==4)
	
	gen x=. // blank variables just to get the right matrix size
	tabstat x inside outside, stat(mean sd) save
	mat table3=table3\r(StatTotal)
	
	* Distance traveled to visit provider
	sum hh_distance, d
	local trim=r(p95)
	
	gen dist_total=hh_distance if hh_distance<=`trim' & inside!=.
	gen dist_inside=hh_distance if hh_distance<=`trim' & inside==1 
	gen dist_outside=hh_distance if hh_distance<=`trim' & outside==1 	
	tabstat dist_total dist_inside dist_outside, stat(mean sd) save
	mat table3=table3\r(StatTotal)
	
	sum dist_total if m_public==1 // These go into Appendix Table 12
	sum dist_total if m_public==0
	
	* Fraction visits to MBBS doctors
	gen total_mbbs=0 if mbbs==0
	replace total_mbbs=1 if mbbs==1
	gen inside_mbbs=0 if mbbs==0 & inside==1
	replace inside_mbbs=1 if mbbs==1 & inside==1
	gen outside_mbbs=0 if mbbs==0 & outside==1
	replace outside_mbbs=1 if mbbs==1 & outside==1

	tabstat total_mbbs inside_mbbs outside_mbbs, stat(mean sd) save
	mat table3=table3\r(StatTotal)
	
	* Fraction visits to private
	gen pvt_total=0 if public==1
	replace pvt_total=1 if public==0
	gen pvt_inside=0 if public==1 & inside==1
	replace pvt_inside=1 if public==0 & inside==1
	gen pvt_outside=0 if public==1 & outside==1
	replace pvt_outside=1 if public==0 & outside==1

	tabstat pvt_total pvt_inside pvt_outside, stat(mean sd) save
	mat table3=table3\r(StatTotal)

	* Fraction visits to private conditional on public in market/location
	drop pvt_total pvt_inside pvt_outside
	
	gen pvt_total=0 if public==1 & haspub==1
	replace pvt_total=1 if public==0 & haspub==1
	gen pvt_inside=0 if public==1 & inside==1 & haspub_inside==1
	replace pvt_inside=1 if public==0 & inside==1 & haspub_inside==1
	gen pvt_outside=0 if public==1 & outside==1 & haspub_outside==1
	replace pvt_outside=1 if public==0 & outside==1 & haspub_outside==1

	tabstat pvt_total pvt_inside pvt_outside, stat(mean sd) save
	mat table3=table3\r(StatTotal)

	* Fraction visits to private conditional on public in market/location
	drop pvt_total pvt_inside pvt_outside
	
	gen pvt_total=0 if public==1 & haspubmbbs==1
	replace pvt_total=1 if public==0 & haspubmbbs==1
	gen pvt_inside=0 if public==1 & inside==1 & haspubmbbs_inside==1
	replace pvt_inside=1 if public==0 & inside==1 & haspubmbbs_inside==1
	gen pvt_outside=0 if public==1 & outside==1 & haspubmbbs_outside==1
	replace pvt_outside=1 if public==0 & outside==1 & haspubmbbs_outside==1

	tabstat pvt_total pvt_inside pvt_outside, stat(mean sd) save
	mat table3=table3\r(StatTotal)	

	* Fraction visits to Unqualified doctors
	gen total_noqual=0 if noqual==0
	replace total_noqual=1 if noqual==1
	gen inside_noqual=0 if noqual==0 & inside==1
	replace inside_noqual=1 if noqual==1 & inside==1
	gen outside_noqual=0 if noqual==0 & outside==1
	replace outside_noqual=1 if noqual==1 & outside==1

	tabstat total_noqual inside_noqual outside_noqual, stat(mean sd) save
	mat table3=table3\r(StatTotal)
	
	* Fraction visits to Unqualified doctors conditional on public in market/location
	drop total_noqual inside_noqual outside_noqual
	gen total_noqual=0 if noqual==0 & haspub==1
	replace total_noqual=1 if noqual==1 & haspub==1
	gen inside_noqual=0 if noqual==0 & inside==1 & haspub_inside==1
	replace inside_noqual=1 if noqual==1 & inside==1 & haspub_inside==1
	gen outside_noqual=0 if noqual==0 & outside==1 & haspub_outside==1
	replace outside_noqual=1 if noqual==1 & outside==1 & haspub_outside==1
	tabstat total_noqual inside_noqual outside_noqual, stat(mean sd) save
	mat table3=table3\r(StatTotal)

	* Fraction visits to Unqualified doctors conditional on public MBBS in market/location
	drop total_noqual inside_noqual outside_noqual
	gen total_noqual=0 if noqual==0 & haspubmbbs==1
	replace total_noqual=1 if noqual==1 & haspubmbbs==1
	gen inside_noqual=0 if noqual==0 & inside==1 & haspubmbbs_inside==1
	replace inside_noqual=1 if noqual==1 & inside==1 & haspubmbbs_inside==1
	gen outside_noqual=0 if noqual==0 & outside==1 & haspubmbbs_outside==1
	replace outside_noqual=1 if noqual==1 & outside==1 & haspubmbbs_outside==1
	tabstat total_noqual inside_noqual outside_noqual, stat(mean sd) save
	mat table3=table3\r(StatTotal)
		
	
	mat stats=[46\ `avgpop'\ `avghh'\ `totalvisits'\ `avgvisits'],[.\.\.\.\.],[.\.\.\.\.]
	mat table3=table3\stats
	
	
	mat table=table1, table3
	
		
	xml_tab table, save("Output\Table1.xml") append sheet(Table1) font("garamond" 11) ///
		showeq ceq("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)") ///
		cnames("Total" "Inside village" "Outside village" "Total" "Inside village" "Outside village") ///
		rnames("Total (mean)" "Total (median)" " " "Public MBBS (mean)" "Public MBBS (median)" " " ///
			"Public alternative qualification (mean)" "Public alternative qualification (median)" " " ///
			"Public paramedical (mean)" "Public paramedical (median)" " " "Public unqualified (mean)" "Public unqualified (median)" " " "Public total (mean)" "Public total (median)" " " ///
			"Private MBBS (mean)" "Private MBBS (median)" " " "Private alternative qualification (mean)" "Private alternative qualification (median)" " " ///
			"Private unqualified (mean)" "Private unqualified (median)" " " "Private total (mean)" "Private total (median)" " "  ///
			"Fraction of households that visited a provider in last 30 days" " " "Fraction provider visits inside/outside village" " " ///
			"Distance traveled to visited provider (km)" " " ///
			"Fraction of visits to MBBS doctor" " " "Fraction of visits to private sector" " " "Fraction of visits to private sector (conditional on public)" " " ///
			"Fraction of visits to private sector (conditional on Public MBBS)" " " ///
			"Fraction of visits to unqualified providers" " " "Fraction of visits to unqualified providers (conditional on public)" " " ///
			"Fraction of visits to unqualified providers (conditional on Public MBBS)" " " ///
			"Number of villages" "Village population" "Households per village" "Total provider visits in last one month" "Average provider visits in last one month") ///
		rblanks(0 "Panel A: Number of providers" SCLB0, 24 "Panel B: Composition of demand" SCLB0, 44 "Panel C: Sample size" SCLB0) ///	
			title("Table 1: Health market attributes") mv("") ///
		cwidth(0 180, 1 60, 2 60, 3 60) format(SCLR0 (SCCB0 NCCR2 NCCR2)) ///
		notes("Notes:", ///
			"1) Standard deviations in parentheses", ///
			"2) The number of providers available to a village was determined by a provider census, which surveyed all providers in all locations mentioned by households in 100 sample villages, when asked where they seek care for primary care services, regardless of whether or not the particular provider was mentioned by households", ///
			"3) Unqualified providers report no medical training. All others have training that ranges from a correspondence course to a medical degree", ///
			"4) 'Outside villages' are typically adjacent villages or villages connected by a major road", ///
			"5)The 30-day visit rate was calculated from visits to providers reported by households in a complete census of households in the 100 sample villages. The type of provider they visited was determined by matching reported providers to providers surveyed in the provider census")					

			
	
