* Table 7: Real Patients in the Public and Private Sector

clear
set more off
use "Data\POData.dta", clear
	

	
	egen symptoms=rowtotal(fever cold diarrhea weakness injury vomitting dermatological pregnancy pain)
	mat table=J(46,13,.)
		
	* PANEL A: No controls and no fixed effects	
	
	local i=1
	foreach yvar in symptoms fever cold diarrhea weakness injury vomitting dermatological pregnancy pain dayssick adl_dress adl_work adl_lift adl_walk newpatient age gender assetindex education questions thisvillage byfoot{
		
		* Audit 1
		reg `yvar' private if round==1, cluster(villid) robust
		mat table[`i',3]=_b[private]
		mat table[`i'+1,3]=_se[private]
		local p = (2 * ttail(e(df_r), abs(_b[private]/_se[private])))
    	mat table[`i',4]=`p'
		
		sum `yvar' if e(sample)==1 & private==0 // Mean of public
		mat table[`i',1]=r(mean)
		
		sum `yvar' if e(sample)==1 & private==1 // Mean of private
		mat table[`i',2]=r(mean)
		
		areg `yvar' private if round==1, cluster(villid) robust a(villid)
		mat table[`i',5]=_b[private]
		mat table[`i'+1,5]=_se[private]
		local p = (2 * ttail(e(df_r), abs(_b[private]/_se[private])))
    	mat table[`i',6]=`p'
		
		* Dual
		reg `yvar' private if dual==1 & round==2, cluster(villid) robust
		mat table[`i',10]=_b[private]
		mat table[`i'+1,10]=_se[private]
		local p = (2 * ttail(e(df_r), abs(_b[private]/_se[private])))
    	mat table[`i',11]=`p'
		
		sum `yvar' if e(sample)==1 & private==0 // Mean of public
		mat table[`i',8]=r(mean)
		
		sum `yvar' if e(sample)==1 & private==1 // Mean of private
		mat table[`i',9]=r(mean)
		
		areg `yvar' private if dual==1 & round==2, cluster(villid) robust a(distid)
		mat table[`i',12]=_b[private]
		mat table[`i'+1,12]=_se[private]
		local p = (2 * ttail(e(df_r), abs(_b[private]/_se[private])))
    	mat table[`i',13]=`p'
		
		local i=`i'+2
		
		}

xml_tab table, save("Output\TableA17.xml") replace sheet(TableA17) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) mv("")
