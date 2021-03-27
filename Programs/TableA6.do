/*

Table A6: List of Checklist Items Used in the Treatment of SPs

*/

	use "Data\SPDataset.dta", clear

	/*
	
	Discrimination
	
	egen rec1=rowtotal(c1h2 c2h1 c2h2 c2h8 c2h9 c3h2 c3h3 c3h8 c3h14 c3h15 c3e1 c3e2 c3e3 c3e5)
	egen rec2=rowtotal(c1h4 c1h6 c1h7 c1h10 c1h22 c1e1 c1e3 c2h7 c3h1 c3h5 c3h6 c3h9 c3h21)
	egen rec3=rowtotal(c1h1 c1h11 c1h12 c1e2 c1e4 ekg c2h3 c2h4 c2h13 c2h14 c3h12 c3h17 c3h19)
	egen rec4=rowtotal(c1h3 c1h5 c1h9 c1h13 c1h25 c2h5 c2h6 c2h11 c3h4 c3h7 c3h10 c3h13 c3h16)
	
	Difficulty
	
	egen rec1a=rowtotal(c1h1 c1h6 c1h12 c1h13 c1e1 c1e3 ekg c2h1 c3h1 c3h2 c3h4 c3h6 c3e1 c3e3)
	egen rec2a=rowtotal(c1h2 c1h4 c1h5 c1h7 c1h9 c2h3 c3h5 c3h9 c3h13 c3h14 c3h15 c3e2) // Note that c2h1 actually belongs to the second quantile
	egen rec3a=rowtotal(c1h3 c1h10 c1h11 c1h22 c1e4 c2h2 c2h7 c2h8 c2h9 c3h3 c3h7 c3h8 c3h10)
	egen rec4a=rowtotal(c1h25 c2h4 c2h5 c2h6 c2h11 c2h13 c2h14 c3h12 c2h16 c3h17 c3h19 c3h21 c3e5) 	
	
	*/
	
	local items "c1h1 c1h2 c1h3 c1h4 c1h5 c1h6 c1h7 c1h9 c1h10 c1h11 c1h12 c1h13 c1h22 c1h25 c1e1 c1e2 c1e3 c1e4 ekg c2h1 c2h2 c2h3 c2h4 c2h5 c2h6 c2h7 c2h8 c2h9 c2h11 c2h13 c2h14 c3h1 c3h2 c3h3 c3h4 c3h5 c3h6 c3h7 c3h8 c3h9 c3h10 c3h12 c3h13 c3h14 c3h15 c3h16 c3h17 c3h19 c3h21 c3e1 c3e2 c3e3 c3e5"
	
	foreach var in `items' {	
		
		* Audit 1
		
		sum `var' if round==1
		local u1=r(mean)
		ttest `var' if round==1, by(public)
		local m1=r(mu_2)
		local m2=r(mu_1)
		local d1=`m2'-`m1'
		
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star1=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star1=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star1=3
				}
			else if `pval'>0.1 {
				local star1=0
				}	
		
		* Dual sample
		
		sum `var' if round==2 & dual==1
		local u3=r(mean)
		ttest `var' if round==2 & dual==1, by(public)
		local m3=r(mu_2)
		local m4=r(mu_1)
		local d2=`m4'-`m3'
		
			local pval=min(`r(p_u)', `r(p_l)', `r(p)')
			if `pval'<.01{
				local star2=1
				}
			else if `pval'>0.01 & `pval'<.05 {
				local star2=2
				}
			else if `pval'>0.05 & `pval'<.1 {
				local star2=3
				}
			else if `pval'>0.1 {
				local star2=0
				}	
		
	
		mat `var'=[`u1',`m1',`m2',`d1',.,`u3',`m3',`m4',`d2']	
		mat `var'_STARS=[.,.,.,`star1',.,.,.,.,`star2']	
		
		}

	* Number of observations

		forvalues i=1/3{
			
			qui: count if round==1 & case==`i'
			local c`i'k1=r(N)
			qui: count if round==1 & public==1 & case==`i' // Audit 1 Public
			local c`i'n1=r(N)
			qui: count if round==1 & public==0 & case==`i' // Audit 1 Private
			local c`i'n2=r(N)
			
			qui: count if round==2 & dual==1 & case==`i'
			local c`i'k3=r(N)
			qui: count if round==2 & public==1 & dual==1 & case==`i' // Dual Public
			local c`i'n3=r(N)
			qui: count if round==2 & public==0 & dual==1 & case==`i' // Dual Private
			local c`i'n4=r(N)	
			
			mat n`i'=[`c`i'k1',`c`i'n1',`c`i'n2',.,.,`c`i'k3',`c`i'n3',`c`i'n4',.]
		
			}	
		
	forvalues i=1/3{
		mat n`i'_STARS=[.,.,.,.,.,.,.,.,.]
		}
		
	mat table=n1
	mat table_STARS=n1_STARS
	local items2 "c1h1 c1h2 c1h3 c1h4 c1h5 c1h6 c1h7 c1h9 c1h10 c1h11 c1h12 c1h13 c1h22 c1h25 c1e1 c1e2 c1e3 c1e4 ekg n2 c2h1 c2h2 c2h3 c2h4 c2h5 c2h6 c2h7 c2h8 c2h9 c2h11 c2h13 c2h14 n3 c3h1 c3h2 c3h3 c3h4 c3h5 c3h6 c3h7 c3h8 c3h9 c3h10 c3h12 c3h13 c3h14 c3h15 c3h16 c3h17 c3h19 c3h21 c3e1 c3e2 c3e3 c3e5"
		
	foreach var in `items2'{
		mat table=table\ `var'
		mat table_STARS=table_STARS\ `var'_STARS
		}	

	cap drop asthma
	gen mi=.
	label var mi "MI (number of observations)	
	gen dysentery=.
	label var dysentery "Dysentery (number of observations)
	gen asthma=.
	label var asthma "Asthma (number of observations)
		
	local items3 "mi c1h1 c1h2 c1h3 c1h4 c1h5 c1h6 c1h7 c1h9 c1h10 c1h11 c1h12 c1h13 c1h22 c1h25 c1e1 c1e2 c1e3 c1e4 ekg dysentery c2h1 c2h2 c2h3 c2h4 c2h5 c2h6 c2h7 c2h8 c2h9 c2h11 c2h13 c2h14 asthma c3h1 c3h2 c3h3 c3h4 c3h5 c3h6 c3h7 c3h8 c3h9 c3h10 c3h12 c3h13 c3h14 c3h15 c3h16 c3h17 c3h19 c3h21 c3e1 c3e2 c3e3 c3e5"
	foreach x in `items3' {
		local rownames `"`rownames' "`: var label `x''""'
		}
		
	xml_tab table, save("Output\TableA6") replace sheet(TableA6) font("garamond" 11) ///
		cnames("All" "Public" "Private" "Difference" " " "All" "Public" "Private" "Difference") ///
		rnames(`rownames') title("Table A4. List of Checklist Items Used in the treatment of Standardized Patients") mv("") ///
		format(SCLR (NCCR3)) ///
		notes("Notes:")	
		
