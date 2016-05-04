
*************************************************
*** Do File - Simple and Multiple Regression
*** with Measurement and Variable Creation
*************************************************

* Getting Started:
*************************************************

clear all
cap cd "~/Dropbox/Git/repositories/StataLabs/2.SimpleMultipleRegression/"
set more off, permanently
cap log close
log using simplemultiple.smcl, replace

use "simplemultiplereg.dta", clear

* Part One: Abortion Variables & Simple Regression
*************************************************

* #1 Looking for Abortion Variables

lookfor ab

* #2 Getting more info on the GSS website

/*

This lists all variables that have "ab" in the variable name, label, or values.
Too many, but it helps us narrow it down from the full list.
These below are the ones that relate to abortion:

abdefect        byte   %8.0g       LABD       strong chance of serious defect
abnomore        byte   %8.0g       LABD       married--wants no more children
abhlth          byte   %8.0g       LABD       womans health seriously endangered
abpoor          byte   %8.0g       LABD       low income--cant afford more children
abrape          byte   %8.0g       LABD       pregnant as result of rape
absingle        byte   %8.0g       LABD       not married
abany           byte   %8.0g       LABD       abortion if woman wants for any reason

But, we can also find this one and should investigate if it is related.

geneabrt        byte   %8.0g       geneabrt   abort defective fetus

So, we go to the website for the GSS, http://www3.norc.org/GSS+Website/

We could download the entire codebook, or just browse variables.

We find this infor for geneabrt:

Literal Question
1567. Suppose a test shows the baby has a serious genetic defect. 
Would you (yourself want to/ want your partner to) have an abortion 
if a test shows the baby has a serious genetic defect?

Values 	Categories 	N 	NW
1 	HAVE ABORTION 	1589 	1540 	
	 38.2%
2 	NO ABORTION 	2424 	2468 	
	 61.3%
7 	REFUSED 	20 	18 	
	 0.4%
0 	NAP 	46325 	46337
8 	DONT KNOW 	526 	521
9 	NA 	136 	137

For abdefect, we find the following:

 Variable abdefect : STRONG CHANCE OF SERIOUS DEFECT
PreQuestion Text
206. Please tell me whether or not you think it should be possible for a 
pregnant woman to obtain a legal abortion if. . .READ EACH STATEMENT, 
AND CIRCLE ONE CODE FOR EACH.

Values 	Categories 	N 	NW
1 	YES 	28636 	28509 	
	 80.2%
2 	NO 	6850 	7026 	
	 19.8%
0 	NAP 	14133 	14118
8 	DK 	1251 	1220
9 	NA 	150 	147
Summary Statistics
Valid cases 	35486
Missing cases 	15534
This variable is numeric 

And, finally for abnomore, we find:

 Variable abnomore : MARRIED--WANTS NO MORE CHILDREN
PreQuestion Text
206. Please tell me whether or not you think it should be possible 
for a pregnant woman to obtain a legal abortion if. . .
Literal Question
B. If she is married and does not want any more children?
Values 	Categories 	N 	NW
1 	YES 	15502 	15338 	
	 43.3%
2 	NO 	19827 	20064 	
	 56.7%
0 	NAP 	14133 	14118
8 	DK 	1403 	1350
9 	NA 	155 	150
Summary Statistics
Valid cases 	35329
Missing cases 	15691
This variable is numeric 

Based on this, we probably conclude that we should not include geneabrt with the ab variables,
since it was asked with a different series of questions, is somewhat repetititious of one of 
the other variables about birth defects, and also because it relates more to a personal view
of abortion, rather than a political, religious or philosophical outlook. Clearly, some people
may answer one way for themselves and their partners, but another way for the rights of others.

*/

* #3 Recoding Abortion Variables

* Just to be sure, let's check their current coding:

tab abdefect
tab abdefect, nolab

tab abnomore
tab abnomore, nolab

