
*************************************************
*** Do File - Lab 1
*************************************************

/*
Welcome to SOC385L Lab!

Some comments throughout provide explanation.

PLEASE go ahead and write your own comments to answer questions,
or take notes for future reference.
*/

* Setting up DO and LOG files:
*************************************************

*Clear memory
clear all

*Turns off automatic scroll breaks
set more off, permanently 		

*Be sure to change the directory below to your current directory.
cd "/"
								
	/*
	NOTE: Working in multiple locations? Try this code instead -
	capture noisily cd "/drive1/folder1/"
	capture noisily cd "/drive2/folder2/"
	*/

*Close any open logs, just in case
capture noisily log close

*Log input and output
log using "Lab1LOG.smcl", smcl replace


*Importing/Using Data:
*************************************************

use "lab1data.dta", clear		/*the ", clear" option here is redundant but 
								shows you that you can also do it this way.*/

* Exploring the Dataset:
*************************************************

*Describe the dataset
desc

	*Q: How many observations?
	*-----------------------------------------------*
	
	
	
	*Q: How many variables?
	*-----------------------------------------------*

	
	
*Tabulate a variable
tab s002

	*Q: s002 is wave. How many waves are in this dataset?
	*-----------------------------------------------*
	
	
	
	*Q: How many observations (obs.) in each wave?
	*-----------------------------------------------*
	
	
	
*Tabulate a few more variables

tab s003

	*Q: How many countries (s003) are in our dataset?
	*-----------------------------------------------*
	
	
		
	*Q: How many observations in the U.S?
	*-----------------------------------------------*
	
	
		
	*Q: How many religions are in this data? (f025)
	*-----------------------------------------------*
	



*Cross-Tabulating some variables

tab s003 s002

	*Q: If we want to focus on Egypt, does it matter which wave we use?
	*-----------------------------------------------*
	
	
	
	*Q: How about Poland?
	*-----------------------------------------------*
	
	
	
*Summarizing some variables (with detail... ", d" option)

sum x003, d

	*Q: What is the mean age of our respondents?
	*-----------------------------------------------*
	
	
	
	
	*Q: The Standard Deviation?
	*-----------------------------------------------*
	
	
	
	
	*Q: Explain "percentiles".
	*-----------------------------------------------*
	
	
	
	
	/*
	NOTES ON SKEWNESS AND KURTOSIS:
	
	"Skewness - Skewness measures the degree and direction of asymmetry.  
	A symmetric distribution such as a normal distribution has a skewness of 0,
	and a distribution that is skewed to the left, e.g., when the mean is less 
	than the median, has a negative skewness.
	
	Kurtosis - Kurtosis is a measure of the heaviness of the tails of a 
	distribution. A normal distribution has a kurtosis of 3. Heavy tailed 
	distributions will have kurtosis greater than 3 and light tailed 
	distributions will have kurtosis less than 3."
	
	From: http://www.ats.ucla.edu/stat/stata/output/stata_summ_output.htm
	*/
	
	
* Exploring Volunteering Variables (a081-a096):
*************************************************

*sort the data by wave
sort s002

*Show underlying names of waves (without labels)
tab s002, nolab

*Check volunteer variables by wave (using ", m" option to show missing)
by s002: tab a081, m

*You could also write the following to sort and tab in one step.
bysort s002: tab a081, m

*Repeat these tabs for a few other volunteer variables

	*Q: If we study volunteering, can we use both waves 4 and 5?
		*If not, which one should we use?
	*-----------------------------------------------*
	
	
		
		
*Dropping/Keeping Observations and Variables
*************************************************

*Keeping only Wave 4
keep if s002==4

*Dropping "study" and "interview" variables
drop s001 s008

	/*
	NOTE: You can use either keep or drop.
	It is normally easiest to use the one that entails the least code.
	*/
	
*Combining/Generating Variabls Coding volunteering:
*************************************************

/*
THE ORIGINAL QUESTION FROM THE WVS:

Please look carefully at the following list of voluntary organizations and 
activities and say...
And for which, if any, are you currently doing unpaid voluntary work? 
A081-A096 List of Voluntary Organizations
0 Not mentioned 1 Unpaid Work
*/




	*Q: What are some ways you can think of to code these volunteering variables?
	*-----------------------------------------------*
	
	
	
