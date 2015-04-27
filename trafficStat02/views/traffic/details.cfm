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


<cfimport prefix="ui" taglib="ui">

<script type="text/javascript" src="https://www.google.com/jsapi"></script>

	

<div class="row">
    <div class="span1">&nbsp;</div>
    
	<div class="span7">
		<ui:caption />




<h2>Visitor Origin</h2>
<div id="origin_bar"></div>

<script type="text/javascript">
  google.load("visualization", "1", {packages:["corechart"]});
  google.setOnLoadCallback(drawChart);
  function drawChart() {
  	var data = new google.visualization.DataTable();
    data.addColumn('string', 'Visitors');
    data.addColumn('number', 'Direct');
    data.addColumn('number', 'Organic');
    data.addColumn('number', 'Referral');

    data.addRows([
    <cfoutput>
        ['', #rc.DirectVisitors#, #rc.OrganicVisitors#, #rc.ReferralVisitors#]
    </cfoutput>
    ]);

    var options = {width: 700, height: 90, isStacked : 1, legend : 'none' };

    
    var chart = new google.visualization.BarChart(document.getElementById('origin_bar'));
    chart.draw(data, options);
    
    
    
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Hits');
    data.addColumn('number', 'Action');
    data.addRows([
    
    <cfoutput query="rc.qryTopSectionItem" maxrows="10">	
      ['#action#',    #hits#],
    </cfoutput>  
      ['Others',    <cfoutput>#rc.otherhits#</cfoutput>]
    ]);

    var options = {width: 700, height: 300 };

    var chart = new google.visualization.PieChart(document.getElementById('chart_pie'));
    chart.draw(data, options);
    
   // OS Browser
   	var OBdata = new google.visualization.DataTable();
    OBdata.addColumn('string', 'Hits');
    OBdata.addColumn('number', 'OS:Browser');
    OBdata.addRows([
    
    <cfoutput query="rc.qryOSBrowser">	
      ['#OB#',    #hits#] <cfif currentrow NEQ rc.qryOSBrowser.recordcount>,</cfif>
    </cfoutput>  
    ]);

    var options = {width: 700, height: 300 };

    var OBchart = new google.visualization.PieChart(document.getElementById('OB_pie'));
    OBchart.draw(OBdata, options); 
    
    
    // Bots
   	var botdata = new google.visualization.DataTable();
    botdata.addColumn('string', 'Hits');
    botdata.addColumn('number', 'OS:Browser');
    botdata.addRows([
    
    <cfoutput query="rc.qryBot">	
      ['#OB#', #hits#] <cfif currentrow NEQ rc.qryBot.recordcount>,</cfif>
    </cfoutput>  
    ]);

    var options = {width: 700, height: 300 };

    var botchart = new google.visualization.PieChart(document.getElementById('Bot_pie'));
    botchart.draw(botdata, options); 
    
}
</script>



<cfoutput>
<div class="well summary">
<ul>
	<li>
		<span class="count">#rc.BounceVisitors#</span> Bounces
	</li>
	
</ul>
</div>
</cfoutput>




<cfoutput>
<h2>#rc.stGraph.graphtitle#</h2>
</cfoutput>



<ui:bargraph qryData="#rc.stGraph.qryGraph#" title="" xlabel = "#rc.stGraph.graphxlabel#" />



<h2>Page Views</h2>
<div id="chart_pie"></div>

<h2>Hits</h2>
<div id="OB_pie"></div>	


<h2>Bots</h2>
<div id="Bot_pie"></div>	


	</div>
	<div class="span1">&nbsp;</div>
</div>		

