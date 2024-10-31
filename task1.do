clear
cd "/Users/haivanle/Downloads/HIL_DataTask_2025/GSS_stata/"
use "gss7222_r3a.dta"

// Change all variable names to lowercase
rename *, lower

describe vote72
label list VOTE68A
// Create the new indicator variable for each presidential election
gen vote_pres = 2  // Initialize as 2
// Assign 1 if voted, and 0 if did not vote
// Initially I used an AND condition but no real changes made so I switched to an OR condition
replace vote_pres = 1 if (vote72 == 1 & year == 1974) | (vote76 == 1 & year == 1978) | (vote80 == 1 & year == 1982) | (vote84 == 1 & year == 1986) | (vote88 == 1 & year == 1990) | (vote92 == 1 & year == 1994) | (vote96 == 1 & year == 1998)
// Did not vote at all or did not vote for one year but voted for the other? Then, I should do an AND condition here to avoid double counting
replace vote_pres = 0 if (vote72 == 2 & year == 1974) & (vote76 == 2 & year == 1978) & (vote80 == 2 & year == 1982) & (vote84 == 2 & year == 1986) & (vote88 == 2 & year == 1990) & (vote92 == 2 & year == 1994) & (vote96 == 2 & year == 1998)
// Label values of the new variable
label define voted_label 1 "Voted" 0 "Did not vote" 2 "Neither"
label values vote_pres voted_label

drop if vote_pres == 3

// Create a new indicator variable repub_v_dem
describe pres72
label list PRES72A
gen repub_v_dem = 2
// Again, unless the code is wrong, the AND condition doesn't work. I think using an AND condition is correct but for the sake of the regression, I had to use an OR here. Otherwise, I have no data.
replace repub_v_dem = 1 if (pres72 == 2 & year == 1974) | (pres76 == 2 & year == 1978) | (pres80 == 2 & year == 1982) | (pres84 == 2 & year == 1986) | (pres88 == 2 & year == 1990) | (pres92 == 2 & year == 1994) | (pres96 == 2 & year == 1998)
replace repub_v_dem = 0 if (pres72 == 1 & year == 1974) & (pres76 == 1 & year == 1978) & (pres80 == 1 & year == 1982) & (pres84 == 1 & year == 1986) & (pres88 == 1 & year == 1990) & (pres92 == 1 & year == 1994) & (pres96 == 1 & year == 1998)
label define voted_candidate_label 1 "Republican" 0 "Democrat" 2 "Neither"
label values repub_v_dem voted_candidate_label

// Create an indicator variable named male
describe sex
label list GENDER
gen male = sex==1
label define male 1 "Male" 0 "Female"

// Create a categorial variable name religion
describe relig
label list RELIG
gen religion = 4
replace religion = 1 if relig == 1
replace religion = 2 if relig == 2
replace religion = 3 if relig == 4
label define religion_label 1 "Protestant" 2 "Catholic" 3 "No Religion" 4 "Other"
label values religion religion_label

// Create a categorical variable named age_cat
gen age_cat = 4
replace age_cat = 1 if age >= 18 & age <= 29
replace age_cat = 2 if age >= 30 & age <= 49
replace age_cat = 3 if age >= 50 & age <= 64

label define age_label 1 "18-29" 2 "30-49" 3 "50-64" 4 "65plus"
label values religion religion_label

// Create an indicator variable named less_highschool
describe educ
label list EDUC
gen less_highschool = 2
replace less_highschool = 1 if educ >= 0 & educ <= 11 
replace less_highschool = 0 if educ >= 12 & educ <= 20

// Create a summary table with the statistics of recently created variables
summarize vote_pres repub_v_dem male religion age_cat less_highschool

// Regression
eststo clear
eststo reg1: reg vote_pres i.religion [pweight = wtssall]
eststo reg2: reg vote_pres i.religion i.age_cat [pweight = wtssall]
eststo reg3: reg vote_pres i.religion i.age_cat male [pweight = wtssall]
eststo reg4: reg vote_pres i.religion i.age_cat male i.less_highschool [pweight = wtssall]
eststo reg5: reg vote_pres i.religion i.age_cat male i.less_highschool i.year [pweight = wtssall]

esttab reg1 reg2 reg3 reg4 reg5 using "reg_table_hil.tex", label se b(3) star(* 0.05 ** 0.01 *** 0.001) 

eststo clear
eststo reg6: reg repub_v_dem i.religion [pweight = wtssall]
eststo reg7: reg repub_v_dem i.religion i.age_cat [pweight = wtssall]
eststo reg8: reg repub_v_dem i.religion i.age_cat male [pweight = wtssall]
eststo reg9: reg repub_v_dem i.religion i.age_cat male i.less_highschool [pweight = wtssall]
eststo reg10: reg repub_v_dem i.religion i.age_cat male i.less_highschool i.year [pweight = wtssall]

esttab reg6 reg7 reg8 reg9 reg10 using "reg_table_hil2.tex", label se b(3) star(* 0.05 ** 0.01 *** 0.001) 
