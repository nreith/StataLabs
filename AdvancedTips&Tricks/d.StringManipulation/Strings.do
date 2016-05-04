********************************************************************************
* DO File - Working with Strings in Stata
********************************************************************************

****************
*Setup
****************

	cap cd "~/Dropbox/Git/repositories/StataLabs/AdvancedTips&Tricks/d.StringManipulation/"
	set more off, permanently
	cap log close
	log using strings.smcl, replace

**********
* 1 Importing as strings
**********
/*First, if you are importing a tab or csv file, you may want to specify all strings
	so you can avoid losing text information if Stata converts them directly
	into numeric*/
	
import delimited using stringspractice.csv, clear stringcols(_all)

desc // NOTE: It tells you the storage type is string for both

**********
* 2 Converting to string or numeric
**********

*We now want to make year into a numeric variable, since it has all numbers

*we have the option of generating a new variable

destring year, gen(year2)

*Or, just replacing the original

destring year, replace

*But, we got an error message saying that year contains nonnumeric characters

tab year

*In this case, it was pretty simple... we see one observation where the year
	* was 20l3 (with the letter L), instead of 2013. So we correct this.
	
replace year=2013 if year==20l3

*Error message. Oops... year is still a string, so we work with quotes

replace year="2013" if year=="20l3"

*Now, let's finish converting.

destring year, replace

desc // year is now int (which is one type of numeric storage type)

*If we wanted to convert a numeric to a string, we could do the opposite

tostring year, gen(yearstring)

desc
drop yearstring

**********
* 3 Encoding and Decoding
**********

/*Above we faced the problem of trying to make a numeric out of a variable that
	contained a string character. What if we want to create a numeric variable
	out of a string? For example, we don't care about the names of wingos,
	we just want a unique number for each?*/
	
*One way is to manually create a group id variable

bysort wingo: egen wingoid = group(wingo)

*Error... we can't use "by" with egen = group

sort wingo year // Let's sort just to make sure the numbers go in an order we like

egen wingoid = group(wingo)

list wingo wingoid year in 1/50

*The problem with this approach is that we lost the name labels for our new variable
	*We could reacreate them, but it's an extra step and a hassle.
	
*Instead, let's encode wingo

drop wingoid
encode wingo, gen(wingoid)

tab wingoid //Now we see that wingoid has text
tab wingoid, nolab //But actually it has id numbers underneath as the real data
					//with text as the labels
					
*We could also do the reverse of encode using "decode", which would remove
	//the numbers and leave a text variable
	
decode wingoid, gen(wingotext)
tab wingotext
tab wingotext, nolab
desc
drop wingoid wingotext

**********
* 4 Finding and dealing with duplicates
**********

help duplicates // first, check out some of the built in stuff for Stata

desc
*Checking for duplicates
duplicates report //Our report shows that we have 1188 unique obs
					//and 462 that are repeated 3 times, and 318 repeated 6 times.

*We could also check for duplicates by a specific combination of variables
duplicates report wingo // for example, if we ignore year, and only look at
						// wingo, we have many more duplicates
						
duplicates example // this shows us an example of each duplicate group
					// so if you have multiple duplicates, it shows only one
					
duplicates list // this lists all duplicated observations

duplicates tag, gen(dups) // this creates a variable that tags duplicates

tab dups // originals are given a value of 0, and 1s are duplicate observations

*We could then use "duplicates drop" to drop duplicate observations

*But, I prefer to be a bit more careful, especially if we have multiple duplicates
	// because we might accidentally drop some originals

*So, let's create an id variable within each duplicate group that gives us 0
	// for the original, and numbers the rest within the gorup

bysort wingo year: gen dupsid = cond(_N==1,0,_n)
tab dupsid

*Now, instead of just giving us a count of how many dups each obs has
	// as in "duplicates tag", we actually put them in order
	// all those with 0 are originals with no duplicates
	// all those with 1 are the first observation of a set of duplicates
	// and those greater than 1 are duplicates we can remove
*But, let's check

list in 1/10 // Here we see ABANTU is a duplicate for 2003... it was given
			// 2 in dups because it has 2 extra... but in dupsid, we number them

*Let's inspect all duplicates

preserve	// saves the current dataset
keep if dupsid>0
list // make your Stata window very wide for this part, to fit everything
restore // restores the preserved dataset
			
*So, now we can remove duplicates with confidence

drop if dupsid>1

*Just to check, let's rerun it
drop dups
drop dupsid

duplicates tag, gen(dups)
tab dups // No duplicates
bysort wingo year: gen dupsid = cond(_N==1,0,_n)
tab dupsid // Same

drop dups dupsid

**********
* 4 Merging duplicate observations
**********

