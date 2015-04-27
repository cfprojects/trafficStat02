<!---
Copyright © 2012 James Mohler

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--->


<cfcomponent>

<cfscript>
function init(fw) { variables.fw = fw; }
</cfscript>


<cffunction name="before">
	<cfargument name="rc" type="struct" required="true">
	
	<cfparam name="rc.DateType" default="Month">
	<cfparam name="rc.filterSection" default="">
	<cfparam name="rc.filterItem" default="">
	<cfparam name="rc.filterDate" default="#now()#">
	

	<cfscript>
	try	{
		rc.wsTraffic = CreateObject("webservice", application.stSetting.ws.traffic);
		}
		
	catch(any e)	{
		rc.wsTraffic = CreateObject("webservice", application.stSetting.ws.get('traffic'));

		}
	</cfscript>
	

</cffunction>


<cffunction name="home">
	<cfargument name="rc" type="struct" required="true">



<cfscript>
	var qrySectionItem = rc.wsTraffic.getTopSectionItemByMonth(now(),'','','nobot');
	rc.qrySectionItem = qrySectionItem;

	rc.stSummary = {
		UsersThisHour 		= rc.wsTraffic.getUsersThisHour(now()),
		UsersThisDay 		= rc.wsTraffic.getUsersThisDay(now()),
		UsersThisMonth 		= rc.wsTraffic.getUsersThisMonth(now()),
	
		ForecastUsersThisHour 	= rc.wsTraffic.getForecastUsersThisHour(now()),
		ForecastUsersThisDay 	= rc.wsTraffic.getForecastUsersThisDay(now()),
		ForecastUsersThisMonth 	= rc.wsTraffic.getForecastUsersThisMonth(now()),		
	
	
		HitsThisHour 			= rc.wsTraffic.getHits(now(), 'hour', 'nobot'),
		HitsThisDay 			= rc.wsTraffic.getHits(now(), 'day', 'nobot'),
		HitsThisMonth 			= rc.wsTraffic.getHits(now(), 'month', 'nobot'),
	
		ForecastThisHour 		= rc.wsTraffic.getForecastThisHour(now(), 'nobot'),
		ForecastThisDay 		= rc.wsTraffic.getForecastThisDay(now(), 'nobot'),
		ForecastThisMonth 		= rc.wsTraffic.getForecastThisMonth(now(), 'nobot'),

		
		BotsThisHour 			= rc.wsTraffic.getHits(now(), 'hour', 'bot'),
		BotsThisDay 			= rc.wsTraffic.getHits(now(), 'day'	, 'bot'),
		BotsThisMonth 			= rc.wsTraffic.getHits(now(), 'month', 'bot'),
	
		ForecastBotsThisHour 	= rc.wsTraffic.getForecastThisHour(now(), 'bot'),
		ForecastBotsThisDay 	= rc.wsTraffic.getForecastThisDay(now(), 'bot'),
		ForecastBotsThisMonth 	= rc.wsTraffic.getForecastThisMonth(now(), 'bot')
		};
		
	rc.otherhits = evaluate(replace(valuelist(qrySectionItem.hits),",","+","all"));		
</cfscript>




	<cfoutput query="qrySectionItem" maxrows="10">
		<cfset rc.otherhits -= hits>
	</cfoutput>



</cffunction>


<cffunction name="details">
	<cfargument name="rc" type="struct" required="true">

<cfscript>
var stFilter = {filterDate = rc.FilterDate, dateType = rc.DateType, filterSection = rc.FilterSection, filterItem = rc.filterItem};


rc.otherhits = 0;

rc.DirectVisitors 	= rc.wsTraffic.getHits(now(), rc.DateType, 'direct');
rc.OrganicVisitors 	= rc.wsTraffic.getHits(now(), rc.DateType, 'organic');
rc.ReferralVisitors = rc.wsTraffic.getHits(now(), rc.DateType, 'referral');

rc.BounceVisitors = rc.wsTraffic.getHits(now(), rc.DateType, 'bounce');
</cfscript>


<cfinvoke webservice="#rc.wsTraffic#" 
	method="getTopSectionItem"
	argumentcollection="#stFilter#"  
	returnVariable="rc.qryTopSectionItem" />


<cfinvoke webservice="#rc.wsTraffic#" 
	method="getDetails" 
	argumentcollection="#stFilter#" 
	returnVariable="rc.stGraph" />


<cfinvoke webservice="#rc.wsTraffic#" 
	method="getOSBrowser" 
	argumentcollection="#stFilter#" 
	returnVariable="rc.qryOsBrowser" />

<cfinvoke webservice="#rc.wsTraffic#" 
	method="getBot" 
	argumentcollection="#stFilter#" 
	returnVariable="rc.qryBot" />

<!--->
<cfinvoke webservice="#rc.wsTraffic#" 
	method="getOrigin" 
	argumentcollection="#stFilter#" 
	returnVariable="rc.qryOrigin" />
--->

<cfoutput query="rc.qryTopSectionItem" startRow="10">
	<cfset rc.otherhits += hits>
</cfoutput>



</cffunction>



</cfcomponent>