*Combining volunteering variables as a count
		*NOTE: egen with missing option counts missing as zero, unless all are
		*missing. Then it considers all as missing.
egen volcount = rowtotal (a081-a096), m

*Look at the egen help file.
help egen
*This line closes the help file automatically,
*so be careful to stop here or comment it out if you want to view it
window manage close help

*Tabulatin volcount
tab volcount

	*Q: What is the mode of this variable?
	*-----------------------------------------------*
	
	
	

*Summarizing volcount
sum volcount, d

	*Q: What is the mean number of types of organizations for which people volunteer?
	*-----------------------------------------------*

	
		
*Visualize volcount with a histogram
hist volcount
graph export "hist_volcount.png", as(png) replace
window manage close graph

*Create a dummy variable "volany"
gen volany=volcount 
recode volany 2/15=1

*Tabulate volany with missing options
tab volany, m

	*Q: What do you conclude about most people from this quick summary?
		*Hint: Pay attention to missing.
	*-----------------------------------------------*
	
	

	*Cross-tabs of volany and country	
tab s003 volany, row

	*Q: Which country has the smallest percentage of people who volunteer?
	
	
	
	*Q: Which country has the largest?
	
	
*Cross-tabs of volany and gender	
tab x001 volany, row

	*Q: Do men or women tend to volunteer more?
	*-----------------------------------------------*
	
	
	
*Dropping originaly volunteer variables
drop a081-a096
	*Also possible to write, "drop a0*" to drop all variables that begin with prefix.



*Gender Equality Variables
*************************************************	

/*
THE ORIGINAL TEXT OF THE WVS QUESTIONS:

C001.- Jobs scarce: Men should have more right to a job than women
Do you agree or disagree with the following statements?

When jobs are scarce, men should have more right to a job than women
1 Agree 2 Disagree 3 Neither
D058.- Husband and wife should both contribute to income
For each of the following statements I read out, can you tell me how much you 
agree with each. Do you agree strongly, agree, disagree, or disagree strongly? 

Both the husband and wife should contribute to household income
1 Agree strongly 2 Agree 3 Disagree 4 Strongly disagree
D059.- Men make better political leaders than women do
For each of the following statements I read out, can you tell me how much you 
agree with each. Do you agree strongly, agree, disagree, or disagree strongly? 

On the whole, men make better political leaders than women do
1 Agree strongly 2 Agree 3 Disagree 4 Strongly disagree */

*Reverse code d059 to align with d058
recode d059 1=4 2=3 3=2 4=1

*If you tabulate d059, you'll see the labels did not switch

*Relabelling d059

label define newlab 1 "strongly disagree" 2 "disagree" 3 "agree" 4 "agree strongly"

label values d059 newlab
	
tab d059


*Recoding c001

tab c001
tab c001, nolab
recode c001 2=0 3=.5
tab c001

*Short-Cute labelling method

label var c001 "0 disagree, 0.5 neither, 1 agree"

label values c001 clab
	
tab c001
	
*Transforming Town Size
*************************************************	

tab x049
tab x049, nolab
hist x049
window manage close graph
	
	*Q: Think about this scale. Does this make sense?
		*How else would you code it?
	*-----------------------------------------------*

*Creating Town Size Variable
gen townsize = x049
recode townsize 1=1000 2=3500 3=7500 4=15000 5=35000 6=75000 7=300000 8=750000

hist townsize
window manage close graph

*Creating Urban / Rural Dummy Variable
gen urban_setting=x049
recode urban_setting 1/6=0 7/8=1

hist urban_setting
window manage close graph

*Recoding Religious Attendance
*************************************************	

tab f028
tab f028, nolab
hist f028
window manage close graph

/*
Create a new variable from f028 with  called and recode it so that 0=never,
.5=less than once a year, 1=once a year, 2=special holy days, 4=other specific
holy days, 12=once a month, 52=once a week, and 104=more than once a week.
*/

*Recoding Religious Attendance
gen days_relig_service = f028
recode days_relig_service 8=0 7=.5 6=1 5=4 4=2 3=12 2=52 1=104