tab abhlth
tab abhlth, nolab

tab abpoor
tab abpoor, nolab

tab abrape
tab abrape, nolab

tab absingle
tab absingle, nolab

tab abany
tab abany, nolab

* Ok, so we confirmed that all of them are 1=yes and 2=no, so we recode

recode abdefect 2=0
recode abnomore 2=0
recode abhlth 2=0
recode abpoor 2=0
recode abrape 2=0
recode absingle 2=0
recode abany 2=0

tab abdefect

* We notice, the labels are a bit funky, so let's fix that if we wish.

label define abl 0 "no" 1 "yes"

label values abdefect abl

tab abdefect

* Yay, it worked, so we can do the others too

label values abnomore abl
label values abhlth abl
label values abpoor abl
label values abrape abl
label values absingle abl
label values abany abl

* #4: Adding the abortion variables to combine them.

* Ok, now to combine them, first with egen, then with gen

egen abcount1 = rowtotal (abdefect abnomore abhlth abpoor abrape absingle abany)
gen abcount2 = abdefect + abnomore + abhlth + abpoor + abrape + absingle + abany

tab abcount1, m
tab abcount2, m

/* To answer the question on the difference between the two, we notice that abcount1 (created with egen)
has no missing values, whereas abcount2 (created with gen) has more than 2,000 of them. We may surmise
that the egen command automatically codes missing as zero, and thus those who have all missing, get a value
of zero, instead of missing. This is a problem, because it could skew our data. Missing is omitted from
a normal regression, but zero is included.

So we type "help egen" and we find that there is a "missing" option, also abbreviated as "m".
*/

egen abcount3 = rowtotal (abdefect abnomore abhlth abpoor abrape absingle abany), m

tab abcount3, m

/* In comparison, we notice that this variable does have some missing, but not as many as abcount2.

I'll save you the time of further investigation and give a little brief summary of some Stata quirks
regarding missing values here:

1) With the gen command, Stata treats missing as absolute. If the value is missing for one of the variables
being combined, it drops out for that respondent across all questions.

2) With the egen command, by default, the missing is considered like a zero. It just adds up the values 
across the row and you get whatever that value is... all missing, add up to zero.

3) However, with egen, using the missing option, Stata only counts as missing those observations (respondents)
for whom all answers are missing. If they just skipped one question, they get a zero for that one.

This third option is preferable in most circumstances, but you need to check your data after doing 
such transformations to be sure, and choose what is appropriate.

Lastly, a few quirks on missing in Stata:

a) Many datasets tend to treat missing as a large number, or negative number. You may find 999 or -999 in your
data. In some cases just -1 or -2. In these cases refer to the codebook and recode all of these as . for missing.

b) Stata does allow you to differentiate among various types of missing values. This may be useful depending
on what you want to do. For example, in research with Pam, we had decided we wanted to impute certain types
of missing under certain conditions. If an observation appeared in the data book, but the actual members were
missing for example, as opposed to obersvations that never appeard in the book. In this case, you can recode
various types of missing as .a, .b, .c, etc.

c) Finally, though a missing does not have a value, Stata treats missing internally as a very very large value
close to infinity. A missing value will always be larger than the largest value in your variable. Therefore,
when recoding variables, you have to be careful when using > greater than. For example,

replace var = 1 if var>1 		would also recode missing as 1.
replace var = 1 if var>1 & var<. 	would recode all values greater than 1 as 1, excluding missing

*/

* In conclusion, we probably want to use abcount3 above, as this one makes the best use of missing values.

* #5 Examining the distribution of our abcount variable

hist abcount3

/* We can see that the abcount variable is not very normally distributed. There is clustering at 7,
where many people feel abortion should be allowed under any or all of these circumstances.
Otherwise, it looks pretty normal, with a peak in the middle, and lower tails. In other words,
most people fall along a more or less normal curve, but a large number of people are strong
advocates of abortion rights. */

