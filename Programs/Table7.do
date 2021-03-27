/*

Table 7: This do-file generates results for Table 7 of Paper

Produces four sub-tables: 7A, 7B, 7C, 7D

*/

* Salary: Binary Regressions

foreach x in percent_recqe timespent correct_treat mbbs qual age gender distbirth dual{
	
	reg logsalary `x', cl(villid) robust
	est store reg`x'

	}
		
xml_tab reg*, ///
	save("Output\Table7.xml") replace sheet(Table7A) font("garamond" 11) ///
	keep(percent_recqe timespent correct_treat mbbs qual age gender distbirth dual) below format(SCLR0 (SCCR0 NCCR3 NCCR3))
			
* Salary: Multiple Regressions

areg logsalary percent_recqe timespent correct_treat mbbs qual age gender distbirth dual, cl(villid) a(distid)
est store r1

xml_tab r1, ///
	save("Output\Table7.xml") append sheet(Table7B) font("garamond" 11) stats(r2 N) below ///
	keep(percent_recqe timespent correct_treat mbbs qual age gender distbirth dual _cons) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3)) 
estimates clear	

	
* Desirability: Binary Regressions
	
drop if round==1
foreach x in percent_recqe timespent correct_treat mbbs qual age gender distbirth dual{
	
	reg pca `x', cl(villid) robust
	est store reg`x'

	}
	
xml_tab reg*, ///
	save("Output\Table7.xml") append sheet(Table7C) font("garamond" 11) ///
	keep(percent_recqe timespent correct_treat mbbs qual age gender distbirth dual) below format(SCLR0 (SCCR0 NCCR3 NCCR3))

* Desirability: Multiple Regressions
			
areg pca percent_recqe timespent correct_treat mbbs qual age gender distbirth dual, cl(villid) a(distid) //  chc remote_pca water toilet visit
est store r1

xml_tab r1, ///
	save("Output\Table7.xml") append sheet(Table7D) font("garamond" 11) stats(r2 N) below ///
	keep(percent_recqe timespent correct_treat mbbs qual age gender distbirth dual _cons) ///
	format(SCLR0 (SCCR0 NCCR3 NCCR3))
estimates clear	
