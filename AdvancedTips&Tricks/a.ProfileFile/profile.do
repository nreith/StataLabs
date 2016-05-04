********************************************************************************
* DO File - Stata Profile Files
********************************************************************************

/*
CAUTION: Do not use a Stata profile.do file like this on a public
computer or server, where you might change settings for other users.

See here: http://www.stata.com/support/faqs/programming/profile-do-file/

Google "Stata profile.do" for more

In this profile file, you can tell Stata to do all the things you normally
want Stata to do each time you open, instead of having to repeat them
at the top of your .do files.

Then, you just place this file in a place Stata can find it, like within the
/ado/personal folder inside of Stata's program location.

On Windows, this might be:

c:\Programs\Stata\ado\personal

On Mac, it might be:

~/ado/personal
*/

*Some things you can do with it, include:
********************************************************************************

*Telling Stata to go ahead and automatically update, so you don't have to get
*update nags

update all

/*Setting a main working directory, if for example all your work is in sub-folders
If each computer you work on sets the main working directory, such as Dropbox
then your code will work on any of your computers, as long as the directory structure
underneath is identical.*/

cd "C:\DATA\"

*Turning off the nagging scroll breaks permanently

set more off, permanently


/*Setting a preferred scheme and font (look) for charts and graphs
For example, the one below uses a black-and-white look with Times New Roman
which tends to match well with the look of most publications. You can tweak
it how you like.*/

set scheme s2mono, permanently
graph set window fontface "Times New Roman"

/*You could also set global folder locations, telling Stata, for example to
keep all your various file types in different places, if you prefer to keep
it organized this way, rather than by project.
*/
global SOURCE "/home/username/Dropbox/Stata/"
global RAW "${SOURCE}raw/"
global LOG "${SOURCE}log/"
global DO "${SOURCE}do/"
global GRAPH "${SOURCE}graph/"
global OUTDATA "${SOURCE}outdata/"
global OUTPUT "${SOURCE}output/"
global WD "${SOURCE}wd/"

/*The good thing is, you then have a simple macro for calling file locations
in Stata. For example, with raw data, you'd use:

use "${RAW}data.dta", clear
*/

*There is lots more you could do... but simple things like changing the startup
*message to bid you good day are fun too.

noisily display "Good day, Nicholas!"
