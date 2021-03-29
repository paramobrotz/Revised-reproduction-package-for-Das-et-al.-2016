/*

Table 2: This do-file generates results for Table 2 of Paper

*/
	
use "Data\ProviderData.dta", clear	
	
	mat table=J(39,12,.)
	
	* Audit 1
	count if round==1 & public==1 & spcomplete==1
	mat table[35,1]=r(N)
	count if round==1 & public==0 & spcomplete==1
	mat table[35,2]=r(N)
	
	* Public sample
	count if round==2 & public==1 & spcomplete==1
	mat table[35,5]=r(N)
	
	count if round==2 & public==1 & spcomplete==1 & dual==0
	mat table[35,6]=r(N)

	count if round==2 & public==1 & spcomplete==1 & dual==1
	mat table[35,7]=r(N)
	
	* Dual
	count if round==2 & public==1 & spcomplete==1 & dual==1
	mat table[35,10]=r(N)
	count if round==2 & public==0 & spcomplete==1 & dual==1
	mat table[35,11]=r(N)
	
	local i=1
	
	foreach x in age male education mbbs otherqual noqual training_binary nclinics pracyears dispmed fees patperday patients electricity stethoscope bpmachine thermometer scale handwash {
	
		
		* Audit 1
		ttest `x' if round==1 & spcomplete==1, by(public)
		mat table[`i',1]=r(mu_2)
		mat table[`i',2]=r(mu_1)
		mat table[`i'+1,1]=r(sd_2)
		mat table[`i'+1,2]=r(sd_1)
		mat table[`i',3]=r(p)
		
		* Public
		sum `x' if round==2 & public==1 & spcomplete==1
		mat table[`i',5]=r(mean)
		mat table[`i'+1,5]=r(sd)
		
		ttest `x' if round==2 & spcomplete==1 & public==1, by(dual)
		mat table[`i',6]=r(mu_1)
		mat table[`i',7]=r(mu_2)
		mat table[`i'+1,6]=r(sd_1)
		mat table[`i'+1,7]=r(sd_2)
		mat table[`i',8]=r(p)
			
		* Dual
		ttest `x' if dual==1 & round==2 & spcomplete==1, by(public)
		mat table[`i',10]=r(mu_2)
		mat table[`i',11]=r(mu_1)
		mat table[`i'+1,10]=r(sd_2)
		mat table[`i'+1,11]=r(sd_1)
		mat table[`i',12]=r(p)			
		
		local i=`i'+2
		}
		
		tab qual if otherqual==1 & round==1 & spcomplete==1 & public==1
		tab qual if otherqual==1 & round==1 & spcomplete==1 & public==0
		
		tab qual if noqual==1 & round==1 & spcomplete==1 & public==1
		tab qual if noqual==1 & round==1 & spcomplete==1 & public==0
		


	
xml_tab table, save("Output\Table2.xml") replace sheet(Table2) font("garamond" 11) ///
	showeq ceq("Audit 1" "Audit 1" "Audit 1" " " "Dual" "Dual" "Dual") ///
	cnames("Public" "Private" "p-value of (1)-(2)" " " "All public" "Dual public" "p-value" " " "Public" "Private" "p-value of (1)-(2)") ///
	rnames("Age of Provider" " " "Is male" " " "More than 12 years of basic education" " " "Has MBBS degree" " " "Has alternative qualification" " " "No medical training" " " "Received non-credentialed training" " " "Has multiple practices" " " ///
		"Tenure in years at current location" " " "Dispense medicine" " " "Consultation fee (Rs.)" " " "Average number of patients per day (self reported in census)" " " ///
		"Average number of patients per day (in physician observations)" " " "Electricity" " " "Stethoscope" " " "Blood pressure cuff" " " "Thermometer" " " "Weighing Scale" " " "Handwash facility" " " "Number of providers") /// 
		title("Table 2: Characteristics of providers and practices") ///
	rblanks(0 "Panel A: Provider Characteristics" SCLB0, 10 "Panel B: Clinic Characteristics" SCLB0) ///	
	cwidth(0 180, 1 60, 2 60, 3 60, 4 15, 5 60, 6 60, 7 60) format(SCLR0 (SCCB0 NCCR2 NCCR2)) ///
	notes("Notes:", ///
		"1) Unit of observation is a provider", ///
		"2) The dual sample consists of providers who received a standardized patient in both their public and private practices", /// 
		"3) The provider mapping and complete provider census yielded information about whether or not a provider operates more than practice", /// 
		"4) Audit 1 did not employ the intense reconnaisance to find both the public and private practices of the same provider, and thus the proportion of dual practice providers can be considered self-reported", ///
		"5) In Audit 2, however, the existence of additional medical practices was verified by repeated observation.  Means for fees have been calculated from direct observations of clinical interactions.  All other variables derive from a survey administered during the census of providers")

	
	
