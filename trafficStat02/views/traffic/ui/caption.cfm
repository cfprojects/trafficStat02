<!---
Copyright (c) 2012 James Mohler

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

<!---
<cfset variables.fuseaction = myFusebox.originalFuseaction>
--->

<cfset rc = caller.rc>




<cfparam name="showfuseactionfilter" default="yes">
<cfparam name="rc.showpull" default="1">

<cfparam name="rc.filterSection" default="">
<cfparam name="rc.filterItem" default="">


<cfparam name="rc.datetype">


<cfparam name="rc.filterDate" default="#now()#">

<cfswitch expression="#rc.dateType#">
<cfcase value="Month">
	<cfset rc.filterDate = "#month(rc.filterdate)#/1/#year(rc.filterdate)#">

</cfcase>
</cfswitch>



<cfscript>
variables.target = request.action;
if (variables.target == "traffic.home") { variables.target = "traffic.details"; }
</cfscript>

<cfinvoke webservice="http://foundation.qcliving.com/resource/traffic.cfc?wsdl" 
	method="getSection" 
	returnVariable="qrySection" />


<cfinvoke webservice="http://foundation.qcliving.com/resource/traffic.cfc?wsdl" 
	method="getItem" 
	returnVariable="qryItem">

	<cfinvokeargument name="FilterSection" value="#rc.FilterSection#">
</cfinvoke>	

</cfcase>


<cfcase value= 'end'>


<cfoutput>	

<form action="?action=#target#" method="post" class="form-horizontal well">
<fieldset>
    <legend>Generate Report</legend>
	


<div class="control-group">
   <label class="control-label" for="filtersection">Section</label>
   <div class="controls">
   		<select name="filtersection" onchange="submit()" class="input-medium">
			<option value="_Events" <cfif rc.FilterSection EQ "_Events">selected</cfif>>Events</option>
			<option value="_Pages" 	<cfif rc.FilterSection EQ "_Pages">selected</cfif>>Pages</option>
			<option value="_Blogs" 	<cfif rc.FilterSection EQ "_Blogs">selected</cfif>>Blogs</option>
							
						
			<optgroup label="Sections">
				<option value="" <cfif rc.FilterSection EQ "">selected</cfif>>[All Sections]
				<cfloop query="qrySection">
					<option value="#Section#" <cfif rc.FilterSection EQ Section>selected</cfif>>#Section#
				</cfloop>
			</optgroup>
   	</select>
   	</div>
</div>


<cfif rc.FilterSection NEQ "">
	<div class="control-group">
  		<label class="control-label" for="filteritem">Date Type</label>
   		<div class="controls">
  		 <select name="filteritem" onchange="submit()">
   			<option value="">[All Items]
			<cfloop query="qryItem">
				<option value="#item#" <cfif rc.FilterItem EQ Item>selected</cfif>>#Item#</option>
			</cfloop>
   		</select>
   		</div>
	</div>
</cfif>


<div class="control-group">
   <label class="control-label" for="datetype">Date Type</label>
   <div class="controls">
   <select name="datetype" onchange="submit()" class="input-small">
   		<option value="">[choose one]</option>
		<option value="day" 	<cfif rc.DateType EQ "day">selected</cfif>>1 Day</option>
		<option value="month" 	<cfif rc.DateType EQ "month">selected</cfif>>1 Month</option>
		<option value="year" 	<cfif rc.DateType EQ "year">selected</cfif>>1 Year</option>
   </select>
   </div>
</div>

</cfoutput>





<cfoutput>
<cfif rc.DateType EQ "day">
		<div class="control-group">
            <label class="control-label" for="filterdate">Date</label>
            <div class="controls">
              <select name="filterdate" onchange="submit()">
     			<cfloop from="-7" to="14" index="count">
					<option value="#dateadd("d", count, filterdate)#" <cfif dateformat(filterdate,"dd-mm-yyyy") is dateformat(dateadd("d",count,filterdate),"dd-mm-yyyy")>selected</cfif>>#dateformat(dateadd("d",count,filterdate),"dddd - mmm. d, 'yy")#
				</cfloop>
              </select>
            </div>
 </cfif>        


<cfif rc.DateType EQ "month">
		<div class="control-group">
            <label class="control-label" for="filterdate">Date</label>
            <div class="controls">
              <select name="filterdate" onchange="submit()" class="input-medium">
               <cfloop from="2011" to="#year(now())#" index="MyYear">
				<cfloop from="1" to="12" index="MyMonth">
					<cfset myDate = "#MyMonth#/1/#MyYear#">
				
					<option value="#DateAdd("d", 0, myDate)#"
						<cfif dateformat(rc.filterdate,"dd-mm-yyyy") EQ dateformat(dateadd("d",0,myDate),"dd-mm-yyyy")>selected</cfif>
						>#LSDateFormat(MyDate, "mmmm, yyyy")#</option>
				</cfloop>
			</cfloop>	
              </select>
            </div>
          </div>
</cfif>


<cfif rc.DateType EQ "year">
		<div class="control-group">
            <label class="control-label" for="filterdate">Date</label>
            <div class="controls">
              <select name="filterdate" onchange="submit()" class="input-medium">
               <cfloop from="-3" to="3" index="count">
					<option value="#LSDateFormat(dateadd('yyyy', count, filterdate),'mm/dd/yyyy')#" 
						<cfif dateformat(filterdate,"dd-mm-yyyy") EQ dateformat(dateadd("yyyy",count,filterdate),"dd-mm-yyyy")>selected</cfif>>#dateformat(dateadd("yyyy",count,filterdate),"yyyy")#
				</cfloop>
              </select>
            </div>
          </div>
</cfif>


	<div class="form-actions">
		<button type="submit" class="btn btn-primary"><i class="icon-search icon-white"></i> Filter</button>
	</div>


	</fieldset>
</form>


</cfoutput>


</cfcase>
</cfswitch>
