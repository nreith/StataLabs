*Reproducible Research with Stata

********************************************************************************
*Setting up the Working Directory, Line Width, Log File, and other options
********************************************************************************
*NOTE: Please manually create a folder called "Lab3" somewhere, and change
	*the line below to the path for that folder!
	cap noi cd "~/Dropbox/Git/repositories/StataLabs/AdvancedTips&Tricks/c.ReproducibleResearch/"
	cap qui log c /*Abbreviation of "capture quietly log close"*/
	set linesize 70 /*Line width*/
	set more off, permanently /*Let the scrolling flow.*/
	qui log using "output.smcl", replace /*Start a log file, by default smcl*/
********************************************************************************

clear
// prestige data
use http://www.ats.ucla.edu/stat/stata/examples/ara/prestige
//(From Fox, Applied Regression Analysis.  Use 'notes' command for source of data)
hist income, xlabel(0(5000)30000) start(0) width(5000)  addlabels
graph export "hist_income.png", replace

********************************************************************************
*Installing some add-ons for Markdown/LaTeX reproducible documents
	*Manually highlight and run the indented section below from "capture" to "}"
	*only the first time, to install the necessary programs. I comment it out,
	*so that it runs faster on subsequent runs.
********************************************************************************
	
			capture noisily {
			ssc install markdoc, replace
			ssc install weaver, replace
			ssc install synlight, replace /*Includes ketchup*/
			ssc install statax, replace /*Syntax highlighting for Stata*/
			}

********************************************************************************

//OFF
clear
// prestige data
use http://www.ats.ucla.edu/stat/stata/examples/ara/prestige
//(From Fox, Applied Regression Analysis.  Use 'notes' command for source of data)
//ON
hist income, xlabel(0(5000)30000) start(0) width(5000)  addlabels
//OFF
graph export "graph1.png", replace width(400)
//ON
/***
#Prestige Data

![Histogram of Income](graphs/graph1.png)

It looks like income is pretty skewed! As usual, we might want to log income.
***/



*Exporting to PDF format using Markdoc
********************************************************************************
	
	qui log c /*Quietly close the log file*/
	
	markdoc output, install replace statax export(pdf) style(stata) ///
	title(Output) author(Student XYZ) ///
	affiliation(Department of ABC, The University of Texas at Austin) ///
	summary("NOTE: This is a sample *reproducible*, *dynamic* document" ///
	"created using Stata and the Markdoc package for" ///
	"Stata to weave formatted text written in Markdown Syntax with" ///
	"bits of Stata Code and Output. For more details on writing in" ///
	"*Markdown*, type ''help markdoc'' in the Stata console, or see"	///
	"[Markdoc documentation here](http://www.haghish.com/statistics/stata-blog/reproducible-research/dynamic_documents/markdown.php)" ///
	"or [Markdown documentation here](http://daringfireball.net/projects/markdown/syntax).")	
	
/*
	NOTE: You can also export to:
		.md (Markdown), .html, .docx, .pdf, .pdf (slides), 
		.odt, .tex (LaTeX), and .epub
		
	NOTE: An explanations of some of the options used above:
		
		-INSTALL: installs "Pandoc" and "wkhtmltopdf" temporarily to Stata.
			Both are necessary for Markdoc. If you are working on your own
			computer, it is better to install them both separately to have
			regular updates, and remove the INSTALL option above.
	
		-REPLACE: replaces the document each time you re-run things
		
		-STATAX: uses a javascript plugin from the synlight pacakge to properly
			highlight Stata code and output with different colors.
		
		-STYLE: "stata" or "classic", or you can write your own with css or LaTeX
		
		-TITLE/AUTHOR/AFFILIATION/SUMMARY: self-explanatory
		
*/
