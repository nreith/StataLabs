*Autocorrelation Lab

********************************************************************************
* SETUP
********************************************************************************

cap cd "~/Dropbox/Academic/TAing/SOC385L Spring 2016/Labs/Lab7/"
set more off, permanently
set scheme s2color
cap log close
log using LOG_Lab7_autocorrelation.smcl, replace

********************************************************************************
* TRAFFIC DATA
********************************************************************************

use "http://fmwww.bc.edu/ec-p/data/wooldridge/traffic2.dta", clear

label var prcfat "100*(fatacc/totacc)"
label var wkends "# weekends in month"
label var unem "state unemployment rate"
label var spdlaw "=1 after 65mph in effect"
label var beltlaw "=1 after seatbelt law"
label var t "time trend"

desc prcfat wkends unem spdlaw beltlaw t feb mar apr may jun jul aug sep oct nov dec

sum  prcfat wkends unem spdlaw beltlaw t


********************************************************************************
* REVIEW OF MULTI-COLLINEARITY
********************************************************************************

*Recall how we test this.
regress prcfat wkends unem spdlaw beltlaw
vif

/*
CORRELATION VS. MULTI-COLLINEARITY

Multi-collinearity in a regression is a direct result of
high levels of correlation (collinearity) between two variables. So testing
for correlation can help identify potential multi-collinearity, but a VIF
or Tolearance test is more definitive, as it takes into account the entire model.

"In statistics, multicollinearity (also collinearity) is a phenomenon in which 
two or more predictor variables in a multiple regression model are highly 
correlated, meaning that one can be linearly predicted from the others with 
a substantial degree of accuracy. In this situation the coefficient estimates 
of the multiple regression may change erratically in response to small changes 
in the model or the data. Multicollinearity does not reduce the predictive power 
or reliability of the model as a whole, at least within the sample data set; 
it only affects calculations regarding individual predictors. That is, a 
multiple regression model with correlated predictors can indicate how well 
the entire bundle of predictors predicts the outcome variable, but it may not 
give valid results about any individual predictor, or about which predictors 
are redundant with respect to others."

From: https://en.wikipedia.org/wiki/Multicollinearity

A common way to evaluate collinearity is with variance inflation factors (VIFs). 
This can be achieved in R using the 'vif' function within the 'car' package. 
This has an advantage over looking at only the correlations between two variables, 
as it simultaneously evaluates the correlation between one variable and the 
rest of the variables in the model. It then gives you a single score 
for each predictor in the model.

Dropping a variable from a regression due to high multicollinearity causes
biais in two ways:

a) Ommitted Variable Biais

"In statistics, omitted-variable bias (OVB) occurs when a model is created 
which incorrectly leaves out one or more important factors. The "bias" is 
created when the model compensates for the missing factor by over- or 
underestimating the effect of one of the other factors.

More specifically, OVB is the bias that appears in the estimates of parameters 
in a regression analysis, when the assumed specification is incorrect in that 
it omits an independent variable that is correlated with both the dependent 
variable and one or more included independent variables."

From: https://en.wikipedia.org/wiki/Omitted-variable_bias

b) Although it seems to fix the assumption of "no multicollinearity", it violates
another assumption of "independent errors", namely that the "error term is
independently distributed and not correlated... i.e. no correlation between
observations of the Dependent Variable."

Because we know the ommitted variable is significantly correlated with Y,
and is now in the error term. So the error term has a known correlation with Y.

This may be two different ways to think of the same thing. The bottom line:
DON'T DROP VARIABLES DUE TO MULTICOLLINEARITY, UNLESS IT IS AN IDENTICAL VARIABLE
DUE TO A KNOWN CODING MISTAKE.

Ven diagrams, and explanation.

CONCEPTUAL REVIEW: (from slide 22 of CH 13 slides) What to do:
	1. Nothing
	2. Incorporate additional info (more data, principal component factors, etc.
	3. Fancy Bayesian techniques, ridge regression, etc.
	4. Drop the offending variable (DO NOT DO THIS!!! WHY?)
		*Sounds like possible exam question.
Then on to autocorrelation.
*/

********************************************************************************
* SERIAL/AUTOCORRELATION DISCUSSION
********************************************************************************

