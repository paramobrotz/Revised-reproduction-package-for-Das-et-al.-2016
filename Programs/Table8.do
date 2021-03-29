/*

Table 8: This do-file generates results for Table 8 of Paper

Produces four sub-tables: Panel A, Panel A means, Panel B, Panel C

*/
	
local controls = "dayssick questions education assetindex thisvillage byfoot adl_dress adl_work adl_lift adl_walk fever cold diarrhea weakness injury vomitting dermatological pregnancy pain"
	
* PANEL A: No controls and no fixed effects	
foreach yvar in timespent totalquestions examination dispense totalmeds{
	
	* Audit 1
	reg `yvar' private if round==1, cluster(villid) robust
	est store s1_`yvar'
	sum `yvar' if e(sample)==1 & private==0 // Mean of public
	mat s1_`yvar'_mean=r(mean)\r(sd)
	sum `yvar' if e(sample)==1 & private==1 // Mean of private
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)\r(sd)]
	sum `yvar' if e(sample)==1 // Mean of sample
	mat s1_`yvar'_mean=s1_`yvar'_mean\[r(mean)\r(sd)]
	
	*egen provtag=tag(finprovid finclinid) if e(sample)==1
	count if private==0 & provtag==1
	mat s1_`yvar'_mean=s1_`yvar'_mean\r(N)
	count if private==1 & provtag==1
	mat s1_`yvar'_mean=s1_`yvar'_mean\r(N)
	drop provtag
	
	* Dual
	reg `yvar' private if dual==1 & round==2, cluster(finprovid) robust
	est store s2_`yvar'
	sum `yvar' if e(sample)==1 & private==0 // Mean of public
	mat s2_`yvar'_mean=r(mean)\r(sd)
	sum `yvar' if e(sample)==1 & private==1 // Mean of private
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)\r(sd)]
	sum `yvar' if e(sample)==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\[r(mean)\r(sd)]
	
	egen provtag=tag(finprovid finclinid) if e(sample)==1
	count if private==0 & provtag==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\r(N)
	count if private==1 & provtag==1
	mat s2_`yvar'_mean=s2_`yvar'_mean\r(N)
	drop provtag
	
	}
xml_tab s1_timespent s1_totalquestions s1_examination s1_dispense s1_totalmeds s2_timespent s2_totalquestions s2_examination s2_dispense s2_totalmeds, ///
	save("Output\Table8.xml") replace sheet(Table8A) font("garamond" 11) ///
	keep(private) below stats(r2 N) ///
	title("Table 8: PO Results") ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

mat means=s1_timespent_mean, s1_totalquestions_mean, s1_examination_mean, s1_dispense_mean, s1_totalmeds_mean, s2_timespent_mean, s2_totalquestions_mean, s2_examination_mean, s2_dispense_mean, s2_totalmeds_mean

xml_tab means, save("Output\Table8.xml") append sheet(Table8A_means) font("garamond" 11) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

estimates clear
		
* PANEL B: No controls and market/district fixed effects	
foreach yvar in timespent totalquestions examination dispense totalmeds{
	
	* Audit 1
	areg `yvar' private if round==1, cluster(villid) robust absorb(villid)
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private if dual==1 & round==2, cluster(finprovid) robust absorb(distid)
	est store s2_`yvar'
	
	}
xml_tab s1_timespent s1_totalquestions s1_examination s1_dispense s1_totalmeds s2_timespent s2_totalquestions s2_examination s2_dispense s2_totalmeds, ///
	save("Output\Table8.xml") append sheet(Table8B) font("garamond" 11) ///
	keep(private) below stats(r2 N) ///
	title("Table 8: PO Results") ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))

estimates clear

* Panel C: Controls and fixed effects
foreach yvar in timespent totalquestions examination dispense totalmeds{

	* Audit 1
	areg `yvar' private mbbs qual provage provgender `controls' if round==1, cluster(villid) robust absorb(villid)
	est store s1_`yvar'
	
	* Dual
	areg `yvar' private provage provgender `controls' if dual==1 & round==2, robust absorb(distid) cluster(finprovid)
	est store s2_`yvar'

	}

xml_tab s1_timespent s1_totalquestions s1_examination s1_dispense s1_totalmeds s2_timespent s2_totalquestions s2_examination s2_dispense s2_totalmeds, ///
	save("Output\Table8.xml") append sheet(Table8C) font("garamond" 11) ///
	keep(private mbbs qual provage provgender adl_dress adl_work adl_lift adl_walk _cons) below stats(r2 N) ///
	title("Table 8: PO Results") format(SCLR0 (SCCR0 NCCR3 NCCR3))


