<!---
Copyright (C) 2012 James Mohler

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

<cfswitch expression="#thisTag.ExecutionMode#">
<cfcase value= 'start'>

<cfscript>
rc = caller.rc;


NewVisitors = rc.wsTraffic.getHits(now(),'hour', 'new');
ReturnVisitors = rc.wsTraffic.getHits(now(),'hour', 'returning');

totalVisitors = NewVisitors + ReturnVisitors;


DirectVisitors = rc.wsTraffic.getHits(now(), 'hour', 'direct');
OrganicVisitors = rc.wsTraffic.getHits(now(),'hour', 'organic');
ReferralVisitors = rc.wsTraffic.getHits(now(),'hour', 'referral');
</cfscript>

</cfcase>
<cfcase value= 'end'>


<div class="jumbotron subhead">
  	<h1><cfoutput>#totalvisitors#</cfoutput></h1>
	<p>Visitors Right Now</p>	 
</div>


<cfoutput>
<table class="table table-condensed">
<thead>
<tr>
	<th>Type</th>
	<th></th>
	<th></th>
</tr>
</thead> 
<tr>
	<td>New</td>
	<td>#NewVisitors#</td>
	<td style="width : 100px;">
	
	<cfset bar = 0>
	<cfif totalVisitors GT 0>
		<cfset bar = (NewVisitors * 100) \ totalVisitors>
	</cfif>
	
	<div class="progress">
  		<div class="bar" style="width: #bar#%;"></div>
	</div>
	</td>
</tr>
<tr>
	<td>Returning</td>
	<td>#ReturnVisitors#</td>
	<td style="width : 100px;">
	<cfset bar = 0>
	<cfif totalVisitors GT 0>
		<cfset bar = (ReturnVisitors * 100) \ totalVisitors>
	</cfif>
	
	<div class="progress">
  		<div class="bar" style="width: #bar#%;">#bar#%</div>
	</div>
	</td>
</tr>
</table>



<table class="table table-condensed">
<thead>
<tr>
	<th>From</th>
	<th></th>
	<th></th>
</tr>
</thead>
<tr>
	<td>Direct</td>
	<td>#DirectVisitors#</td>
	<td style="width : 100px;">
	<cfset bar = 0>
	<cfif totalVisitors GT 0>
		<cfset bar = (DirectVisitors * 100) \ totalVisitors>
	</cfif>
	
	<div class="progress">
  		<div class="bar" style="width: #bar#%;">#bar#%</div>
	</div>
	</td>
</tr>
<tr>
	<td>Organic</td>
	<td>#OrganicVisitors#</td>
	<td style="width : 100px;">
	<cfset bar = 0>
	<cfif totalVisitors GT 0>
		<cfset bar = (OrganicVisitors * 100) \ totalVisitors>
	</cfif>
	<div class="progress">
  		<div class="bar" style="width: #bar#%;">#bar#%</div>
	</div>
	</td>
</tr>
<tr>
	<td>Referral</td>
	<td>#ReferralVisitors#</td>
	<td style="width : 100px;">
	<cfset bar = 0>
	<cfif totalVisitors GT 0>
		<cfset bar = (ReferralVisitors * 100) \ totalVisitors>
	</cfif>
	<div class="progress">
  		<div class="bar" style="width: #bar#%;">#bar#%</div>
	</div>
	</td>
</tr>

</table> 



</cfoutput>



</cfcase>
</cfswitch>
