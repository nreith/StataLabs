*Time-Series Panel Data
*Fixed and Random Effects

* stata has loaded the National Longitudinal Study
webuse nlswork, clear

*#1 Describe Data
********************************************************************************

desc

*the dataset contains 28,091 ìobservationsî, 
*which are 4,697 people, each observed, on average, on 6.0 different years. 
*An observation in our data is a person in a given year. 
*The dataset contains variable idcode, which identifies the persons ó the i index in x[i,t]. 
*Before fitting the model, we type xtset idcode to tell Stata this. 

*#2 XT Set the Data and take a closer look
********************************************************************************

xtset idcode year

xtsum ln_wage ttl_exp tenure age nev_mar collgrad south

tab race, gen(r)
ren r1 white
ren r2 black
ren r3 otherrace

*#3 OLS Regression
********************************************************************************

/*Note that here we do not account for "unobserved heterogeneity" also called
"heterogeneity bias," so the model is not efficient because there could be
things we don't measure about individual respondents that affect their over-time
values for the outcome variable (logged wages).
*/

reg ln_wage ttl_exp tenure age nev_mar collgrad south black
	
	* note that 2.race is a quick way to get an indicator for black

xtserial ln_wage ttl_exp tenure age nev_mar collgrad south black


********************************************************************************
/*
In Analysis of Variance and some other methodologies, 
	there are two types of factors: 
	fixed effect and random effect. 

Which type is appropriate depends on the context of the problem, 
	the questions of interest, and how the data is gathered. 
	Here are the differences:

Fixed effect factor: Data has been gathered from all the levels of the 
	factor that are of interest.

Example: The purpose of an experiment is to compare the effects of three 
	specific dosages of a drug on the response. "Dosage" is the factor; 
	the three specific dosages in the experiment are the levels; there is no 
	intent to say anything about other dosages.

Random effect factor: The factor has many possible levels, interest 
	is in all possible levels, but only a random sample of levels 
	is included in the data.

Example: A large manufacturer of widgets is interested in studying the 
	effect of machine operator on the quality final product. The researcher 
	selects a random sample of operators from the large number of operators 
	at the various facilities that manufacture the widgets. The factor is 
	"operator." The analysis will not estimate the effect of each of the 
	operators in the sample, but will instead estimate the variability 
	attributable to the factor "operator".
*/

*#4 Fixed Effects:
********************************************************************************
/*Recall from Pam's notes...

A fixed effects model is one way to account for heterogeneity biais.
It includes additional parameters for each group (respondent) to account
for time-invariant characteristics of those individuals. Though Stata won't
show all of the output for this, it is similar to including a dummy variable for
each individual, so is sometimes called "LSDV (Least Squares with Dummy Variables)."
This does take care of the problem of heterogeneity bias by allowing
different intercepts for each individual/group in the data, but does not have
a general intercept, and does not allow the inclusion of time-invariant variables,
which we will see in a moment.*/

* okay, so lets run fixed effects
xtreg ln_wage ttl_exp tenure age nev_mar collgrad south 2.race, fe

		/*Let's interpret:
		
		Note the obs, groups, and obs per groups... etc.
		See the f-test for joint significance... some of our variables are significant

		What the heck is corr(u_i, Xb)  = 0.1993  ?
			We can interpret this as saying there is a positive correlation among
			an individual person's residual and their predicted value, i.e.
			the individuals with high wages tend to have positive residuals
			that reinforce their expected values.
		
		But there is another reason to take note of this... one assumption
			of the random effects model we will do next is that fixed effects residuals
			are uncorrelated with the fixed effects predicted values... So if this
			number is very high (sorry I don't have a cutoff) it may not be a good
			candidate to model as random effects.
		
		Note that collgrad and black were omitted from the model 
			because they do not vary within person... i.e. they are time-invariant. 

		Note that stata uses u_i to indicate the fixed effects units
			(what we called e in our handout)
		Note: from the Stata help for xtreg:
			e(sigma_u)          panel-level standard deviation
			e(sigma_e)          standard deviation of epsilon_it
			so rho is telling us that about 61% of the variance is due 
			to across-person differences
		
		We also notice that there are now three types of R-squared:
			1) One for the amount explained within observations (within
				respondents over time)
			2) One for explaining the variation among respondents
			3) And another combined measure of the overall share of
				variation explained in the model

*#5 Random Effects
********************************************************************************

/*Recall from Pam's Notes:
	A more efficient, but also more difficult to interpret and complicated method
		to deal with unobserved heterogeneity in time-series panel data is a 
		"random effects model." This one makes additional assumptions that 
		
		1) the expected value of individual within group (person) errors are 
			zero and their variance is constant within group,
		2) that there is no correlation between a person's error at a specific 
			time and their overall error
		3) that the combined variance of their time specific error and overall 
			error for individuals is constant
		4) and that there is a random component called rho, which captures 
			the unobserved heterogeneity (instead of a fixed effects 
			component in the last model)

	The advantage to the random component is that it is just one additional 
	parameter, instead of one for each individual, since this was moved to the 
	error term with ei, and frees us up to include time-invariant variables in 
	the	model (i.e. race and collgrad, or whatever we want).

	The mechanism by which this is calculated with GLS by subtracting a fraction
	of the unit specific mean from each observed value of y per unit-time is 
	described in more detail in Pam's notes.*/

		
	To fit the corresponding random-effects model, 
	we use the same command but change the fe option to re. */
	
