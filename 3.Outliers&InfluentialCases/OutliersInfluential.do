
*************************************************
*** Do File - Outliers and Influential Cases
*************************************************

cap cd "~/Dropbox/Git/repositories/StataLabs/3.OutliersInfluential/"
set more off, permanently
cap log close
log using outliers.smcl, replace

use http://www.ats.ucla.edu/stat/stata/webbooks/reg/crime, clear

*********************************************************************
/*NOTE: Here are some useful references I quote below.

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm
http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg_self_assessment_answers2.htm
https://en.wikipedia.org/wiki/Studentized_residual
http://mtweb.mtsu.edu/stats/regression/level3/multiregdiag/tools/DFits/conceptdfits.htm
https://en.wikipedia.org/wiki/Cook%27s_distance
http://mtweb.mtsu.edu/stats/regression/level3/cook/concept.htm
*/

desc 

summarize

*This data set contains state/region-level information 
*on the crime rates, murder rates, poverty rates and 
*racial-ethnic compositions for 51 states/regions of the United States

*********************************************************************
*                   MULTICOLLINEARITY DETECTION			    *
*********************************************************************

/*NOTE: Here, we generally consider a VIF (Variance Inflation Factor)
over 10 to be high multicollinearity. A 1/VIF (Called Tolerance) of
less than .1 is also considered high multicollinearity.

See: (UCLA statareg2)
*/

regress crime pctmetro pctwhite pcths poverty single 

vif

*********************************************************************
*                         OUTLIERS				    *
*********************************************************************
/*Outliers: In linear regression, an outlier is an observation with large 
residual. In other words, it is an observation whose dependent-variable value 
is unusual given its values on the predictor variables. An outlier may indicate 
a sample peculiarity or may indicate a data entry error or other problem.

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm
*/


*1. Run the following regression:

regress crime pctmetro pctwhite poverty single

**********************************************
*2. Graph and interpret a scatterplot matrix

graph matrix crime pctmetro pctwhite poverty single, ///
msymbol (Oh) mlabel(state) mlabsize(vsmall) ///
title(Scatterplot Matrix) subtitle(Crime & Explanatory Variables)

graph export ScatterPlotMatrix.png, replace


**********************************************
*3.Graph and interpret some bivariate scatterplots to zoom in 
*closer on the relationships shown in the scatterplot matrix

*crime & pctmetro (subtract dc)

twoway (scatter crime pctmetro, mlabel(state)) (lfit crime pctmetro) ///
(lfit crime pctmetro if sid!=51), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc")) ///
title("Outliers: crime & pctmetro") ytitle(crime) xtitle(pctmetro) scale(.8)
graph export crime_pctmetro.png, replace

*crime & pctwhite (subtract dc, hi, ms, hi_ms, dc_hi_ms)

twoway (scatter crime pctwhite, mlabel(state)) (lfit crime pctwhite) ///
(lfit crime pctwhite if sid!=51, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=11, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=25, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=11 & sid!=25, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=11 & sid!=25 & sid!=51, lpattern(shortdash)), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc") ///
label(4 "without hi") label(5 "without ms") label(6 "without hi/ms") ///
label(7 "without dc/hi/ms")) ///
title("Outliers: crime & pctwhite") ytitle(crime) xtitle(pctwhite) scale(.8)
graph export crime_pctwhite.png, replace

*crime & poverty (subtract dc)

twoway (scatter crime poverty, mlabel(state)) (lfit crime poverty) ///
(lfit crime poverty if sid!=51, lpattern(dash)), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc")) ///
title("Outliers: crime & poverty") ytitle(crime) xtitle(poverty) scale(.8)
graph export crime_poverty.png, replace

*crime & single(subtract dc)

twoway (scatter crime single, mlabel(state)) (lfit crime single) ///
(lfit crime single if sid!=51, lpattern(dash)), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc")) ///
title("Outliers: crime & single") ytitle(crime) xtitle(single) scale(.8)
graph export crime_single.png, replace

*************************************************************************
*4. Partial regression plots