sum abcount3, d

/* Looking at is summary stats, we find that it has very little skewness, close to zero, but some
kurtosis, at 1.5, since this value should be close to 3.
The visual inspection above is also useful. */

* #6 Creating a scatterplot

lookfor educ

* We find that educ is the education variable, so we scatter it like this:

twoway (scatter abcount3 educ) (lfit abcount3 educ), ///
ytitle("abcount3") title("Abortion Count vs. Education")

/* It seems there is a clearly positive correlation between higher levels of education
and pro-abortion rights attitudes */

* #7 Regressing abcount variable on education

reg abcount3 educ

/*
Interpreting results:

Education seems to be a statistically significant predictor 
of abortion attitudes at all conventional alpha levels.

It is also substantively significant. For each extra year of education,
there is a predicted .2 unit increase on the Abortion Count Scale, since the
coefficient is .20. This means, each 5 years of education predicts a 1 point
change on this scale. The confidence interval indicates that the number of years
to increase the abortion scale by 1 point ranges between 4.3 and 5.7 approximately
with a 95% confidence level.

Further, the constant indicates that a person with zero years of education
is still predicted to have an abortion scale score of 1.24, meaning that they
do still condone abortion for at least one of the 7 categories.

We can see our model sum of squares, df, and mean squared error,
as well as our residual sum of squares, remaining residual df, and residual mean squared error
all at the top.

This is all mainly important for calculating our R-squared, which is .06, suggesting our model
of education explains 6% of the variation in Y (abcount3).

In this case, an Adjusted R-Squared is the same. But a reminder, that this is calculated with an equation
that penalizes us for inclusion of too many explanatory variables. It is a check on the tendency to want
to include everything and the kitchen sink.

*/

* Part Two: Multiple Regression
*************************************************

* #8: Recoding variables

* First, religion

lookfor relig
* relig is our religion variable
tab relig
tab relig, nolab
*Here's a shortcut for how to do this:
tab relig, gen(religvar)
ren religvar2 catholic
label var catholic "0=other, 1=catholic"
* We could rename and label the other religions too, 
* but won't bother here as it's not needed for this assignment

* Second, gender

lookfor gender
lookfor sex
* sex is our gender variable
tab sex
tab sex, nolab
recode sex 1=0 2=1
label drop sex
label var sex "0=male, 1=female"

* Third, race

lookfor race
* race is our race variable
tab race
tab race, nolab
tab race, gen(racevar)
ren racevar2 black
ren racevar3 otherrace
ren racevar1 white
label var black "0=other, 1=black"
label var white "0=other, 1=white"
label var other "0=b/w, 1=other"

* #9 Recoding Income and Family Income

* Income

tab rincom06
tab rincom06, nolab
gen income_ind = rincom06
recode income_ind 1=500 2=2000 3=3500 4=4500 5=5500 6=6500 ///
7=7500 8=9000 9=11250 10=13750 11=16250 12=18750 13=21250 ///
14=23750 15=27500 16=32500 17=37500 18=45000 19=55000 20=67500 ///
21=82500 22=100000 23=120000 24=140000 25=175000

tab income_ind

* Family Income

tab income06
tab income06, nolab
gen income_fam = income06
recode income_fam 1=500 2=2000 3=3500 4=4500 5=5500 6=6500 ///
7=7500 8=9000 9=11250 10=13750 11=16250 12=18750 13=21250 ///
14=23750 15=27500 16=32500 17=37500 18=45000 19=55000 20=67500 ///
21=82500 22=100000 23=120000 24=140000 25=175000

* #11 Multiple Regression with Individual Income

reg abcount3 educ income_ind catholic sex black otherrace

/* Note: If you get an error message about omitting catholic because of collinearity,
 check the name of your otherrace variable. You might have included "other", which is
a catch-all variable for "other religions". This and catholic include some of the same
people. */