xtreg ln_wage ttl_exp tenure age nev_mar collgrad south black, re
		
/*		We now get back estimates for those time-invariant variables

		Let's interpret:
		The output looks similar in many ways, except we now calculate
			with GLS instead of OLS.
		
		We still have obs, groups, and obs per group.
		We still have 3 types of R-squared.
		We still have corr(u_i, X) but now it is assumed to be zero!
			Remember that from above.
		Now, we have a chi2 test instead of an f-test
			Similarly though, with such a small p-value and high chi2,
			we reject the null hypothesis, and thus at least some of
			our variables are significant.
			
		We see similar results, though the coefficients change a bit.
			Importantly though, we now are able to estimate collgrad and black
		
		sigma_u, sigma_e still mean the same thing.
		And rho tells us how much of the variance is due to the random parameter
			we have now included.
		
		So, we see that this is a more efficient and preferable model in some 
			cases... but we also can see one of the reasons not everyone loves it.
			The u_i, Xb correlation above was .19 (19%)... and yet the random 
			effects	model assumes it to be zero. This is one reason there 
			continues to be some debate. Often, these things come down to a 
			trade-off between theory/interpretability, and the "best fitting" 
			model for the data.*/
		
*#6 Hausman test.
********************************************************************************

/*If we are unsure which of the models we should choose, fe or re,
we can do a Hausman specification test. We run each of the regressions 
and store their estimates, and then we compare them.*/

qui xtreg ln_wage ttl_exp tenure age nev_mar collgrad south black, fe
estimates store fe
qui xtreg ln_wage ttl_exp tenure age nev_mar collgrad south black, re
estimates store re
hausman fe re

	/*For this test, Stata is lovely and gives us a very clear explanation
	of what we should be looking for. Basically, it compares the coefficients
	from both models to see if there is a significant systematic (overall)
	difference between them. With a small p-value, we conclude that we reject
	the null hypothesis (i.e. it shows that the differences are systematic)
	and we should probably use a fixed-effects model.
	Remember the corr(u_i, Xb)? That might be one early indication of what
	we see here.*/

********************************************************************************
	
clear all
*EXAMPLE #2
********************************************************************************

*1982-1988 state level data for 48 U.S. States on traffice fatality rates (deaths per 100,000)
use http://www.stata-press.com/data/imeus/traffic, clear

*xtsum gives us some basic information by unit and year.  
*including state and year help us understand what is within and what is between;
xtsum fatal beertax spircons unrate perincK state year
* you can see, for example, that beer tax varies much more between states
* than within them for this 7 year period. 
* that makes sense.

reg fatal beertax spircons unrate perincK

xtreg fatal beertax spircons unrate perincK, fe
* estimate of rho suggests that almost all variation in fatal is interstate differences
* F test at bottom tells us there are significant state level effects 

xtreg fatal beertax spircons unrate perincK, re
* we see some pretty different results here

* so, do we think we should do random effects?
estimates store random_effects
quietly xtreg fatal beertax spircons unrate perincK, fe
hausman . random_effects
	*significant p-value suggests that we should use fixed effects here
	*not surprising considering we saw very different results

	* note that we could also include time variables if we thought there might be 
	* differences across time
	* stata can't automatically do such a "two-way fixed effect model
	* but we can generate and add the time effects

quietly tabulate year, generate(yr)

rename yr1 yr82
rename yr2 yr83
rename yr3 yr84
rename yr4 yr85
rename yr5 yr86
rename yr6 yr87
rename yr7 yr88

drop yr7
	* we have to avoid multicollinearity

xtreg fatal beertax spircons unrate perincK yr*, fe
test yr82 yr83 yr84 yr85 yr86 yr87
	* basic results stay the same
	* the years are jointly significant
	