/*Stata calls them Added-Variable Plots (AVPLOTS)
"The avplot command graphs an added-variable plot. 
It is also called a partial-regression plot and is very useful 
in identifying influential points." 

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

In layman's (or laywoman's) terms, what a partial regression plot does is this:

1) Regress X2 X3 X4 on Y, and grab the residual.
2) Regress X2 X3 X4 on X1, and grab the residual.
3) Regress the residual from 2 on the residual from 1.
4) Make a scatterplot of the two residuals and a fitted line.

**This represents the slope (coefficient) or effect of X1 on Y after accounting
for the effects of all other X variables. In other words, "holding all else
constant" as in a multiple regression.*/

*Run the regression first

regress crime pctmetro pctwhite poverty single

*Partial regression

avplots, mlabel(state) scale(0.95)

graph export partialreg.png, replace

*************************************************************************
*5. Leverage prediction (hat matrix)

/*"Leverage: An observation with an extreme value on a predictor variable is 
called a point with high leverage. Leverage is a measure of how far an 
observation deviates from the mean of that variable. These leverage points 
can have an effect on the estimate of regression coefficients."

KEY TO NOTE: Points with high leverage "CAN have an effect on the estimate
of regression coefficients" but leverage is not measuring this effect. It is
simply how far the point falls from the predicted/fitted value. Depending on 
other factors, it may or may not pull the line toward it much. We need to 
look at some other measures. And the true test is what happens when you 
remove it. 

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm
*/

regress crime pctmetro pctwhite poverty single

predict lev, leverage

gsort -lev    //sort in descending order:sorting lev values from larger to smaller

list state lev in 1/10 //Top ten

/*Calculating the cut-off points (2*k+2)/n. A point with leverage greater 
than (2K+2)/n should be carefully examined. Here K is the number of 
predictors and n is the number of observations.*/

di (2*4+2)/51
		
**The answer is .19607843

list state lev if lev > .19607843

**Set a couple of thresholds: visualize the levels of leverage for each case

scalar h2 = .19607843
scalar h3 = 2*.19607843
graph twoway scatter lev sid, mlabel(state) ///
yline(`=h2', lpattern(dash)) yline(`=h3', lpattern(dash)) ///
title(Leverage by State)
graph export LeverageIndexPlot.png, replace

*************************************************************************
/*"Influence: An observation is said to be influential if removing the 
observation substantially changes the estimate of coefficients. Influence 
can be thought of as the product of leverage and outlierness."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

Leverage is just one possible measure of influence.
*/

*************************************************************************
*6) Predicting Studentized Residuals

/*Studentized residuals are a type of standardized residual 
that can be used to identify outliers.

From Wikipedia: https://en.wikipedia.org/wiki/Studentized_residual

"In statistics, a studentized residual is the quotient resulting from the 
division of a residual by an estimate of its standard deviation. Typically 
the standard deviations of residuals in a sample vary greatly from one data 
point to another even when the errors all have the same standard deviation, 
particularly in regression analysis; thus it does not make sense to compare 
residuals at different data points without first studentizing. It is a form 
of a Student's t-statistic, with the estimate of error varying between points.

This is an important technique in the detection of outliers. It is among 
several named in honor of William Sealey Gosset, who wrote under the pseudonym 
Student, and dividing by an estimate of scale is called studentizing, 
in analogy with standardizing and normalizing."

KEY TO KNOW: "Studentized" is just a type of standardized residual named after
a guy who went by Student. It helps put leverage and residuals in perspective
by making them comparable across all observations in the range of X.
*/

*Run regression again (in case we did something else since the last run)

regress crime pctmetro pctwhite poverty single

predict r, rstudent //Predict Studentized Residuals

sort r //Sorting r

*Listing state and r if r is greater than absolute 1

list r state if abs(r)>1

*Set a couple of thresholds

scalar h1 = 1
scalar h2 = 2
scalar h3 = -1
scalar h4 = -2
graph twoway scatter r sid, mlabel(state) ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
yline(`=h3', lpattern(dash)) yline(`=h4', lpattern(dash)) ///
title(Studentized Residuals by State)
graph export StudResIndexPlot.png, replace

/*KEY TO NOTE: So far, leverage and studentized residuals only show us localized
measures of influence, which compare the influence of an observation
(data point) at a particular place in the regression (range of x).

The following measures DFITS, Cook's Di provide more general,
overall measures of influence.
*/

**********************************************
*7) DFITS and Cook's Di