/*
Time series data has one single unit of observation (person, state, etc.)
at various time points. The example in this lab uses traffic fatalities
and other associated data for one state at 108 month-time-points.

Panel data is similar except that it has multiple observations at each time point,
for example, in my Tunisia dissertation data, there is protest and violence data
for 268 districts during 74 days of revolution.

Serial autocorrelation causes violation of two OLS assumptions:
-uncorrelated errors (because the error at the next time period 
	is correlated to the prior)
and
-homoskedasticity (because we then have different error variances over time.

Central problem:(efficiency)
–  the sampling variance of OLS coefficients may be too small 
	when estimated using LS formulas (t-ratios would be too large) 
	when errors are positively correlated
–  the OLS coefficients remain unbiased

*POSSIBLE EXAM TYPE QUESTION

OLS is a subset of Generalized Least Squares. Under GLS, if we have time series
data and know that it is serial/auto-correlated, we could use other GLS models
that would account for this in the data.
*/

********************************************************************************
* TSSET
********************************************************************************

/*A NOTE ON TSSET: Most time series commands in Stata assume that Stata knows
that your data consist of time series. But Stata usually does not know or recognize
that. You have to give Stata an understanding of the time series nature of your
data with the command tsset. This command is simply a way for you to tell Stata
which variable in your data set represents time; tsset then sorts and indexes the
data appropriately for use with the time series commands. See help tsset for much, much
more information.*/

tsset t

********************************************************************************
* SOME SIMPLE MODELS AND VISUALIZATION
********************************************************************************

*First, let's visualize Y over time

twoway (scatter prcfat t) (lfit prcfat t) (connect prcfat t)
graph export yt.png, replace


regress prcfat wkends unem spdlaw beltlaw
cap drop r
predict r, residual
twoway (scatter r t) (lfit r t) (connect r t)
graph export rt.png, replace

/*NOTE how closely related the neighboring residuals are, with peaks and valleys
NOTE also the slight, but distinct downward trend in our fitted line over time
Residuals are decreasing, because there is a time trend in this data
that we did not account for.*/


regress prcfat wkends unem spdlaw beltlaw t ///
feb mar apr may jun jul aug sep oct nov dec
cap drop r
predict r, residual
twoway (scatter r t) (lfit r t) (connect r t)
graph export rt_full.png, replace

/*Now, in the model above, we included the t variable for time.
We also included dummies for all months except January (omitted variable).
This has the effect of removing the time-trend (notice zero slope of lfit).
And, it seems to shrink the peaks and valleys, but does not remove our
autocorrelation problem.

*NOW LOOK AT REGRESSION RESULTS

Besides our traffic laws we include the # of weekends in the month, the unemployment rate
(we can view unem as a measure of economic activity. As economic activity increases
– unem decreases – we expect more driving, and therefore more accidents.)
we also include a time trend variable, t, and monthly dummy variables to capture
any seasonality in traffic fatalities.

We see some evidence of seasonality with more fatalities during the summer months.
Higher speed limits are estimated to increase the percent of fatal accidents,
by .067 percentage points. This is a statistically significant effect.
The new seat belt law is estimated to decrease the percent of fatal accidents by
about .03, but the two-sided p-value is about .21.
Interestingly, increased economic activity also increases the percent of
fatal accidents. This may be because more commercial trucks are on the roads,
and these probably increase the chance that an accident results in a fatality. 
*/

********************************************************************************
* DURBIN-WATSON TEST
********************************************************************************

*So, how about testing for AR(1) autocorrelation?

estat dwatson

/*From the Stata Help on "estat dwatson".

The null hypothesis of the test is that there is no first-order autocorrelation.
The Durbin–Watson d statistic can take on values between 0 and 4 and under the 
null d is equal to 2. Values of d less than 2 suggest positive autocorrelation 
(ρ > 0), whereas values of d greater than 2 suggest negative autocorrelation 
(ρ < 0). Calculating the exact distribution of the d statistic is difficult, 
but empirical upper and lower bounds have been established based on the sample 
size and the number of regressors. Extended tables for the d statistic have 
been published by Savin and White (1977). For example, suppose you have a model 
with 30 observations and three regressors (including the constant term). For a 
test of the null hypothesis of no autocorrelation versus the alternative of 
positive autocorrelation, the lower bound of the d statistic is 1.284, and t
he upper bound is 1.567 at the 5% significance level. You would reject the 
null if d < 1.284, and you would fail to reject if d > 1.567. A value falling 
within the range (1.284, 1.567) leads to no conclusion about whether or not 
to reject the null hypothesis.

To interpret, we need to check the durbin-watson table of d distribution
using a table of critical upper and lower bounds, we see that we are in 
the zone of indecision.

SO LET'S LOOK AT THE PDF I INCLUDED.

The original Durbin-Watson test statistic is rather complicated, but commonly
used, so it is worth understanding. Instead, we can also run the alternative
Durbin test statistic.*/

********************************************************************************
* ALTERNATIVE DURBIN-WATSON TEST
********************************************************************************

estat durbinalt

