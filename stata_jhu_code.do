** https://coronavirus.jhu.edu/map.html
** https://github.com/CSSEGISandData/COVID-19

clear

cd "<your directory here>"





*************************
*** confirmed cases   ***
*************************


import delimited "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv", clear

// fixing lat/long columns

ren lat latitude
ren v4 longitude

		
// fixing the v columns names to include dates
foreach x of varlist v* {
   local t : var label `x'                               // mind the spaces in these two lines
	 local t: subinstr local t "/" "_", all                // replacing / with _ in names. _ to be used later for parsing dates
   
	 rename `x' y`t'   
}

order countryregion provincestate        // order and sort
sort countryregion 

drop if provincestate=="Recovered"            // wierd entry in the dataset

collapse (mean) latitude longitude (sum) y* , by(countryregion)     // avg. of lat/longs might mess up positions due to territories
reshape long y, i(countryregion) j(date) string                     // string because date is a string

ren y reported

split date, p(_) destring            // split it up and remove the orignal date
drop date

ren date1 month
ren date2 day
ren date3 year
replace year = 2000 + year

gen date = mdy(month,day,year)   // reconstruct the date
format date %tdDD-Mon-yy

drop day month year

ren countryregion country
order country date


compress
save ./extracted/JHU/covid19_JHU_ts_reported.dta, replace


****************
*** deaths   ***
****************

import delimited "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv", clear

drop lat v4  // here we drop them since the first file already has the information



		
// fixing the v columns
foreach x of varlist v* {
     local t : var label `x'
     display "`t'"
	 
	 local t: subinstr local t "/" "_", all
	 display "`t'"
     
	 rename `x' y`t'
}

order countryregion provincestate
sort countryregion


drop if provincestate=="Recovered"

collapse (sum) y* , by(countryregion)
reshape long y, i(countryregion) j(date) string   // string because date is a string

ren y deaths

split date, p(_) destring // split it up and remove the actual date
drop date

ren date1 month
ren date2 day
ren date3 year
replace year = 2000 + year

gen date = mdy(month,day,year)
format date %tdDD-Mon-yy

drop day month year
ren countryregion country
order country date

compress
save ./extracted/JHU/covid19_JHU_ts_deaths.dta, replace


******************
*** recovered  ***
******************



import delimited "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv", clear

drop lat v4  // here we drop them since the first file already has the information



		
// fixing the v columns
foreach x of varlist v* {
     local t : var label `x'
     display "`t'"
	 
	 local t: subinstr local t "/" "_", all
	 display "`t'"
     
	 rename `x' y`t'
}

order countryregion provincestate
sort countryregion


drop if provincestate=="Recovered"

collapse (sum) y* , by(countryregion)
reshape long y, i(countryregion) j(date) string   // string because date is a string

ren y recovered


split date, p(_) destring // split it up and remove the actual date
drop date

ren date1 month
ren date2 day
ren date3 year
replace year = 2000 + year

gen date = mdy(month,day,year)
format date %tdDD-Mon-yy

drop day month year
ren countryregion country
order country date

compress
save ./extracted/JHU/covid19_JHU_ts_recovered.dta, replace


***********************************
****  lets put these together  ****
***********************************


use ./extracted/JHU/covid19_JHU_ts_reported, clear
merge 1:1 country date using ./extracted/JHU/covid19_JHU_ts_deaths      // perfect merges currently
drop _m

merge 1:1 country date using ./extracted/JHU/covid19_JHU_ts_recovered
drop _m

// clean up the labels
lab var country 	"Country"
lab var date		"Date"
lab var latitude	"Latitude"
lab var longitude	"Longitude"
lab var	reported	"Reported cases"
lab var deaths		"Deaths"
lab var	recovered	"Recovered"

compress
save ./extracted/JHU/covid19_JHU_ts_final, replace


****************** END OF FILE *************************