tab days_relig_service
hist days_relig_service
window manage close graph

* Note: when you actually tab this variable, 
*no one said #5 'Other specific holy days', so it's not there.

*Renaming Variables:
*************************************************

ren x001 gender
ren s002 wave

* There was a typo in the code below. It should be "ren" or "rename", not "renames".

ren (s003 c001 d058 d059 f024 f025 f028 x003 x007 x011a x047r x049) ///
(country jobs_mf income_mf leaders_mf relig_belong relig_denom ///
 relig_attend age maritstat kids income townsize_orig)

*Labeling Religion Variables:
*************************************************

label var religcat "denomination"

label define religcatl 0 "No Religion" 1 "Catholic" 2 "Evangelical" 3 "Protestant" ///
4 "Orthodox" 5 "Jewish" 6 "Muslim" 7 "Hindu" 8 "Buddhist" 9 "Other"

label values religcat religcatl

tab religcat, m

*Labelling Marital Status
*************************************************

*We called x007 "maritstat" above

tab maritstat, m

label define maritstat 1 "Married" 2 "Living together as married" 3 "Divorced" ///
4 "Separated" 5 "Widowed" 6 "Single/Never married" 7 "Divorced, separated or widow" ///
8 "Living apart but steady relation"

label values maritstat maritstat

tab maritstat, m

*Recoding/Relabelling Short-Cut Method
*************************************************

*Gender

recode gender 1=0 2=1
label define nolab 0 "0" 1 "1" 2 "2"
label values gender nolab
* Short-cut method for labeling
tab gender, m

label var gender "0=male, 1=female"
tab gender, m

* Finishing Up:
*************************************************

*Compresses all variables to the smallest data type to save space, and speed
compress

*Orders your variables alphabetically
aorder

*If we want to keep some variables first or last, we could do that too
order country wave, first

* Final questions

	*Q: Of all of the categories of religion (including "No Religion" and 
		*excluding "missing"), which group has the highest per- centage of 
		*members who volunteer? Which group has the lowest?
	*-----------------------------------------------*

tab religcat volany, row
	
	
	
	
	*Q: On the three gender questions, compare men only, by country. 
		*In which country do men have the most patriarchal views? 
		*In which country do they most strongly support gender equality?
	*-----------------------------------------------*

tab country jobs_mf if gender==0, row
tab country income_mf if gender==0, row
tab country leaders_mf if gender==0, row
	

	

* If we want, we can also combine the variables in some way to look at the overall scores.

gen patriarchy = jobs_mf + income_mf + leaders_mf - 1 	/* This gives us a score from 2 to 9, 
								so I subtracted 1, to make it from 1 to 8 */

tab country patriarchy if gender==0, row 	/* Hard to see, but on the overall scores, the same
						countries are more patriarchal. These are Algeria,
						Egpyt, Iraq, Jordan, Morocco, etc. And the others that
						are least patriarchal are Albania, Canada, Chile, Mexico, 
						Puerto Rico, Sweden, etc. */

*Perhaps summing is an easier way to look at it, to compare the means.
bysort country: sum(patriarchy)
	
	
	
	
	
	*Q: Earlier, you labeled marital status. 
		*But would you use this variable as it is currently coded?
		*Think about how you might recode this variable. 
		*And how might your coding choice depend on your research question?
		*For example, how might you code this variable if "mental health" 
		*was your outcome? What if "trust in others" was your outcome?
	*-----------------------------------------------*



/*  SOME THOUGHTS from Nicholas:

	Perhaps marital status could be combined into fewer categories, if for example we consider 
	living together and married to be similar states, or separated and living apart but married similar.
	In particular, for mental health questions, we might think that the act of cohabitating is where
	the benefits or disadvantages lie. If the question were about trust, we might think tying the knot
	is most important, whether or not someone is living together, since it shows commitment. 
	
	We can test it multiple ways, but this kind of thought process is important to make sure what
	we are measuring is theoretically sound, and also because for some categories, we may have so
	few respondents that we should combine them with other categories, at the very least into an "other"
	category, in order to have statistical power. */

	
*Finally, end your session with the following commands to save the new data.
*Give it a different name, so as not to erase the original data.
	
* Save data

save "lab1data_revised.dta", replace

