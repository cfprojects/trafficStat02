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

	<cfparam name="attributes.mode" default="all">	
	
	<cfset wsTraffic = CreateObject("webservice", application.stSetting.ws.traffic)>

		
	<cfset qryLastHits = wsTraffic.getLastHits(attributes.mode)>
	




</cfcase>
<cfcase value= 'end'>




<table class="table table-condensed">
<thead>
<tr>
	<th>Date</th>
	<th>Time</th>
	<cfif attributes.mode EQ "referer">
		<th>Referer</th>
	<cfelse>
		<th>Action</th>
		<th>Search</th>
		<th>Tag</th>
	</cfif>

	<th>OS</th>
	<th>Browser</th>
	<th>&nbsp;</th>
</tr>
</thead>

<cfoutput query="qryLastHits">
<tr>
	<td>#LSDateFormat(CreateDate)#</td>
	<td>#LSTimeFormat(CreateDate)#</td>
	
	<cfif attributes.mode EQ "referer">
		<td>#htmleditformat(referer)#</td>
	<cfelse>
		<td>#Section#.#Item#</td>
		<td>#HTMLEditFormat(Search)#</td>
		<td>#HTMLEditFormat(Tag)#</td>
	</cfif>
	
	
	<td>#OS#</td>
	<td>#Browser#</td>
	<td>
	<a href="##" rel="popover" title="More Info" data-content="Referer: #Referer# Agent: #agent#"><i class="icon-info-sign" /></i></a>
	</td>
</tr>
</cfoutput>
</table>



</cfcase>
</cfswitch>