/*Here, I won't provide much sample code or go into much detail because this
will differ for each dataset.

The main point to emphasize here is that... sometimes you have observations that
are duplicates on the name and year variables, but contain different information
that you want to capture.

Here are some examples:

*Replace numeric original variables with following observations' data

	ds, has(type numeric)
	foreach var of varlist A-Z { 
	replace `var'=`var'[_n+1] if `var'!=1 & dups==1
	}

*Replace numeric original variables with mean values

	ds, has(type numeric)
	foreach var of varlist A-Z {
	by wingo year: egen `var'mean = mean(`var')
	replace `var'=`var'mean if dups==1
	}

*Replacing blank string originals with following obs, 
	*or combining string variables to preserve info

	ds, has(type string)
	foreach var of varlist A-Z {
	replace `var'=`var'[_n+1] if `var'==""
	replace `var'=`var'+" & "+`var'[_n+1] if dups==1
	}

After doing some of the above to preserve duplicates' information in the first
original observation, you can then delete/drop duplicates as we did above.
*/

**********
* 5 Fuzzy String Matching
**********

/*Sometimes, we have approximate matches (or fuzzy matches) where we think things
should actually be matches and/or duplicates, but they are slightly different
often due to typos or slight name changes*/

*First, install strgroup package for Stata
	/*	 strgroup matches similar strings together. This can be useful when merging data that
    contain typos. For example, "widgets" will not merge with "widgetts" because the
    strings are not identical.  strgroup provides a way to match strings in an objective
    and automated manner. It employs the following algorithm:

        1. Calculate the Levenshtein edit distance between all pairwise combinations of
              strings in varname.

        2. Normalize the edit distance as specified by normalize([shorter|longer|none]).
              The default is to divide the edit distance by the length of the shorter
              string.

        3. Match a string pair if their normalized edit distance is less than or equal
              to the user-specified threshold.

        4. If string A is matched to string B and string B is matched to string C, then
              match A to C.

        5. Assign each group of matches a unique number and store this result in
              newvarname.

    For example, the Levenshtein edit distance between "widgets" and "widgetts" is 1.
    The lengths of these two strings are 7 and 8, respectively. Assuming
    normalize(shorter), they are matched by strgroup if 1/7 <= threshold.

    strgroup is case sensitive.
	
	NOTE: There are other ways to match strings, which you can research and
	that are possible in Stata or R, but Levenshtein distance works pretty well.
	*/
	
net install strgroup

*Here's some sample code

capture drop lev duplevid id // drop these in case you already created them
*stgroup allows you to set the threshold. Start with .1 (10% difference 
	//among matches, and use a bigger threshold with each iteration.
strgroup wingo, gen(lev) threshold(.1) force 
tab lev // We see lev created group id numbers by suggested matches
*So, let's create an ordered duplicates id
bysort lev: gen duplevid = cond(_N==1,0,_n)
*And place our variables in order
order lev duplevid, first
desc
list in 1/15
*Now, we can visually inspect our data... Go into databrowser and check it out.
preserve
bysort wingo: gen dups = cond(_N==1,0,_n)
drop if dups>1 //Removing duplicates to look only at fuzzy matches.
keep if duplev>0
sort wingo duplevid
drop dups
export delimited duplev10.csv, replace
restore
*We can check out the .csv file to see.

*NOW TO MATCH AND FIX THEM!
	*Once you have manually verified which ones match, you can combine them
		// by giving them all a common new name.
		
gen newname = wingo

/* For example, in our data, we found the following match:

duplevid	lev		wingo												year
10			3		African Network for Support to Women Entrepreneurs	2013
10			2		African Network of Support to Women Entrepeneurs	2003

So we give them a common newname:
*/

replace newname = "African Network for Support to Women Entrepreneurs" if ///
		wingo=="African Network of Support to Women Entrepeneurs"
		
*Repeat this process for all fuzzy matched observations that you manually verified

*Then continue to match at a bigger and bigger threshold (.2, .3, .4) until
	// you are hardly finding any matches.

**********
* 6 String Functions
**********

*Sometimes you may want to do batch processing and string replace functions.
	// Of course, you can always use the terminal/command line in Windows/Mac/Linux
	// to replace things with REGEX (regular expressions) and a variety of command
	// line tools for working with text. Python is also really good at this.
	// However, there are some built in tools that are pretty useful in Stata.

help string functions // gives lots of Stata's internal string function commands

*Trimming strings

replace newname = trim(newname) // removes trailing or leading spaces

*Parts of strings

list wingo if strpos(wingo,"ASTRA") // Finds parts of string

*Replace one substring with another (notice misspelled first substring, missing r)
replace wingo = subinstr(wingo, "Entrepeneurs", "Entrepreneurs", .)

*Get the prefix of a variable
gen prefix = substr(wingo, 1, 5) // position 1, first 5 characters

*Get suffix of a variable
gen suffix = substr(wingo, -5, .) // grabs all characters up to postion 5 from last

********************************************************************************

*ALL FOR NOW!! HAVE FUN!!

log close