/* KEY TO NOTE: Now let's move on to overall measures of influence, 
specifically let's look at Cook's D and DFITS. These measures both 
combine information on the studentized residuals (outlierness) and 
leverage (hat matrix). Cook's D and DFITS are very similar except 
that they scale differently but they give us similar answers.

*****
DFITS
*****

"DFITS tells how unusual an observation in a data set is by combining the 
leverage and the studentized residual.  More specifically, it is the difference 
between the fitted (predicted) values calculated with and without the ith 
observation.  Having unusual data can have an influence upon the regression 
result, so it is necessary to recognize any data that might skew the results. 
An observation is considered to be unusual, for small to medium data sets, if 
the absolute value of the DFITS value calculated is greater than 1."

http://mtweb.mtsu.edu/stats/regression/level3/multiregdiag/tools/DFits/conceptdfits.htm

"The cut-off point for DFITS is 2*sqrt(k/n). DFITS can be either positive 
or negative, with numbers close to zero corresponding to the points with 
small or zero influence."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

*********
COOK's Di
*********

"In statistics, Cook's distance or Cook's D is a commonly used estimate of the 
influence of a data point when performing least squares regression analysis. 
In a practical ordinary least squares analysis, Cook's distance can be used 
in several ways: to indicate influential data points that are particularly 
worth checking for validity; to indicate regions of the design space where 
it would be good to be able to obtain more data points.  It is named after the 
American statistician R. Dennis Cook, who introduced the concept in 1977."

https://en.wikipedia.org/wiki/Cook%27s_distance

"Cook's distance is a measurement of the influence of the ith data point on 
all the other data points.  In other words, it tells how much influence the 
ith case has upon the model."

http://mtweb.mtsu.edu/stats/regression/level3/cook/concept.htm

"The lowest value that Cook's D can assume is zero, and the higher the Cook's D 
is, the more influential the point. The conventional cut-off point is 4/n. 
We can list any observation above the cut-off point by doing the following. 
We do see that the Cook's D for DC is by far the largest."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

*****
KEY TO NOTE: Both DFITS and Cook's Di combine studentized residuals and
leverage to look at influence in a more holistic way. DFITs looks at the
influence on a specific predicted value (point estimate) and Cook's Di
looks at the point's influence on all estimated points.
*/

regress crime pctmetro pctwhite poverty single

*Predict DFITS and Cook's Di

predict dfit, dfits
predict d, cooksd

/*NOTE:
We don't like strict cutoffs, but they may make it easy for us to eyeball the data
So let's set both at the more conservative cutoff suggested in Pam's notes.

For DFITs, the conservative cutoff would be anything with an absolute value greater
than 2*sqrt((k+1)/n). For Cook's Di, it is easier, just 4/n.

Again, we can use "display" to calculate in STATA.

*/

*Threshold for DFITS

di 2*sqrt((4+1)/51)
*So our answer is .62622429

*Threshold for Cook's Di

di 4/51

*So our answer is .07843137

*Listing any states with their values if the absolute value falls above our threshold.

list dfit d state if abs(dfit)>.62 | abs(d)>.07

*NOTE: This symbol "|" denotes "or" in many programming languages including Stata

*Set a couple of thresholds and graphing DFITS