*We see here, we reject the null hypothesis, so we have evidence of 
*serial autocorrelation.

********************************************************************************
* HOW ABOUT A SIMPLE LAG VARIABLE?
********************************************************************************

/*
The first and most common technique for dealing with autocorrelation is to
simply use a lagged dependent variable in an OLS regression.

*Advantages
This has the advantage of simplicity, and testability. You get a simple
coefficient and p-value telling you if the prior lagged observation is a
significant predictor of y.

*When to use:
If we wanted to evaluate a mean shift (dummy variable only model), 
calculating rho will not be a good choice. 
Then we would want to use the lagged dependent variable

Also, where we want to test the effect of inertia, 
it is probably better to use the lag.

*Words of caution:
This correction should be based on a theoretic belief for the specification
May cause more problems than it solves
Also costs a degree of freedom (lost observation)
There are several advanced techniques for dealing with this as well
*/

sort t
gen lagy = L.prcfat
*If you wanted a lag-2, you'd write "gen lag2y = L2.prcfat"

reg prcfat lagy wkends unem spdlaw beltlaw t ///
feb mar apr may jun jul aug sep oct nov dec

estat dwatson
estat durbinalt

cap drop r
predict r, residual
twoway (scatter r t) (lfit r t) (connect r t)
graph export rt_lag1.png, replace

*NOTE: You could also model other types of lag variables to deal with different
	*processes. For example, the average of the last 5 time periods, etc.

********************************************************************************
* PRAIS-WINSTON /COCHRANE ORCUTT CORRECTIONS
	*Seems to be the preferred method taught by Professor Paxton
********************************************************************************

* Prais/Winston

/*prais uses the generalized least-squares method to estimate the parameters in a
linear regression model in which the errors are serially correlated. Specifically,
the errors are assumed to follow a first-order autoregressive process.*/

*It is best to correct for AR(1) and see what it does to the results.

prais prcfat wkends unem spdlaw beltlaw t ///
feb mar apr may jun jul aug sep oct nov dec
cap drop r
predict r, residual
twoway (scatter r t) (lfit r t) (connect r t)
graph export rt_prais.png, replace

/* There are no drastic changes. Both policy variable coefficients get closer to zero,
and the standard errors are bigger than the incorrect OLS standard errors
So the basic conclusion is the same: the increase in the speed limit appeared to
increase prcfat, but the seat belt law, while it is estimated to decrease
prcfat, does not have a statistically significant effect. 

NOTE: rho is the "autocorrelation parameter". It can be calculated a number of
different ways, but by default from the residuals. Stata has options for the
other calculation types if you have a preferences.
*/

* Cochrane Orcutt

/* Here is the alternative estimator. Note the extreme similarity in the results.
This is called the Cochrane-Orcutt transformation
This is instead of the standard Prais-Winsten transformation.
*/ 

prais prcfat wkends unem spdlaw beltlaw t ///
feb mar apr may jun jul aug sep oct nov dec, corc
cap drop r
predict r, residual
twoway (scatter r t) (lfit r t) (connect r t)
graph export rt_cochrane.png, replace
/*
Aside from a slightly different way of estimating "rho", the main difference
is that the Cochrane Orcutt method (unlike the Prais-Winston method), drops
the first observation. The Prais-Winston generates values for the lost observation.
By "lost observation", we are referring to the first one, since it has no prior
or lagged observations before it.
*/

********************************************************************************
* ARIMA REGRESSION
	*A more complicated approach taught by Professor Powers
********************************************************************************

/* The ARIMA model allows us to test the hypothesis of autocorrelation and 
remove it from the data. It also allows us to specify more complicated
auto-correlation, like first and second order in the example below.

In Small N, calculating rho tends to be more accurate 
ARIMA is one of the best options, however, it is very complicated!
When dealing with time, the number of time periods and the spacing 
of the observations is VERY IMPORTANT!
When using estimates of rho, a good rule of thumb is to make sure you 
have 25-30 time points at a minimum. More if the observations are too 
close for the process you are observing!
*/

arima prcfat wkends unem spdlaw beltlaw t ///
feb mar apr may jun jul aug sep oct nov dec, ar(1/2) nolog
cap drop r
predict r, residual
twoway (scatter r t) (lfit r t) (connect r t)
graph export rt_arima.png, replace

/*In this case, we tried both ar1 and ar2 processes. ar2 is not significant.
But the ar1 coefficient is significant. Unsurprisingly, it is quite close to
the "rho" value estimated by the Prais-Winston model. Though the calculations
are different, both measure the effect of a serial correlation from the
prior observation in time.

NOTE: sigma is the "residual standard error"
*/

log close
