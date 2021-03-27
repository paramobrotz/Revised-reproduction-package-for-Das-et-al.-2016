clear
set more off
	
	
	
	use "Data\Paper2_ProviderDataset.dta", clear
	keep if m_round==1
	keep villid finprovid finclinid public mbbs noqual name qual location practype s3q12a s3q12b s3q13a s3q13b s3q14 s3q15 s3q19
	
		// Total Providers
	
	* Unknown type -- we decided to not include these guys
	count if public==. | qual==.
	drop if public==. | qual==. // 86 providers are dropped
	
				* Training variables -- added on 1/4/2015
				
					* Degree duration
					gen degreeduration = s3q12a * 12 + s3q12b

					* Internship and duration
					gen internship = s3q13a
					recode internship 1=1 2=0
					gen internship_duration = s3q13b 
					
					* Training from another source

					gen training = 1 if s3q14 == 0 // None
					replace training = 2 if s3q14 == 1 // Family Member
					replace training = 3 if s3q14 == 2 | s3q14 == 4 // Practicising Physician or Learned by Observation
					replace training = 4 if s3q14 == 6 // Compounder or Learned by Observation
					replace training = 5 if s3q14 == 3 | s3q14 == 7 // Another Institution or Hospital
					replace training = 6 if s3q14 == 8 | s3q14 == 9 | s3q14 == 10 | s3q14 == 5 | s3q14 == 12 // ANM/MPW/ASHA or Pharmacist or Other
					
					gen training_binary = training
					recode training_binary 1=0 2=1 3=1 4=1 5=1 6=1 *=.
					ta training, gen(training)

					gen trainingduration = s3q15

					* Training Others

					gen trainedothers = s3q19
					recode trainedothers 1=1 2=0 *=.
				
					drop s3q12a s3q12b s3q13a s3q13b s3q14 s3q15 s3q19
					
					
	* Public
	gen pubpara=0
	replace pubpara=1 if (practype==5|practype==6) & public==1
	label var pubpara "Public Paramedical Staff" // Includes ASHA/Anganwadi and Chemists/Pharmacists
		
	gen pubmbbs=0 
	replace pubmbbs=1 if public==1 & qual==5 & pubpara!=1
	label var pubmbbs "Public MBBS"
	
	gen pubqual=0
	replace pubqual=1 if public==1 & (qual==2|qual==3|qual==4|qual==6|qual==7|qual==8|qual==9|qual==10) & pubpara!=1
	label var pubqual "Public Some Qualification"
	
	gen pubnoqual=0
	replace pubnoqual=1 if public==1 & (qual==0|qual==1|qual==11) & pubpara!=1
	label var pubnoqual "Public No Qualification"
	
	egen temp=rowtotal(pubpara pubmbbs pubqual pubnoqual)
	tab public temp
		
	count
	tab public pubpara
	tab public pubmbbs
	tab public pubqual
	tab public pubnoqual

	drop temp

	* Private
	gen pvtmbbs=0
	replace pvtmbbs=1 if public==0 & qual==5
	label var pvtmbbs "Private MBBS"
	
	gen pvtqual=0
	replace pvtqual=1 if public==0 & (qual==2|qual==3|qual==4|qual==6|qual==7|qual==8|qual==9|qual==10)
	label var pvtqual "Private Some Qualification"
	
	gen pvtnoqual=0
	replace pvtnoqual=1 if public==0 & (qual==0|qual==1|qual==11)
	label var pvtnoqual "Private No Qualification"

	egen temp=rowtotal(pvtmbbs pvtqual pvtnoqual)
	tab public temp
		
	count
	tab public pvtmbbs
	tab public pvtqual
	tab public pvtnoqual

	drop temp	

	
* Summary stats

	gen pvttype = 1 if pvtmbbs==1
	replace pvttype = 2 if pvtqual==1
	replace pvttype = 3 if pvtnoqual==1
	
	drop if pvttype ==.
	
	
save "Data\ProviderData2.dta", replace	