scalar h1 = .62
scalar h2 = 1.2
scalar h3 = -.62
scalar h4 = -1.2
graph twoway scatter dfit sid, mlabel(state) ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
yline(`=h3', lpattern(dash)) yline(`=h4', lpattern(dash)) ///
title(DFITS by State)
graph export DFITSIndexPlot.png, replace

*Next, setting a couple of thresholds and graphing Cook's Di

scalar h1 = .07
scalar h2 = .14
graph twoway scatter d sid, mlabel(state) ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
title(Cook's D by State)
graph export CooksDIndexPlot.png, replace


**********************************************
*8) DFBETAS

/*NOTE: We have covered localized measures of influence (leverage) and
outlierness (studentized residuals), and more general measures of influence
(DFITS and Cook's Di).

"You can also consider more specific measures of influence that assess how each
coefficient is changed by deleting the observation. This measure is called 
DFBETA and is created for each of the predictors. Apparently this is more 
computational intensive than summary statistics such as Cook's D since the 
more predictors a model has, the more computation it may involve."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

KEY TO NOTE: DFBETAs give us a measure of the influence of a particular data
point on the slope of a specific coefficient/parameter estimate. In other words
how much does the coefficient of an X change when we remove that point.
Because of this, we get multiple DFBETAs, one for each of our slopes.
*/

regress crime pctmetro pctwhite poverty single //Run regression again.

dfbeta //Predict DFBETAs

/*As Dr. Paxton did in class, we'll use a conservative cutoff and put them all together
into one table. The cutoff calculation is 2/sqrt(n). Again, we use display to calculate
this.
*/

disp 2/sqrt(51)

*We get a value of .28005602
*Instead, let's just use the more intuitive .25

*Listing based on a cutoff of more than a quarter standard deviation

list state _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 if abs(_dfbeta_1)>.25 | abs(_dfbeta_2)>.25 ///
| abs(_dfbeta_3)>.25 | abs(_dfbeta_4)>.25

*Set our threshold lines at positive and negative .25, then graphing superimposed
*scatter plots of all three DFBETAS.

scalar h1 = .25
scalar h2 = -.25
graph twoway (scatter _dfbeta_1 sid, mcolor(lavender) msymbol(oh) mlabel(state) mlabcolor(lavender)) ///
(scatter _dfbeta_2 sid, mcolor(maroon) msymbol(dh) mlabel(state) mlabcolor(maroon)) ///
(scatter _dfbeta_3 sid, mcolor(emerald) msymbol(th) mlabel(state) mlabcolor(emerald)) ///
(scatter _dfbeta_4 sid, mcolor(navy) msymbol(sh) mlabel(state) mlabcolor(navy)), ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
title(DFBETAS by State)
graph export DFBETASIndexPlot.png, replace

**********************************************
*9) PUTTTING IT ALL TOGETHER (TABLES)

/* NOTE:
No single one of the measures above will tell us definitively and conclusively
if a particular outlier is actually influential. And as we noticed, some of the
cutoffs are general (subjective) rules of thumb, based mostly on how many standard
deviations away from the mean a value falls... or based on previous practice by
other researchers.

The best way to decide if a case is influential is to look holistically at all
of these measures, and see if it tends to be highly influential in a number
of ways.

In order to put it all together, we can produce a table of all of these results
and look them over as a whole. We can also do some other fancy graphs that indicate
multiple aspects.
*/

*Sorting data back to original order
sort sid

*Producing one table with all results
list state lev r dfit d _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4

*If you want to save the table to excel, you can highlight the whole table,
*and right click and select "copy table".
*Then paste it into an excel sheet so you can sort and analyze them in more detail.

/* NOTE:
Although this is useful, I would like to zoom just on the ones we think are outliers
or have influence, rather than looking at all of our good data too. So I'll reproduce
the table with all of our original thresholds. Remember to use "|" to indicate or.
*/

**********************************************
*10. Smaller table
*Producing a reduce table of culprits
list state lev r dfit d _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 if lev>.15 ///
| abs(r)>1 | abs(dfit)>.62 | abs(d)>.07 | abs(_dfbeta_1)>.25 | ///
abs(_dfbeta_2)>.25 | abs(_dfbeta_3)>.25

*Again, you can save to excel if you want, with the same technique.
*The table will also be in your log of course.


**********************************************
*11. Bonus, Bubble Plot

