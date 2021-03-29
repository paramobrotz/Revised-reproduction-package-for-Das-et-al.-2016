# Revised-reproduction-package-for-Das-et-al.-2016
Revised reproduction package for Das et al. 2016


Readme file: “Quality and Accountability in Healthcare Delivery: Audit-Study Evidence from Primary Care in India”
Authors: Jishnu Das, Alaka Holla, Aakash Mohpal and Karthik Muralidharan
Date: 08 March 2016

This document guides users interested in using the data and replicating results from the above paper. The folder is organized as follows:
Data: Contains all datasets used for the purpose of the paper. The accompanying readme file (ReadMe_Datasets.docx) describes each dataset. 
Programs: Contains all do-files for replicating the analyses of the research. The file name of each do-file corresponds to the table numbers in the paper. “Masterfile.do” calls all programs in sequence and replicates the analysis of the paper.
Output: Contains all results from the produced by running the do-files above. Results are obtained in a raw format and then further formatted in Excel. Formatted tables are available in the files “MainTables.xlsx” and “AppendixTables.xlsx” in the same folder. 

Notes:
All analysis was performed using Stata 14 on a Windows 10 computer. The program files use user-written program “xml_tab.ado” which is available for installation from the Stata server (Masterfile.do installs this file)

#####################################

ReadMe_Datasets file: “Quality and Accountability in Healthcare Delivery: Audit-Study Evidence from Primary Care in India”
Descriptions of all data sets
Authors: Jishnu Das, Alaka Holla, Aakash Mohpal and Karthik Muralidharan
Date: 08 March 2016

ReadMe_DualDifferentialCompletion
Description: Village level data set with number of providers (total and by type) available to households in the market, in own villages and in the cluster villages. 
Observation: Each observation is a location – which is either the sampled village or a cluster village. 
Unique Identifier: Combination of villid and location
Related do-files: Table1.do

ReadMe_HouseholdDataset
Description: Individual level data set with all medical visits made in the past one month linked to identities of provider visited. 
Observation: Each observation is an individual in the sampled village
Unique Identifier: Data are identified up to the household level. Combination of villid and hhid
Related to-files: Table1.do

ReadMe_ProviderData
Description: Data set with all health care providers and their individual and clinic characteristics
Observation: Each observation is a provider. The variable round identifies if the provider is from the representative sample or the dual practice sample
Unique identifier: Combination of finprovid and finclinid
Related do-files: Table1.do, Table2.do, TableA4.do

ReadMe_SPDataset
Description: The main data set for the paper. All SP observations for both representative and dual practice samples identified by the round variable. Includes all variables on questions and examinations asked, diagnoses, treatments, and prices charged. 
Observation: Each observation is a SP visit to providers. 
Unique identifier: Combination of finprovid and finclinid and case
Related do-files: Table3.do, Table4.do, Table5.do, Table6.do, TableA4.do, TableA6.do, TableA7.do, TableA8.do, TableA9.do, TableA10.do, TableA11.do, TableA12.do, TableA15.do, TableA18.do, TableA19.do

ReadMe_PublicSalary
Description: Data set with salaries of all public providers and desirability of the clinic they are posted to
Observation: Each observation is a SP visit to the public sector
Unique identifier: Data are identified up to the provider level. Combination of finprovid and finclinid
Related do-files: Table7.do

ReadMe_POData
Description: Data set of real patients visits (physician observations) to providers in both representative and dual practice samples. Include variables on patient symptoms and characteristics, as well as provider characteristics.
Observation: Each observation is a real patient visit
Unique identifier: Data are identified up to the provider level. Combination of finprovid and finclinid
Related do-files: Table8.do, TableA17.do

ReadMe_ProviderData2
Description: Data set of providers in the representative sample and their medical training
Observation: Each observation is a provider
Unique identifier: Combination of finprovid and finclinid
Related do-files: TableA3.do

ReadMe_DualDifferentialCompletion
Description: Data set denoting sampling and completion of SP observations in the dual practice sample
Observation: Each observation is a sampled/completed SP
Unique identifier: Combination of finprovid and finclinid and case
Related do-files: TableA13.do, TableA14.do

ReadMe_PublicFacilitySurvey
Description: Data set from public facilities (PHC/CHC) surveys with strength of the facility, and patients visits in past three years
Observation: Each observation is a PHC/CHC employee
Unique identifier: Data are identified up to the facility level. The variable is phcid
Related do-files: TableA16.do