/* RESULTS: We notice that our model explains only about 5.6% of the variation in Y,
so it has gone down since our simple regression with education alone.
We find that education is still highly significant, though its effect size has gone down.
Income, and Catholic are also significant, but nothing else really.

The change in effect size for educ and our R-squared indicates that there may be some overlap
in explanatory power (or correlation) among some of our X variables. Some of these other variables
may be correlated to some extent with socio-economic class, with which education is closely related.
Therefore, when including income for example, we find that education has a smaller effect size.

*/

* #12: Multiple Regression: with Family Income

reg abcount3 educ income_fam catholic sex black otherrace

/*RESULTS:
Our R-Squared went up to 6.1%, so by including family income we explain an extra .5% of the variation
in our abcount variable.
Education, and catholic remain significant, and the education effect size has actually gone up slightly.
Family income is also as significant as income, but has an effect size twice as large (though it is still
tiny).
Finally, with regards to females (sex=1), we see that the previously insignificant effect is now significant
and has a strong negative effect-size.
Since the only change was the switch of family income for individual income, we surmise that women's income
must differ in these two variables. Some quick tabs will confirm. */

sum income_ind if sex==1, d
sum income_fam if sex==1, d

/* As we confirm, the mean income is 34,400 for individual women, and has an SD of 30,200.
When reporting family income, the mean is 53,800 and the SD is 45,000.
This may be because some women choose to work in the home, and are not compensated for this.
*/

* #12 Looking at diagnostics of explanatory variables

sum educ, d
hist educ

* Low skewness near zero, and reasonable kurtosis, though our histogram shows some clustering

sum income_ind, d
hist income_ind

* This one has a lot of skew, and quite a bit of kurtosis

sum income_fam, d
hist income_fam

* Low kurtosis, but some moderate skew

sum catholic, d
sum sex, d
sum black, d
sum otherrace, d

/* These are all dummy variables, so we care less how they are distributed,
as long as they have sufficient observations in each category.
*/

/* In sum, after looking over our explanatory variables, education is reasonably distributed
and we don't want to do much with dummy variables. But either of our income variables might be game
for a transformation. In this case, the typical solution is to log income. This is because income normally
has a large positive skew. In other words, most people make very little, and a few people make tons and tons,
and this distorts the distribution. */

* #6 Logging Individual Income and Regressing

gen lnincome_ind = ln(income_ind)

reg abcount3 educ lnincome_ind

/* Logged income and education are both significant with serious effect sizes.
Together they account for about 5.5% of the variation in Y. */

* #7 Logging Family Income and Regressing

gen lnincome_fam = ln(income_fam)

reg abcount3 educ lnincome_fam

/* When we regress family income and education on abcount however, we find something different.
While the R-Squared remains stable, education's effect size increases and logged family income
is not significant at all.

Why?

1) We might think that your own socio-economic status has more to do with your attitudes than
the socio-economic status of your family. In other words, after controlling for education,
personal income is more important at predicting abortion attitudes than family income.
2) We might also think that your family's income is more highly correlated with education
than individual income. If your family is wealthy, you are likely to go to college.
It does go in the other direction too since having a college degree predicts higher earning power,
but most likely not as strong in that direction, since we all know the earning power of a college
degree is lower in recent decades.
3) All of this is unfortunate since individual income is not as good of a measure for women.
But, it works better for our outcome, so we must use it.

*/

* Final Model

*********************************************

* #8 Normal Model

reg abcount3 educ lnincome_ind catholic sex black otherrace

reg abcount3 educ lnincome_ind catholic sex black otherrace z2

* #9 My Variable

tab zodiac, gen(z)

*z2 = Taurus

hist z2
sum z2, d

* It's a dummy variable, so not too many worries about distribution.

reg abcount3 educ lnincome_ind catholic sex black otherrace z2

* #10 Interpretation

/* R-squared went up a tad, but Taurs had no effect! */


log close