regress crime pctmetro pctwhite poverty single
scalar cut = 2/sqrt(51)
scalar h2 = .19607843
scalar h3 = 2*.19607843
* Bubble Plot
twoway (scatter r lev [pw=d], ms(Oh)) ///
(scatter r lev, ms(i) mlabel(state)), legend(off) ///
yline(-2, lpattern(dash)) yline(0, lpattern(dash)) yline(2, lpattern(dash)) ///
xline(`=h2', lpattern(dash) lcolor(navy)) xline(`=h3', lpattern(dash) lcolor(navy))
graph export BubblePlot.png, replace

log close

cap cd "~/Dropbox/Academic/TAing/SOC385L Spring 2016/Labs/Lab5/outliers/"
set more off, permanently
set scheme s2color
cap log close
log using LOG_Lab5_outliers.smcl, replace

use http://www.ats.ucla.edu/stat/stata/webbooks/reg/crime, clear

*********************************************************************
/*NOTE: Here are some useful references I quote below.

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm
http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg_self_assessment_answers2.htm
https://en.wikipedia.org/wiki/Studentized_residual
http://mtweb.mtsu.edu/stats/regression/level3/multiregdiag/tools/DFits/conceptdfits.htm
https://en.wikipedia.org/wiki/Cook%27s_distance
http://mtweb.mtsu.edu/stats/regression/level3/cook/concept.htm
*/

desc 

summarize

*This data set contains state/region-level information 
*on the crime rates, murder rates, poverty rates and 
*racial-ethnic compositions for 51 states/regions of the United States

*********************************************************************
*                   MULTICOLLINEARITY DETECTION			    *
*********************************************************************

/*NOTE: Here, we generally consider a VIF (Variance Inflation Factor)
over 10 to be high multicollinearity. A 1/VIF (Called Tolerance) of
less than .1 is also considered high multicollinearity.

See: (UCLA statareg2)
*/

regress crime pctmetro pctwhite pcths poverty single 

vif

*********************************************************************
*                         OUTLIERS				    *
*********************************************************************
/*Outliers: In linear regression, an outlier is an observation with large 
residual. In other words, it is an observation whose dependent-variable value 
is unusual given its values on the predictor variables. An outlier may indicate 
a sample peculiarity or may indicate a data entry error or other problem.

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm
*/


*1. Run the following regression:

regress crime pctmetro pctwhite poverty single

**********************************************
*2. Graph and interpret a scatterplot matrix

graph matrix crime pctmetro pctwhite poverty single, ///
msymbol (Oh) mlabel(state) mlabsize(vsmall) ///
title(Scatterplot Matrix) subtitle(Crime & Explanatory Variables)

graph export ScatterPlotMatrix.png, replace


**********************************************
*3.Graph and interpret some bivariate scatterplots to zoom in 
*closer on the relationships shown in the scatterplot matrix

*crime & pctmetro (subtract dc)

twoway (scatter crime pctmetro, mlabel(state)) (lfit crime pctmetro) ///
(lfit crime pctmetro if sid!=51), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc")) ///
title("Outliers: crime & pctmetro") ytitle(crime) xtitle(pctmetro) scale(.8)
graph export crime_pctmetro.png, replace

*crime & pctwhite (subtract dc, hi, ms, hi_ms, dc_hi_ms)

twoway (scatter crime pctwhite, mlabel(state)) (lfit crime pctwhite) ///
(lfit crime pctwhite if sid!=51, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=11, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=25, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=11 & sid!=25, lpattern(shortdash)) ///
(lfit crime pctwhite if sid!=11 & sid!=25 & sid!=51, lpattern(shortdash)), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc") ///
label(4 "without hi") label(5 "without ms") label(6 "without hi/ms") ///
label(7 "without dc/hi/ms")) ///
title("Outliers: crime & pctwhite") ytitle(crime) xtitle(pctwhite) scale(.8)
graph export crime_pctwhite.png, replace

*crime & poverty (subtract dc)

twoway (scatter crime poverty, mlabel(state)) (lfit crime poverty) ///
(lfit crime poverty if sid!=51, lpattern(dash)), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc")) ///
title("Outliers: crime & poverty") ytitle(crime) xtitle(poverty) scale(.8)
graph export crime_poverty.png, replace

*crime & single(subtract dc)

twoway (scatter crime single, mlabel(state)) (lfit crime single) ///
(lfit crime single if sid!=51, lpattern(dash)), ///
legend(label(1 "states") label(2 "full model") label(3 "without dc")) ///
title("Outliers: crime & single") ytitle(crime) xtitle(single) scale(.8)
graph export crime_single.png, replace

*************************************************************************
*4. Partial regression plots

