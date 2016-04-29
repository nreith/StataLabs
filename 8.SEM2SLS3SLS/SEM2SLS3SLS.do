*Do File for Lab 8 - Simultaneous Equations:
*Nonrecursive Model with Instrumental Variables

clear all

cd "C:\Dropbox\UT\TAing\Sociology 385L-SSC 385\Labs\Lab8"

use "Lab8.dta", clear

set more off

*******************************************************************

*#1 Describe the data

desc


*******************************************************************

*#5 Models from Figure 2.4 and 2.5 ignoring simultaneity

**IGNORING SIMULTANEITY 2.4
reg civpart intprtrst educ babies, beta
reg intprtrst civpart educ burglary, beta

**IGNORING SIMULTANEITY 2.5
reg civpart intprtrst educ tvhours babies, beta
reg intprtrst civpart educ burglary pardiv16, beta

/*You know how to interpret normal regressions, so I don't need to help here.
Most importantly, you'll notice significant coefficients for each Association
Civic Participation and Trust in predicting each other.
*/

*******************************************************************

*#6 First model, 2sls with one instrumental variable per equation

**MODEL WITH ONE IV PER EQUATION
*civic participation equation
ivregress 2sls civpart (intprtrst = burglary) educ babies, first
estat firststage 
estat endogenous

/*For our first equation, we can interpret as follows:

The first stage results give overall joint signifance according to an F-test
and show the coefficients of our exogenous variables used to estimate trust,
all of which are significant. I will not interpret each coefficient here
because we are mainly interested in the second stage results.

Second stage:

- A small Probability of Chi2 close to zero, and high Wald Chi2 statistic means
our model is significant on the whole.
- We have an R-squared of .11, meaning we seem to explain 11% of the variation in 
our model, predicting Participation in Civic Associations
-Let's look at the units of analysis of each of our variables to help with interpretation:
*/
sum civpart intprtrst burglary educ babies
/*
So, CIVPART is measured as a count of orgs volunteered for from 0-11,
BURGLARY is a dummy variable for whether or not the person has been 
burglarized in the last year,
EDUC is years of education measured from 0 to 20,
BABIES is the number of small children from 0 to 4,
and INTPRTRST (interpersonal trust) is a factor score previously created that combines
three variables about "the extent to which the respondent feels people in general:
(1) are fair, (2) are helpful, and (3) can be trusted. It ranges from -2.24 to 2.5.

So our coefficients tell us that:
- Trust is not a significant predictor of Associations after we control for
the effect of the other exogenous variables on Trust.
-But one additional year of education yields .18 additional orgs, or about 1 more
org for each 5 years of education.
-Having one additional small child is expected to lead to .19 less orgs, more or less
cancelling out the one year effect from education.

-And of course, we need to take our constant here with a grain of salt because it is not
possible to volunteer for a negative number of organizations. Usually zero education is
not typical, but we do have 7 people in our dataset who have zero educ.*/

list educ babies burglary intprtrst civpart if educ==0

/*
Continuing with our interpretation, we now look at the postestimation commands.
estat firststage gives the data from the first stage of this 2 stage regression,
which you recall is the prediction of trust with the instrumental variable burglary.
- It has a small p-value for the F-test, so the variables (in this case just one) are
jointly significant.
- We also notice an R-squared of .07, so 7% of the variation in trust is explained
by burglary in the last year, and nearly the same for the Adjusted-R-squared
- And the partial R-squared of .01 indicates that very little of the variation in trust
is due to burglary once other variables are held constant. This similar to "partial
regression plots" or avplots, but for R-squared. Though, since our first stage only
has burglary, I'm not sure what other variables stata is controlling for here.

The second part of the first-stage output tells us about our instrumental variables.

The critical value required to reject the null hypothesis of a "weak instrument"
is 46 (approximately), and we see that the eigenvalues we get for 2sls in the second
line from the bottom are below this threshold. Therefore, as indicated by the low
R-squareds above, burglary is probably a weak instrument for trust.

We can ignore LIML because that is for another type of estimation model.
*/

/*Finally, we can interpret the output from estat endogenous, which is telling us
whether the endogenous variables (trust) in our model are actually exogenous
(this is the null hypothesis). With very high p-values and low chi2 and F statistics,
we reject the null hypothesis with both tests.

Not only is our instrument for trust weak, but it seems trust may not actually be
endogenous afterall.
*/

*******************************************************************

*#6 Second part

*interpersonal trust equation
ivregress 2sls intprtrst (civpart = babies) educ burglary, first
estat firststage
estat endogenous 

*Sum the variables again if you forgot the units of analysis for interpretation of the coefficients.

sum intprtrst civpart babies educ burglary

*The output looks similar, so I will leave the interpretation of this one up to you.


*******************************************************************

*#7 Second model, Figure 2.5, 2sls with two instrumental variables per equation

/*Again, I'll leave interpretation of the output below up to you.
Note however one additional postestimation command used for this model:
estat overid provides chi2 tests (two versions by Sargan 1958 and Basmann 1960)
From the Stata help files:
"These are tests of the joint null hypothesis that the excluded instruments are valid
instruments, i.e., uncorrelated with the error term and correctly excluded from the
estimated equation.  A rejection casts doubt on the validity of the instruments."
*/

**MODEL WITH TWO IV'S PER EQUATION
*voluntary associations equation
ivregress 2sls civpart (intprtrst = burglary pardiv16) educ tvhours babies, first
estat firststage 
estat overid 
estat endogenous

sum civpart intprtrst burglary pardiv16 educ tvhours babies

*interpersonal trust equation
ivregress 2sls intprtrst (civpart = babies tvhours) educ burglary pardiv16, first
estat firststage 
estat overid 
estat endogenous

sum civpart intprtrst burglary pardiv16 educ tvhours babies


/*
Addendum on 3-Stage Least Squares
NOTE:
The models above do account for the simultaneous effects of our two endogenous variables, but they do not fully account for the correlation between the error terms in each of our equations. We can improve on the estimation techniques above by moving to Three-Stage Least Squares, a technique that goes beyond OLS again by combining Two-Stage Least Squares and Seemingly Unrelated Regressions (SUR). 3SLS has an advantage over 2SLS the more highly correlated the error terms of the equations are. A brief explanation of the steps involved is taken from this website.

Summing up, the three-stage least squares estimator of in (4.9) is obtained by carrying out the following three-steps: 
1)	The first stage is identical to the two-stage procedure: instruments for the endogenous regressors are computed as the predicted values of an ordinary least squares regression of each endogenous regressor on all exogenous regressors. 
2)	In the second stage, the two-stage least squares estimator for each equation is computed and the residuals are used according to (4.14) to obtain an estimate of the covariance matrix of the error terms of the SEQM. 
3)	In the third stage, the estimate of is used to calculate the generalized least squares estimator defined in (4.15) and an estimate of its covariance matrix as described in (4.16) 

Let’s go ahead and run both models from Figures 2.4 and 2.5 then with 3SLS. Be sure to interpret results and postestimation commands.
*/


*#8 Three Stage Least Squares

*Model from Figure 2.4
**3SLS
reg3 (civpart intprtrst educ babies) (intprtrst civpart educ burglary), first
estat ic

/*Note: The stats we see here include the AIC and BIC, both of which are used
to compare models, which unlike with the Chi2 and likelihood ratio tests,
do not need to be nested models. We are looking for the model with the smaller
AIC and BIC. */

*Model from Figure 2.5
**3SLS
reg3 (civpart intprtrst educ babies tvhours) (intprtrst civpart educ burglary pardiv16), first
estat ic

