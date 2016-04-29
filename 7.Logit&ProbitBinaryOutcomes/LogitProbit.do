*Lab Assignment 7 DO File

clear all

cd "D:\Dropbox\UT\TAing\Sociology 385L-SSC 385\Labs\Lab7"

log using Lab7LOG, smcl replace

use "binlfp2.dta"

describe

*#1

logit lfp k5 k618 age wc hc lwg inc

estimates store logit

probit lfp k5 k618 age wc hc lwg inc

estimates store probit

estimates table logit probit, b(%9.3f) t label varwidth(30)

*Recall that the logit is approximately 1.6 times the probit
*Let's test this by dividing a few of the logit coefficients by the probit coefficients

disp -1.462913/-.8747111
disp -.0645707/-.0385945
disp .6046931/.3656287

*They all come out to some ratio between 1.6 and 1.7, so not exact, but pretty close.

*Now let's think about interpeting these results in different ways.

	/*First, we note the direction of the coefficients in each model and that these do tell
	us something important, even if the magnitude is more complicated.
	
	Having kids of any age seems to decrease the likelihood of being in the workforce, as
	does age and family income. But the log of wife's estimated wages and college degrees
	for both the wife and husband increase the probability of being in the work force for
	the wife.*/

*#2 Now let's get the predicted probabilities

logit lfp k5 k618 age wc hc lwg inc

predict prlogit

sum prlogit

hist prlogit

*Look at the datatable for prlogit, our newly created variable.
*Notice that there is a predicted probability given for each woman in our dataset.

*#3.1 prvalue

*Let's use the prvalue command to customize the probabilities

net from http://www.indiana.edu/~jslsoc/stata/

*click your way through to install spost9_ado in Stata12, or spost13_ado in Stata13
*If necessary force reinstallation to make sure you have the latest updates

logit lfp k5 k618 age wc hc lwg inc

prvalue	

*So, these are the predicted probabilities of working outside the home when our x variables
*are all set at the mean.

*Play around with it and try some other values:

prvalue , x(age=35 k5=2 wc=0 hc=0 inc=15) rest(mean)

*Do some more

*#3.2 prtab

prtab k5, rest(mean)

*try some others, or combinations

prtab k5 k618 wc, rest(mean)

*Neato!

*#3.2 prchange

prchange k5, help

prchange k5 wc, help

*#4 Now let's talk about an odds ratio interpretation

listcoef, help

*First, pay attention to the coefficient sign, and then look at the e^b
*which is the factor change in odds for a unit increase in x

*For example, each additional 1% incease in wages leads to a e^b/100 factor change in Y

disp 1.8307/100

*so a 1% increase in income for the household increases the odds of a woman participating in 
*the labor force by a factor of .018 (holding all other factors constant)

*#5 Odds ratio percentage change

listcoef, percent help

*This now is a bit more intuitive, but still refers to odds.

*For example, having one additional child age 5 or less decreases the odds
*a woman's participation in the labor force by 76.8% (holding all else constant)
*Bear in mind, this may be a bit or small change depending on the overall odds.
*i.e. it could be a big change for the first child, but less for additional children, though
*the cumulative odds would still be lower.