/*Stata calls them Added-Variable Plots (AVPLOTS)
"The avplot command graphs an added-variable plot. 
It is also called a partial-regression plot and is very useful 
in identifying influential points." 

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

In layman's (or laywoman's) terms, what a partial regression plot does is this:

1) Regress X2 X3 X4 on Y, and grab the residual.
2) Regress X2 X3 X4 on X1, and grab the residual.
3) Regress the residual from 2 on the residual from 1.
4) Make a scatterplot of the two residuals and a fitted line.

**This represents the slope (coefficient) or effect of X1 on Y after accounting
for the effects of all other X variables. In other words, "holding all else
constant" as in a multiple regression.*/

*Run the regression first

regress crime pctmetro pctwhite poverty single

*Partial regression

avplots, mlabel(state) scale(0.95)

graph export partialreg.png, replace

*************************************************************************
*5. Leverage prediction (hat matrix)

/*"Leverage: An observation with an extreme value on a predictor variable is 
called a point with high leverage. Leverage is a measure of how far an 
observation deviates from the mean of that variable. These leverage points 
can have an effect on the estimate of regression coefficients."

KEY TO NOTE: Points with high leverage "CAN have an effect on the estimate
of regression coefficients" but leverage is not measuring this effect. It is
simply how far the point falls from the predicted/fitted value. Depending on 
other factors, it may or may not pull the line toward it much. We need to 
look at some other measures. And the true test is what happens when you 
remove it. 

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm
*/

regress crime pctmetro pctwhite poverty single

predict lev, leverage

gsort -lev    //sort in descending order:sorting lev values from larger to smaller

list state lev in 1/10 //Top ten

/*Calculating the cut-off points (2*k+2)/n. A point with leverage greater 
than (2K+2)/n should be carefully examined. Here K is the number of 
predictors and n is the number of observations.*/

di (2*4+2)/51
		
**The answer is .19607843

list state lev if lev > .19607843

**Set a couple of thresholds: visualize the levels of leverage for each case

scalar h2 = .19607843
scalar h3 = 2*.19607843
graph twoway scatter lev sid, mlabel(state) ///
yline(`=h2', lpattern(dash)) yline(`=h3', lpattern(dash)) ///
title(Leverage by State)
graph export LeverageIndexPlot.png, replace

*************************************************************************
/*"Influence: An observation is said to be influential if removing the 
observation substantially changes the estimate of coefficients. Influence 
can be thought of as the product of leverage and outlierness."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

Leverage is just one possible measure of influence.
*/

*************************************************************************
*6) Predicting Studentized Residuals

/*Studentized residuals are a type of standardized residual 
that can be used to identify outliers.

From Wikipedia: https://en.wikipedia.org/wiki/Studentized_residual

"In statistics, a studentized residual is the quotient resulting from the 
division of a residual by an estimate of its standard deviation. Typically 
the standard deviations of residuals in a sample vary greatly from one data 
point to another even when the errors all have the same standard deviation, 
particularly in regression analysis; thus it does not make sense to compare 
residuals at different data points without first studentizing. It is a form 
of a Student's t-statistic, with the estimate of error varying between points.

This is an important technique in the detection of outliers. It is among 
several named in honor of William Sealey Gosset, who wrote under the pseudonym 
Student, and dividing by an estimate of scale is called studentizing, 
in analogy with standardizing and normalizing."

KEY TO KNOW: "Studentized" is just a type of standardized residual named after
a guy who went by Student. It helps put leverage and residuals in perspective
by making them comparable across all observations in the range of X.
*/

*Run regression again (in case we did something else since the last run)

regress crime pctmetro pctwhite poverty single

predict r, rstudent //Predict Studentized Residuals

sort r //Sorting r

*Listing state and r if r is greater than absolute 1

list r state if abs(r)>1

*Set a couple of thresholds

scalar h1 = 1
scalar h2 = 2
scalar h3 = -1
scalar h4 = -2
graph twoway scatter r sid, mlabel(state) ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
yline(`=h3', lpattern(dash)) yline(`=h4', lpattern(dash)) ///
title(Studentized Residuals by State)
graph export StudResIndexPlot.png, replace

/*KEY TO NOTE: So far, leverage and studentized residuals only show us localized
measures of influence, which compare the influence of an observation
(data point) at a particular place in the regression (range of x).

The following measures DFITS, Cook's Di provide more general,
overall measures of influence.
*/

**********************************************
*7) DFITS and Cook's Di

