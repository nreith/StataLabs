
********************************************************************************
* DO File - Heteroskedasticity
********************************************************************************

****************
*Setup
****************

	cap cd "~/Dropbox/Git/repositories/StataLabs/4.Heteroskedasticity/"
	set more off, permanently
	cap log close
	log using heteroskedasticity.smcl, replace

	use http://www.ats.ucla.edu/stat/stata/webbooks/reg/crime, clear

****************
*#0 Intro Discussion on Hetero/Homo-skedasticity
****************
		/*Let's talk a bit about the problem of heteroskedasticity.
		
		Since constant variance (homoskedasticity) is one of the main
		assumptions of OLS regression, Stata and other statistical packages
		assume this is the case and calculate the sample variance based on
		this assumption.
		
Causes:
	
		Here are some examples of why you might have heteroskedasticity:
		
		* Errors may increase if value of explanatory variables increase
			e.g. family income and family expenditures on vacations or
			sales of large vs. small firms firm size
		* Errors may increase if extreme positions e.g. attitudes 
			(hourglass shape)
		* or for different subpopulations 
			e.g. expenditures and income for white vs. black
		* misspecification can cause HK 
			e.g. instead of using Y you should use log of Y,
			instead of X you should use X2..
			
Consequences:

		* Does NOT result in biaised estimates! Yay!
		* But, OLS no longer BLUE... because it is inefficient
		* Variance will no longer be the smallest! Boo!
		* This means STANDARD ERRORS ARE BIAISED! So, we know our coefficient
			estimates, but our tests of significance (t-tests, f-tests, etc.)
			can be wrong and draw wrong conclusions (too high, too low, etc.)
		* For some other types of regression aside from OLS (for example, Logistic)
			it can also biaise parameter (coefficient) estimates
			
Treatment:
		
		a) Visual inspection
		b) Tests for heteroskedasticity to confirm
		c) Structural Fixes:
			If we know the structure/patterns, for example, that it is 
			homoskedastic within groups, but not across groups, we can use 
			clustering options in Stata to correct this. Or we can solve
			other problems by transforming variables first if necessary.
				
			In practice however, we often don't know the structure or patterns of
			heteroskedasticity. So, instead... we treat it in the following ways.
		d) Using weighted least squares regression to adjust for heteroskedasticity
			GLS estimation minimizes a weighted sum of squared residuals
			That error terms with large variance get a smaller weight than 
			observations with small variance
		e) Simply using regression with robust standard errors.	*/
	
	
****************
*#1 Run regression model
****************

	regress crime pctmetro pctwhite single

****************
*#2 Visually Inspect for heteroskedasticity
****************

	/*residual-versus-fitted plots

	rvfplot graphs a residual-versus-fitted plot, 
	a graph of the residuals against thefitted values.

	NOTE: There are all kinds of other automated postregression diagnostic plots

	In stata, type: "help regress postestimation plots" to see some others.

	What we are looking for in this rvfplot is to see if the residuals display
	an approximately even spread on the vertical Y axis, as we move out along
	the X axis. 
	*/

	rvfplot
	graph export rvfplot.png, replace as(png)

	/*In the graph above, we can see that there is not a big change in variance
	across the fitted values, although it does seem to have a downward trend.*/

	****************
	/*Next, we can do some rvfplots looking at those same residuals and how they
	behave as we increase values of certain X variables, to see if there is some
	heteroskedasticity in the relationship of some of our X variables.*/

	rvpplot pctmetro
	graph export rvfplotmetro.png, replace as(png)

	*Above, also looks pretty even.

	rvpplot pctwhite
	graph export rvfplotwhite.png, replace as(png)

	*Again, pretty even (up and down), though more values are clumped to the right

	rvpplot single
	graph export rvfplotsingle.png, replace as(png)

	*Finally, this one also looks pretty even... although we see a bit of narrowing

****************
*#3 Some Statistical Tests for Heteroskedasticity
****************

*Why two different tests?
	*Breusch-Pagan works well if linear forms but not for non-linear forms
	*White Test works well for non-linear forms, but adds many terms 
		*in the test regression sometimes a simpler test like BP is more appropiate

	*Breusch-Pagan / Cook-Weisberg test
	****************
	/* estat hettest performs three versions of the Breusch-Pagan (1979) and
		Cook-Weisberg (1983) test for heteroskedasticity.  All three versions of this test
		present evidence against the null hypothesis that t=0 in Var(e)=sigma^2 exp(zt).
		In the normal version, performed by default, the null hypothesis also includes the
		assumption that the regression disturbances are independent-normal draws with
		variance sigma^2.  The normality assumption is dropped from the null hypothesis in
		the iid and fstat versions, which respectively produce the score and F tests
		discussed in Methods and formulas in [R] regress postestimation.  If varlist is
		not specified, the fitted values are used for z.  If varlist or the rhs option is
		specified, the variables specified are used for z.
	*/

	estat hettest

	/*With a p-value of less than .05, we reject the null hypothesis of constant
	variance, meaning we have evidence of heteroskedasticity*/

	*White Test
	****************
	/* estat imtest performs an information matrix test for the regression model and an
		orthogonal decomposition into tests for heteroskedasticity, skewness, and kurtosis
		due to Cameron and Trivedi (1990); White's test for homoskedasticity against
		unrestricted forms of heteroskedasticity (1980) is available as an option.
		White's test is usually similar to the first term of the Cameron-Trivedi
		decomposition.
	*/

	estat imtest, white

	/*Here, we are presented with a number of statistics.
	First, White's test also indicates heteroskedasticity because of a small p-value.
	We are also told that we have skewness in our variable, but no kurtosis.*/

****************
*#4 Weighted Least Squares - Correction
****************

	*Step 1: Predict residuals
	predict r, residuals

	*Step 2: Log squared residual variable
	gen ln_r2=ln(r^2)

	*Step 3: Rerun regression with new logged, squared residual in place of dv
	regress ln_r2 pctmetro pctwhite single

	*Step 4: Predict fitted values
	predict hat_ln_r2, xb

	*Step 5: Exponentiate the fitted values variable
	gen hat_r2=exp(hat_ln_r2)

	*Step 6: Run full model again correcting for heteroskedasticity by using
		* aweight 1/(exp fitted value var here) at the end of regression
	gen weights=1/hat_r2

		*Let's rerun our original regression for comparison
		regress crime pctmetro pctwhite single

	*Step 7: Now, run with weights
	regress crime pctmetro pctwhite single [aw=weights]

	/*NOTE: Some changes in coefficients and standard errors, by accounting for
	the heteroskedasticity*/

	*Step 8: Re-test

	estat hettest
	cap estat imtest, white //NOTE the error message. Doesn't work with weights.

	/*Here above, the hettest shows we still have heteroskedasticity.
	This is because, the WLS does not remove it, but it does correct for it
	by weighting observations based on their residuals*/
	
	/*NOTE: If we had evidence that one of our variables was the main culprit
	in terms of causing heteroskedasticity, it could be possible to do WLS
	based only on that variable, and not do the entire process above.
	
	For example, you might create weights like this:
	
	gen weights=(1/variable)^2
	
	and then re-run the weighted regression.*/
****************
*#5 Robust Standard Errors - Correction
****************

	regress crime pctmetro pctwhite single, hc3

	*Re-running original model for comparison

	regress crime pctmetro pctwhite single

log close
