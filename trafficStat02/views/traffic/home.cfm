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



<cfimport prefix="common" taglib="../_common">
<cfimport prefix="ui" taglib="ui">




<div class="row">
	<div class="span2">
		<ui:rightnow />
	</div>
	
	<div class="span1">&nbsp;</div>

	<div class="span5">
		<ui:caption />
	</div>

	<div class="span1">&nbsp;</div>
</div>	
	


<cfoutput>

<div class="row">
	<div class="span2">&nbsp;</div>

	<div class="span5">


<table class="table table-condensed table-bordered">
<tr>
	<th>Visitor Summary</th>
	<td style="text-align : right;">This Hour</td>
	<td style="text-align : right;"><a href="#buildURL('traffic.details&datetype=day')#">Today</a></td>
	<td style="text-align : right;"><a href="#buildURL('traffic.details&datetype=month')#">This Month</a></td>
</tr>
<tr>
	<td>Current:</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.usersthishour)# visitors</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.usersthisday)# visitors</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.usersthismonth)# visitors</td>
</tr>
<tr>
	<td>Forecast:</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.forecastusersthishour)# visitors</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.forecastusersthisday)# visitors</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.forecastusersthismonth)# visitors</td>
</tr>

<tr>
	<th>Traffic Summary</th>
	<td width="20%" style="text-align : right;">This Hour</td>
	<td width="20%" style="text-align : right;"><a href="#buildURL('traffic.details&datetype=day')#">Today</a></td>
	<td width="20%" style="text-align : right;"><a href="#buildURL('traffic.details&datetype=month')#">This Month</a></td>
</tr>

<tr>
	<td>Current:</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.HitsThisHour)# hits</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.HitsThisDay)# hits</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.HitsThisMonth)# hits</td>
</tr>
<tr>
	<td>Forecast:</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.ForecastThisHour)# hits</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.ForecastThisDay)# hits</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.ForecastThisMonth)# hits</td>
</tr>
<tr>
	<th>Bot Summary</th>
	<td style="text-align : right;">This Hour</td>
	<td style="text-align : right;"><a href="#buildURL('.details&datetype=day')#">Today</a></td>
	<td style="text-align : right;"><a href="#buildURL('.details&datetype=month')#">This Month</a></td>
</tr>
<tr>
	<td>Current:</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.botsthishour)# bots</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.botsthisday)# bots</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.botsthismonth)# bots</td>
</tr>
<tr>
	<td>Forecast:</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.forecastbotsthishour)# bots</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.forecastbotsthisday)# bots</td>
	<td style="text-align : right;">#LSNumberFormat(rc.stSummary.forecastbotsthismonth)# bots</td>
</tr>

</table>

	</div>

	<div class="span2">&nbsp;</div>
</div>	
	

<ul class="std">
	<li>This page shows a summary of the traffic on your site. You can drill down to more
detailed information on the number of hits, number of users and the most viewed actions.</li>
</ul>
</cfoutput>



<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
  google.load("visualization", "1", {packages:["corechart"]});
  google.setOnLoadCallback(drawChart);
  function drawChart() {
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Hits');
    data.addColumn('number', 'Action');
    data.addRows([
    
    <cfoutput query="rc.qrySectionItem" maxrows="10">	
      ['#action#',    #hits#],
    </cfoutput>  
      ['Others',    <cfoutput>#rc.otherhits#</cfoutput>]
    ]);

    var options = { width: 600, height: 350    };

    var chart = new google.visualization.PieChart(document.getElementById('chart_pie'));
    chart.draw(data, options);
   
  }
</script>

<h2>This Months Top Pages</h2>
<div id="chart_pie" align="center"></div>



<div class="row">

<h2>Traffic</h2>
<ui:lasthits />


<h2>Search Terms</h2>
<ui:lasthits mode="search" />

<h2>Referer</h2>
<ui:lasthits mode="referer" />

<h2>Bots</h2>
<ui:lasthits mode="bot" />


</div>