/* KEY TO NOTE: Now let's move on to overall measures of influence, 
specifically let's look at Cook's D and DFITS. These measures both 
combine information on the studentized residuals (outlierness) and 
leverage (hat matrix). Cook's D and DFITS are very similar except 
that they scale differently but they give us similar answers.

*****
DFITS
*****

"DFITS tells how unusual an observation in a data set is by combining the 
leverage and the studentized residual.  More specifically, it is the difference 
between the fitted (predicted) values calculated with and without the ith 
observation.  Having unusual data can have an influence upon the regression 
result, so it is necessary to recognize any data that might skew the results. 
An observation is considered to be unusual, for small to medium data sets, if 
the absolute value of the DFITS value calculated is greater than 1."

http://mtweb.mtsu.edu/stats/regression/level3/multiregdiag/tools/DFits/conceptdfits.htm

"The cut-off point for DFITS is 2*sqrt(k/n). DFITS can be either positive 
or negative, with numbers close to zero corresponding to the points with 
small or zero influence."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

*********
COOK's Di
*********

"In statistics, Cook's distance or Cook's D is a commonly used estimate of the 
influence of a data point when performing least squares regression analysis. 
In a practical ordinary least squares analysis, Cook's distance can be used 
in several ways: to indicate influential data points that are particularly 
worth checking for validity; to indicate regions of the design space where 
it would be good to be able to obtain more data points.  It is named after the 
American statistician R. Dennis Cook, who introduced the concept in 1977."

https://en.wikipedia.org/wiki/Cook%27s_distance

"Cook's distance is a measurement of the influence of the ith data point on 
all the other data points.  In other words, it tells how much influence the 
ith case has upon the model."

http://mtweb.mtsu.edu/stats/regression/level3/cook/concept.htm

"The lowest value that Cook's D can assume is zero, and the higher the Cook's D 
is, the more influential the point. The conventional cut-off point is 4/n. 
We can list any observation above the cut-off point by doing the following. 
We do see that the Cook's D for DC is by far the largest."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

*****
KEY TO NOTE: Both DFITS and Cook's Di combine studentized residuals and
leverage to look at influence in a more holistic way. DFITs looks at the
influence on a specific predicted value (point estimate) and Cook's Di
looks at the point's influence on all estimated points.
*/

regress crime pctmetro pctwhite poverty single

*Predict DFITS and Cook's Di

predict dfit, dfits
predict d, cooksd

/*NOTE:
We don't like strict cutoffs, but they may make it easy for us to eyeball the data
So let's set both at the more conservative cutoff suggested in Pam's notes.

For DFITs, the conservative cutoff would be anything with an absolute value greater
than 2*sqrt((k+1)/n). For Cook's Di, it is easier, just 4/n.

Again, we can use "display" to calculate in STATA.

*/

*Threshold for DFITS

di 2*sqrt((4+1)/51)
*So our answer is .62622429

*Threshold for Cook's Di

di 4/51

*So our answer is .07843137

*Listing any states with their values if the absolute value falls above our threshold.

list dfit d state if abs(dfit)>.62 | abs(d)>.07

*NOTE: This symbol "|" denotes "or" in many programming languages including Stata

*Set a couple of thresholds and graphing DFITS

