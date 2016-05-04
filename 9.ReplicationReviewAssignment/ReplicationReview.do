********************************************************************************
* DO File - Replication Review Assignment - Putting It All Together
********************************************************************************

********************************************************************************
/*Go to the following website.

https://dataverse.harvard.edu/

In the search box type ".dta replication"
Unclick dataverses and datasets on the left, leaving only "files".

Choose a replication dataset for an article that you find interesting.
Download all the files, including the Stata .dta file and the article...
from Google Scholar if necessary.

If you're lucky, the author may even provide the Stata code (.do file) for 
performing their analyses.
*/

********************************************************************************

*#1 Explore the data

*Do some summary commands. Describe. Summarize key variables. Tab a few if needed.
*Run some univariate visuals such as histograms. etc.

********************************************************************************

*#2 Replication

*First, try to perform exactly the same analysis as the author, either
	*using their .do file, or approximating it by reading their methods
	*section.
	
*Did you get the same results?

********************************************************************************

*#3 OLS version

*Now perform an OLS regression using the same variables.
*If their model above was too complicated and they did not provide the code,
	*feel free to skip the second step.


********************************************************************************

*#3 Clean Up

*Hopefully their dataset is already really clean and final.
*If not, and you want to clean up some of the names or labels, do that here.


********************************************************************************

*#4 Outliers

*Look at Lab 5 and perform some of the outlier diagnostics on this dataset,
	*using only the relevant Y and X model from the article (OLS version).

*What do you conclude? Were outliers driving any of this analysis?
	
	
********************************************************************************

*#5 Heteroskedasticity

*Look at Lab 6, and perform some heteroskedasticity diagnostics including 
	*visualizations, and if appropriate, some corrections.
	
*What do you conclude? Was there heteroskedasticity? How did you deal with it?

********************************************************************************

*#6 Multi-Collinearity

*Test the OLS regression model for multi-collinearity using VIF and 1/VIF.

*What do you conclude? Is high or perfect multicollinearity a problem? If so,
	*what will you do?
	
********************************************************************************

*#7 Time-series (autocorrelation)

*If your data has a temporal component, consider running some of the autocorrelation
	*tests in Lab 7, or the xtserial test from Lab 8 if it is panel data.
	
*Correct for autocorrelation or "heterogeneity bias". Which model do you use?

********************************************************************************

*#8 Lastly, consider the overall picture. Do you think the authors performed
	*thorough diagnostics on their data and models? Were any of the above tests
	*serious problems that were affecting their results? If so, what effect were
	*they having? Did they bias standard errors, coefficients, efficiency?
	