scalar h1 = .62
scalar h2 = 1.2
scalar h3 = -.62
scalar h4 = -1.2
graph twoway scatter dfit sid, mlabel(state) ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
yline(`=h3', lpattern(dash)) yline(`=h4', lpattern(dash)) ///
title(DFITS by State)
graph export DFITSIndexPlot.png, replace

*Next, setting a couple of thresholds and graphing Cook's Di

scalar h1 = .07
scalar h2 = .14
graph twoway scatter d sid, mlabel(state) ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
title(Cook's D by State)
graph export CooksDIndexPlot.png, replace


**********************************************
*8) DFBETAS

/*NOTE: We have covered localized measures of influence (leverage) and
outlierness (studentized residuals), and more general measures of influence
(DFITS and Cook's Di).

"You can also consider more specific measures of influence that assess how each
coefficient is changed by deleting the observation. This measure is called 
DFBETA and is created for each of the predictors. Apparently this is more 
computational intensive than summary statistics such as Cook's D since the 
more predictors a model has, the more computation it may involve."

http://www.ats.ucla.edu/stat/stata/webbooks/reg/chapter2/statareg2.htm

KEY TO NOTE: DFBETAs give us a measure of the influence of a particular data
point on the slope of a specific coefficient/parameter estimate. In other words
how much does the coefficient of an X change when we remove that point.
Because of this, we get multiple DFBETAs, one for each of our slopes.
*/

regress crime pctmetro pctwhite poverty single //Run regression again.

dfbeta //Predict DFBETAs

/*As Dr. Paxton did in class, we'll use a conservative cutoff and put them all together
into one table. The cutoff calculation is 2/sqrt(n). Again, we use display to calculate
this.
*/

disp 2/sqrt(51)

*We get a value of .28005602
*Instead, let's just use the more intuitive .25

*Listing based on a cutoff of more than a quarter standard deviation

list state _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 if abs(_dfbeta_1)>.25 | abs(_dfbeta_2)>.25 ///
| abs(_dfbeta_3)>.25 | abs(_dfbeta_4)>.25

*Set our threshold lines at positive and negative .25, then graphing superimposed
*scatter plots of all three DFBETAS.

scalar h1 = .25
scalar h2 = -.25
graph twoway (scatter _dfbeta_1 sid, mcolor(lavender) msymbol(oh) mlabel(state) mlabcolor(lavender)) ///
(scatter _dfbeta_2 sid, mcolor(maroon) msymbol(dh) mlabel(state) mlabcolor(maroon)) ///
(scatter _dfbeta_3 sid, mcolor(emerald) msymbol(th) mlabel(state) mlabcolor(emerald)) ///
(scatter _dfbeta_4 sid, mcolor(navy) msymbol(sh) mlabel(state) mlabcolor(navy)), ///
yline(`=h1', lpattern(dash)) yline(`=h2', lpattern(dash)) ///
title(DFBETAS by State)
graph export DFBETASIndexPlot.png, replace

**********************************************
*9) PUTTTING IT ALL TOGETHER (TABLES)

/* NOTE:
No single one of the measures above will tell us definitively and conclusively
if a particular outlier is actually influential. And as we noticed, some of the
cutoffs are general (subjective) rules of thumb, based mostly on how many standard
deviations away from the mean a value falls... or based on previous practice by
other researchers.

The best way to decide if a case is influential is to look holistically at all
of these measures, and see if it tends to be highly influential in a number
of ways.

In order to put it all together, we can produce a table of all of these results
and look them over as a whole. We can also do some other fancy graphs that indicate
multiple aspects.
*/

*Sorting data back to original order
sort sid

*Producing one table with all results
list state lev r dfit d _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4

*If you want to save the table to excel, you can highlight the whole table,
*and right click and select "copy table".
*Then paste it into an excel sheet so you can sort and analyze them in more detail.

/* NOTE:
Although this is useful, I would like to zoom just on the ones we think are outliers
or have influence, rather than looking at all of our good data too. So I'll reproduce
the table with all of our original thresholds. Remember to use "|" to indicate or.
*/

**********************************************
*10. Smaller table
*Producing a reduce table of culprits
list state lev r dfit d _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 if lev>.15 ///
| abs(r)>1 | abs(dfit)>.62 | abs(d)>.07 | abs(_dfbeta_1)>.25 | ///
abs(_dfbeta_2)>.25 | abs(_dfbeta_3)>.25

*Again, you can save to excel if you want, with the same technique.
*The table will also be in your log of course.


**********************************************
*11. Bonus, Bubble Plot

regress crime pctmetro pctwhite poverty single
scalar cut = 2/sqrt(51)
scalar h2 = .19607843
scalar h3 = 2*.19607843
* Bubble Plot
twoway (scatter r lev [pw=d], ms(Oh)) ///
(scatter r lev, ms(i) mlabel(state)), legend(off) ///
yline(-2, lpattern(dash)) yline(0, lpattern(dash)) yline(2, lpattern(dash)) ///
xline(`=h2', lpattern(dash) lcolor(navy)) xline(`=h3', lpattern(dash) lcolor(navy))
graph export BubblePlot.png, replace

log close
