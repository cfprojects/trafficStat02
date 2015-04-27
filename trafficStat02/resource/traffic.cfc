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

<cfcomponent>


<cfscript>
// Traffic
string function stripHTML(str) output="false" {
	return REReplaceNoCase(arguments.str,"<[^>]*>","","ALL");
	}


boolean function add(
				string SubSystem = '',
	required 	string Section, 
	required 	string Item,
				boolean isPost = 0,
	 
	required	string http_user_agent,
	required	string Remote_addr,
	required	string http_accept_language,
	required	string http_referer,
			
				string Search = '',
				string Tag = '',
				string NodeID = ''
							
	) output="false" access="remote"	{


	if (arguments.section == "traffic")	{ return false; }


	local.ormTraffic = entityNew("TrafficLoad", {
			SubSystem	= arguments.SubSystem == "" ? JavaCast("null", "") : this.stripHTML(arguments.SubSystem),
			Section 	= this.stripHTML(arguments.Section),
			Item 		= this.stripHTML(arguments.Item),
			isPost		= arguments.isPost,
			Remote_addr	= arguments.remote_addr,
			http_accept_Language = arguments.http_accept_language,
			
			Agent		= stripHTML(arguments.http_user_agent),
						
			Referer		= arguments.http_Referer	== "" ? JavaCast("null", "") : stripHTML(arguments.http_referer),
			Search		= arguments.Search 	== "" ? JavaCast("null", "") : stripHTML(arguments.search),
			Tag			= arguments.Tag 	== "" ? JavaCast("null", "") : stripHTML(arguments.tag),
			NodeID		= arguments.NodeID 	== "" ? JavaCast("null", "") : stripHTML(arguments.nodeid) //no comma
			});
			
	EntitySave(local.ormTraffic); // Commit may actually happen later
	
	return true;
	} // end function add
		


numeric function getHits(required date filterDate, required string datetype, required string mode) output="false" access="remote" 	{
	
	switch (arguments.datetype)	{
		case "hour" :
			return this.getHitsThisHour(arguments.filterDate, arguments.mode);
			break;
		case "day" :
			return this.getHitsThisDay(arguments.filterDate, arguments.mode);
			break;
		}

		
	return this.getHitsThisMonth(arguments.filterDate, arguments.mode);
	}


	
struct function getDetails(
	required string dateType,
	required date filterDate, 
	string filterSection = '', 
	string filterItem = '') output="false" access="remote" {

	
	
	switch (arguments.datetype)	{
		case "day" :
			return this.getDay(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		case "month" :
			return this.getMonth(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		}
	
		
	return this.getYear(arguments.filterDate, arguments.filterSection, arguments.filterItem);
	
	}


query function getOSBrowser(
	required string dateType,
	required date filterDate, 
	string filterSection = '', 
	string filterItem = '') output="false" access="remote" {
	
	switch (arguments.datetype)	{
		case "day" :
			return this.getOBDay(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		case "month" :
			return this.getOBMonth(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		}
	

	return this.getOBYear(arguments.filterDate, arguments.filterSection, arguments.filterItem);
	}


query function getBot(
	required string dateType,
	required date filterDate, 
	string filterSection = '', 
	string filterItem = '') output="false" access="remote" {
	
	switch (arguments.datetype)	{
		case "day" :
			return this.getOBDay(arguments.filterDate, arguments.filterSection, arguments.filterItem, 'Bot');
			break;
		case "month" :
			return this.getOBMonth(arguments.filterDate, arguments.filterSection, arguments.filterItem, 'Bot');
			break;
		}
	
	return this.getOBYear(arguments.filterDate, arguments.filterSection, arguments.filterItem, 'Bot');
	}

	

query function getTopSectionItem(
	required string dateType,
	required date filterDate, 
	string filterSection = '', 
	string filterItem = '') output="false" access="remote" {
	
	switch (arguments.datetype)	{
		case "hour" :
			return this.getTopSectionItemByHour(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		case "day" :
			return this.getTopSectionItemByDay(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		case "month" :
			return this.getTopSectionItemByMonth(arguments.filterDate, arguments.filterSection, arguments.filterItem);
			break;
		}

	return this.getTopSectionItemByYear(arguments.filterDate, arguments.filterSection, arguments.filterItem);
	}

</cfscript>


<cffunction name="getDay" output="false" returntype="struct" hint="Data is broken down by hour">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">


	
	<cfscript>
	var graph = querynew("x_axis,bot,hit,visitor");
	var tempgraph = "";
	var result = {
		graphtitle	= "Page Views for #dateformat(arguments.filterdate,'dddd mmmm d, yyyy')#",
		graphxlabel	= "Hours",
		xlabel		= "Hour"
		};
	</cfscript>


	
	<cfquery name="tempgraph">
		SELECT 	datepart(hour, Createdate) AS x_axis, COUNT(DISTINCT remote_addr) AS visitor, 
			SUM(CASE WHEN Browser LIKE '%bot%' THEN 0 ELSE 1 END) as hit,
			SUM(CASE WHEN Browser LIKE '%bot%' THEN 1 ELSE 0 END) as bot
		FROM 	dbo.Traffic
		WHERE 	Createdate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(arguments.filterdate,'mm/dd/yyyy')#">
			AND		<cfqueryparam cfsqltype="cf_sql_date" value="#dateformat(dateadd('d',1,arguments.filterdate),'mm/dd/yyyy')#">
		
		<cfif arguments.FilterSection NEQ "">
		AND		Section 	= <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item 	= <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		
		GROUP BY datepart(hour, CreateDate)
		order by datepart(hour, CreateDate)
	</cfquery>
	
	
	<cfscript>
	for (count = 0; count <= 23; count++)	{
		queryaddrow(graph);
		querysetcell(graph,"x_axis",count);
		finddate = listfind(valuelist(tempgraph.x_axis),count);
		if (finddate)	{
			querysetcell(graph, "visitor", 	listgetat(valuelist(tempgraph.visitor),finddate));
			querysetcell(graph, "hit", 		listgetat(valuelist(tempgraph.hit),finddate));
			querysetcell(graph, "bot", 		listgetat(valuelist(tempgraph.bot),finddate));
			}
		else	{ 
			querysetcell(graph,"visitor",0);
			querysetcell(graph,"hit",0);
			querysetcell(graph,"bot",0);
			}
		}
	
	result.qryGraph = graph;

	return result;
	</cfscript>
</cffunction>


<cffunction name="getMonth" output="false" returntype="struct" hint="Data broken down by day of the month">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">

	<cfscript>
	var graph = querynew("x_axis,bot,hit,visitor,themonth,theyear");
	var tempgraph = "";
	var result = {
		graphtitle	= "Page Views for the month of #dateformat(arguments.filterdate,'mmmm yyyy')#",
		graphxlabel	= "Days",
		xlabel		= "Day"
		};
	</cfscript>

	
	<cfquery name="tempgraph">
		SELECT 	day(CreateDate) as x_axis, month(CreateDate) as themonth, year(CreateDate) as theyear, 
			COUNT(DISTINCT remote_addr) AS visitor, 
			SUM(CASE WHEN Browser LIKE '%bot%' THEN 0 ELSE 1 END) as hit,
			SUM(CASE WHEN Browser LIKE '%bot%' THEN 1 ELSE 0 END) as bot
			
		FROM 	dbo.Traffic
		WHERE 	month(CreateDate)	= <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#month(arguments.filterdate)#">
		AND		year(CreateDate) 	= <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#year(arguments.filterdate)#">
		
		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		GROUP BY day(CreateDate), month(CreateDate), year(CreateDate)
		ORDER BY day(CreateDate)
	</cfquery>
	
	<cfscript>
	for(count = 1; count <= daysinmonth(arguments.filterdate); count++)	{
		queryaddrow(graph);
		querysetcell(graph,"x_axis",count);
		querysetcell(graph,"themonth",month(arguments.filterdate));
		querysetcell(graph,"theyear",year(arguments.filterdate));
		finddate = listfind(valuelist(tempgraph.x_axis),count);
		
		if (finddate)	{
			querysetcell(graph, "visitor", 	listgetat(valuelist(tempgraph.visitor),finddate));
			querysetcell(graph, "hit", 		listgetat(valuelist(tempgraph.hit),finddate));
			querysetcell(graph, "bot", 		listgetat(valuelist(tempgraph.bot),finddate));
			}
		else	{ 
			querysetcell(graph,"visitor",0);
			querysetcell(graph,"hit",0);
			querysetcell(graph,"bot",0);
			}
		}
	
	result.qrygraph = graph;

	return result;
	</cfscript>
</cffunction>


<cffunction name="getYear" output="false" returntype="struct" hint="Data broken down by month of the year">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">

	<cfscript>
	var graph = querynew("x_axis,bot,hit,visitor,theyear");
	var tempgraph = "";
	var result = {
		graphtitle	= "Page Views for #dateformat(arguments.filterdate,'yyyy')#",
		graphxlabel	= "Months",
		xlabel		= "Month"
		};
	</cfscript>



	<cfquery name="tempgraph">
		SELECT	DATENAME(month, CreateDate), month(CreateDate) as x_axis, Year(CreateDate) as theyear, 
			COUNT(DISTINCT remote_addr) AS visitor, 
			SUM(CASE WHEN Browser LIKE '%bot%' THEN 0 ELSE 1 END) as hit,
			SUM(CASE WHEN Browser LIKE '%bot%' THEN 1 ELSE 0 END) as bot
	
		FROM 	dbo.Traffic
		WHERE	year(CreateDate) = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#year(arguments.filterdate)#">

		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		GROUP BY Year(CreateDate), Month(CreateDate),DATENAME(month, CreateDate)
		ORDER BY Year(CreateDate), Month(CreateDate)
	</cfquery>
		
	
	
	<cfscript>
	for (count = 1; count <= 12; count++)	{
	
		queryaddrow(graph);
		querysetcell(graph,"x_axis",count);
		finddate = listfind(valuelist(tempgraph.x_axis),count);
		querysetcell(graph,"theyear",year(arguments.filterDate));
		
		if (finddate)	{
			querysetcell(graph, "visitor", 	listgetat(valuelist(tempgraph.visitor),finddate));
			querysetcell(graph, "hit", 		listgetat(valuelist(tempgraph.hit),finddate));
			querysetcell(graph, "bot", 		listgetat(valuelist(tempgraph.bot),finddate));
			}
		else	{ 
			querysetcell(graph,"visitor",0);
			querysetcell(graph,"hit",0);
			querysetcell(graph,"bot",0);
			}
		}	
	
	result.qrygraph = graph;

	return result;
	</cfscript>

</cffunction>


<cffunction name="getTopSectionItemByHour"  output="false" returntype="query">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">
	<cfargument name="mode" required="false" type="string" default="nobot">
	
	<cfquery name="topSectionItem">
		SELECT 	Section,Item,count(*) as hits
		FROM 	dbo.Traffic
		WHERE 	CreateDate BETWEEN <cfqueryparam CFSQLType="CF_SQL_DATE" value="#dateadd("n",-minute(arguments.filterdate) - 1, arguments.filterdate)#">
			AND		<cfqueryparam CFSQLType="CF_SQL_DATE" value="#dateadd("n",-minute(arguments.filterdate) + 60, arguments.filterdate)#">
		<cfif arguments.FilterSection NEQ "">
			AND		Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.Item NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		group by Section,Item
		order by hits desc
	</cfquery>
	
	
	<cfreturn topSectionItem>
</cffunction>


<cffunction name="getTopSectionItemByDay"  output="false" returntype="query">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">
	<cfargument name="mode" required="false" type="string" default="nobot">


	<cfquery name="qrytopSectionItem">
		SELECT 	
			CASE 
			WHEN isPost = 1 THEN [Section] + '.' + Item + ' (post)'
			ELSE [Section] + '.' + Item
				
			END AS Action,	
				
			count(*) as hits
		FROM	dbo.Traffic
		WHERE 	CreateDate BETWEEN <cfqueryparam CFSQLType="CF_SQL_DATE" value="#dateformat(arguments.filterdate,"mm/dd/yyyy")#">
			AND		<cfqueryparam CFSQLType="CF_SQL_DATE" value="#dateformat(dateadd("d",1,arguments.filterdate),"mm/dd/yyyy")#">
		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Filteritem#">
			</cfif>
		</cfif>
		
		<cfif arguments.mode EQ "nobot">
			AND NOT Browser LIKE '%bot%'
		<cfelse>
			AND Browser LIKE '%bot%'
		</cfif>
		
		group by Section, Item, isPost
		order by hits desc
	</cfquery>

	<cfreturn qryTopSectionItem>
</cffunction>


<cffunction name="getTopSectionItemByMonth"  output="false" returntype="query" access="remote">
	<cfargument name="filterDate" required="false" type="date" default="#now()#">
	<cfargument name="filterSection" required="false" type="string" default="">
	<cfargument name="filterItem" required="false" type="string" default="">
	<cfargument name="mode" required="false" type="string" default="nobot">
	
	<cfquery name="qrytopSectionItem">
		SELECT 	CASE 
			WHEN isPost = 1 THEN [Section] + '.' + Item + ' (post)'
			ELSE [Section] + '.' + Item
				
			END AS Action,	
				
			count(*) as hits
		FROM 	dbo.Traffic
		WHERE 	month(CreateDate) = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#month(arguments.filterdate)#">
		AND		year(CreateDate) = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#year(arguments.filterdate)#">

		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		
		<cfif arguments.mode EQ "nobot">
			AND NOT Browser LIKE '%bot%'
		<cfelse>
			AND Browser LIKE '%bot%'
		</cfif>
		
		group by Section, Item, isPost
		order by hits desc
	</cfquery>
	
	
	<cfreturn qrytopSectionItem>
</cffunction>


<cffunction name="getTopSectionItemByYear"  output="false" returntype="query">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">
	<cfargument name="mode" required="false" type="string" default="nobot">

	
	<cfquery name="qrytopSectionItem">
		SELECT 	CASE 
			WHEN isPost = 1 THEN [Section] + '.' + Item + ' (post)'
			ELSE [Section] + '.' + Item
				
			END AS Action,	
				
			count(*) as hits
		FROM 	dbo.Traffic
		WHERE year(CreateDate) = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#year(arguments.filterdate)#">
		
		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguements.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		
		<cfif arguments.mode EQ "nobot">
			AND NOT Browser LIKE '%bot%'
		<cfelse>
			AND Browser LIKE '%bot%'
		</cfif>
		
		
		group by Section, Item, isPost
		order by hits desc
	</cfquery>
		

	
	<cfreturn qrytopSectionItem>
</cffunction>



<cffunction name="getOBDay"  output="false" returntype="query">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">
	<cfargument name="mode" required="false" type="string" default="nobot">


	<cfquery name="qryOBYear">
		SELECT 	OS + ' : ' + Browser AS OB, count(*) as hits
		FROM 	dbo.Traffic
		WHERE 	CreateDate BETWEEN <cfqueryparam CFSQLType="CF_SQL_DATE" value="#dateformat(arguments.filterdate,'mm/dd/yyyy')#">
			AND	<cfqueryparam CFSQLType="CF_SQL_DATE" value="#dateformat(dateadd("d",1, arguments.filterdate),'mm/dd/yyyy')#">
		
		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		
		<cfif arguments.mode EQ "nobot">
			AND NOT Browser LIKE '%bot%'
		<cfelse>
			AND Browser LIKE '%bot%'
		</cfif>
		
		group by OS, Browser
		order by hits desc
	</cfquery>
	
	<cfreturn qryOBYear>
</cffunction>


<cffunction name="getOBMonth"  output="false" returntype="query">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">
	<cfargument name="mode" required="false" type="string" default="nobot">


	<cfquery name="qryOBYear">
		SELECT 	OS + ' : ' + Browser AS OB, count(*) as hits
		FROM 	dbo.Traffic
		WHERE 	month(CreateDate) 	= <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#month(arguments.filterdate)#">
		AND		year(CreateDate) 	= <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#year(arguments.filterdate)#">

		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Filteritem#">
			</cfif>
		</cfif>
		
		<cfif arguments.mode EQ "nobot">
			AND NOT Browser LIKE '%bot%'
		<cfelse>
			AND Browser LIKE '%bot%'
		</cfif>
		
		
		group by OS, Browser
		order by hits desc
	</cfquery>
		

	
	<cfreturn qryOBYear>
</cffunction>


<cffunction name="getOBYear"  output="false" returntype="query">
	<cfargument name="filterDate" required="true" type="date">
	<cfargument name="filterSection" required="true" type="string">
	<cfargument name="filterItem" required="true" type="string">
	<cfargument name="mode" required="false" type="string" default="nobot">


	<cfquery name="qryOBYear">
		SELECT 	OS + ' : ' + Browser AS OB, count(*) as hits
		FROM 	dbo.Traffic
		WHERE year(CreateDate) = <cfqueryparam CFSQLType="CF_SQL_INTEGER" value="#year(arguments.filterdate)#">

		<cfif arguments.FilterSection NEQ "">
			AND	Section = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterSection#">
			<cfif arguments.FilterItem NEQ "">
				AND Item = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.FilterItem#">
			</cfif>
		</cfif>
		
		<cfif arguments.mode EQ "nobot">
			AND NOT Browser LIKE '%bot%'
		<cfelse>
			AND Browser LIKE '%bot%'
		</cfif>
		
		
		group by OS, Browser
		order by hits desc
	</cfquery>
		

	
	<cfreturn qryOBYear>
</cffunction>




<cffunction name="getHitsThisHour" output="false" returntype="numeric">
	<cfargument name="filterDateTime" required="true" type="date">
	<cfargument name="mode" required="false" type="string" default="nobot">
	
	<cfset var qryThisHour = "">
	
	<cfquery name="qrythishour">
		SELECT 	count(TrafficID) AS thecount
		FROM 	dbo.Traffic
		WHERE 	CreateDate > #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
		AND		CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)+60,arguments.FilterDateTime)#
		
		<cfswitch expression="#arguments.mode#">
		<cfcase value="bounce">
			AND NOT remote_addr IN (
				SELECT 	remote_addr 
				FROM 	dbo.Traffic 
				WHERE	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				GROUP BY	remote_addr
				HAVING		COUNT(remote_addr) = 1
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
				
		
		<cfcase value="new">
			AND NOT remote_addr IN (
				SELECT 	remote_addr 
				FROM 	dbo.Traffic 
				WHERE	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="returning">
			AND remote_addr IN (
				SELECT remote_addr 
				FROM 	dbo.Traffic 
				WHERE CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="direct">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM dbo.Traffic
					WHERE 	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
					AND		CreateDate > dateAdd(mm, -1, getDate())
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		referer IS NULL		
				)
		
			AND NOT Browser LIKE '%bot%'
		
		</cfcase>
		
		<cfcase value="organic">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM dbo.Traffic
					WHERE 	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
					AND		CreateDate > dateAdd(mm, -1, getDate())
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		referer like '%search%'		
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="referral">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM dbo.Traffic
					WHERE 	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
					AND		CreateDate > dateAdd(mm, -1, getDate())
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		NOT referer like '%search%'		
				)
		
			AND NOT Browser LIKE '%bot%'
		
		</cfcase>
		
				
		<cfcase value="bot">
			AND Browser LIKE '%bot%'	
		</cfcase>
		
		<cfdefaultcase>
			AND NOT Browser LIKE '%bot%'
		</cfdefaultcase>
		</cfswitch>
	</cfquery>
	
	<cfreturn qryThisHour.Thecount>
</cffunction>


<cffunction name="getHitsThisDay" output="false" returntype="numeric">
	<cfargument name="filterDateTime" required="true" type="date">
	<cfargument name="mode" required="false" type="string" default="nobot">

	<cfquery name="qryday">
		SELECT count(*) AS thecount
		FROM 	dbo.Traffic
		WHERE	CreateDate > <cfqueryparam CFSQLType="CF_SQL_DATE" value="#createodbcdate(dateadd("h",-hour(arguments.FilterDateTime),arguments.FilterDateTime))#">
		AND		CreateDate < <cfqueryparam CFSQLType="CF_SQL_DATE" value="#createodbcdate(dateadd("h",-hour(arguments.FilterDateTime)+24,arguments.FilterDateTime))#">
		
				
		<cfswitch expression="#arguments.mode#">
		<cfcase value="bounce">
			AND NOT remote_addr IN (
				SELECT 	remote_addr 
				FROM 	dbo.Traffic 
				WHERE	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				GROUP BY	remote_addr
				HAVING		COUNT(remote_addr) = 1
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="new">
			AND NOT remote_addr IN (
				SELECT 	remote_addr 
				FROM 	dbo.Traffic 
				WHERE	CreateDate < #dateadd("h",-hour(arguments.FilterDateTime)-1, arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="returning">
			AND remote_addr IN (
				SELECT remote_addr 
				FROM 	dbo.Traffic 
				WHERE CreateDate < #dateadd("h",-hour(arguments.FilterDateTime)-1, arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="direct">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM dbo.Traffic
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		referer IS NULL		
				)
		
			AND NOT Browser LIKE '%bot%'
		
		</cfcase>
		
		<cfcase value="organic">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM dbo.Traffic
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		referer like '%search%'		
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="referral">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM dbo.Traffic
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		NOT referer like '%search%'		
				)
		
			AND NOT Browser LIKE '%bot%'
		
		</cfcase>
		
				
		<cfcase value="bot">
			AND Browser LIKE '%bot%'	
		</cfcase>
		
		<cfdefaultcase>
			AND NOT Browser LIKE '%bot%'
		</cfdefaultcase>
		</cfswitch>
	</cfquery>

	<cfreturn qryDay.Thecount>
</cffunction>


<cffunction name="getHitsThisMonth" output="false" returntype="numeric"> 
	<cfargument name="filterDateTime" required="true" type="date">
	<cfargument name="mode" required="false" type="string" default="nobot">

	<cfquery name="qrymonth">
		SELECT 	count(*) AS thecount
		FROM	dbo.Traffic WITH (NOLOCK)
		WHERE	CreateDate > #createodbcdate(dateadd("d",-day(arguments.FilterDateTime), arguments.FilterDateTime))#
		AND		CreateDate < #createodbcdate(dateadd("d",-day(arguments.FilterDateTime)+daysinmonth(arguments.FilterDateTime)+1,arguments.FilterDateTime))#
		
				
		<cfswitch expression="#arguments.mode#">
		<cfcase value="bounce">
			AND NOT remote_addr IN (
				SELECT 	remote_addr 
				FROM 	dbo.Traffic 
				WHERE	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				GROUP BY	remote_addr
				HAVING		COUNT(remote_addr) = 1
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<!---
		<cfcase value="new">
			AND NOT remote_addr IN (
				SELECT 	remote_addr 
				FROM 	dbo.Traffic 
				WHERE	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="returning">
			AND remote_addr IN (
				SELECT remote_addr 
				FROM 	dbo.Traffic 
				WHERE CreateDate < #dateadd("n",-minute(arguments.FilterDateTime)-1,arguments.FilterDateTime)#
				AND		CreateDate > dateAdd(mm, -1, getDate())
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		--->
		<cfcase value="direct">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT 	remote_addr, MIN(CreateDate) AS CreateDate
					FROM 	dbo.Traffic
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		referer IS NULL		
				)
		
			AND NOT Browser LIKE '%bot%'
		
		</cfcase>
		
		<cfcase value="organic">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT 	remote_addr, MIN(CreateDate) AS CreateDate
					FROM 	dbo.Traffic
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		referer like '%search%'		
				)
		
			AND NOT Browser LIKE '%bot%'
		</cfcase>
		
		<cfcase value="referral">
			AND remote_addr IN (
				SELECT B.remote_addr
				FROM dbo.Traffic, (
					SELECT remote_addr, MIN(CreateDate) AS CreateDate
					FROM 	dbo.Traffic
					GROUP BY remote_addr
					) B
				WHERE	dbo.Traffic.remote_addr = B.remote_addr
				AND		dbo.Traffic.CreateDate = B.CreateDate
				AND		NOT referer like '%search%'		
				)
		
			AND NOT Browser LIKE '%bot%'
		
		</cfcase>
		
				
		<cfcase value="bot">
			AND Browser LIKE '%bot%'	
		</cfcase>
		
		<cfdefaultcase>
			AND NOT Browser LIKE '%bot%'
		</cfdefaultcase>
		</cfswitch>
	</cfquery>
	
	<cfreturn qryMonth.Thecount>
</cffunction>




<!--- Forcast --->
<cfscript>
numeric function getForecastThisHour(required date FilterDateTime, string mode='nobot') output="false" access="remote" {
	if (dayofyear(arguments.FilterDateTime) < dayofyear(now()))
		return arguments.getHitsthishour(arguments.FilterDateTime, arguments.mode);
	else if (val(minute(arguments.FilterDateTime)))
		return round(60/minute(arguments.FilterDateTime) * this.getHitsthishour(arguments.FilterDateTime, arguments.mode));
	
	return 0;
	}


numeric function getForecastThisDay(required date FilterDateTime, string mode='nobot') output="false" access="remote" {
	if (dayofyear(arguments.FilterDateTime) < dayofyear(now()))
		return this.getHitsthisDay(arguments.FilterDateTime, arguments.mode);
	else if (val(hour(arguments.FilterDateTime)))
		return round(24/hour(arguments.FilterDateTime) * this.getHitsthisday(arguments.FilterDateTime, arguments.mode));
	
	
	return 0;
	}



numeric function getForecastThisMonth(required date FilterDateTime, string mode='nobot') output="false" access="remote" {
	if (dayofyear(arguments.FilterDateTime) < dayofyear(now()))
		return arguments.getHitsthisMonth(arguments.FilterDateTime, arguments.mode);
	else if (val(day(arguments.FilterDateTime)))
		return round(daysinmonth(arguments.FilterDateTime)/day(arguments.FilterDateTime) * this.getHitsthismonth(arguments.FilterDateTime, arguments.mode));

	
	return 0;
	}
	
	
numeric function getForecastUsersThisHour(required date FilterDateTime) output="false" access="remote" {
	if (dayofyear(arguments.FilterDateTime) < dayofyear(now()))
		return this.getUsersthishour(arguments.FilterDateTime);
	else if (val(minute(arguments.FilterDateTime)))
		return round(60/minute(arguments.FilterDateTime) * this.getUsersthishour(arguments.FilterDateTime));
	
	return 0;
	}


numeric function getForecastUsersThisDay(required date FilterDateTime) output="false" access="remote" {
	if (dayofyear(arguments.FilterDateTime) < dayofyear(now()))
		return this.getUsersthisDay(arguments.FilterDateTime);
	else if (val(hour(arguments.FilterDateTime)))
		return round(24/hour(arguments.FilterDateTime) * this.getUsersthisday(arguments.FilterDateTime));
	
	return 0;
	}


numeric function getForecastUsersThisMonth(required date FilterDateTime) output="false" access="remote" {
	if (dayofyear(arguments.FilterDateTime) lt dayofyear(now()))
		return this.getUsersthisMonth(arguments.FilterDateTime);
	else if (val(day(arguments.FilterDateTime)))
		return round(daysinmonth(arguments.FilterDateTime)/day(arguments.FilterDateTime) * this.getUsersthismonth(arguments.FilterDateTime));
	
	return 0;
	}	
	
</cfscript>

<!--- Users --->
<cffunction name="getUsersThisHour" output="false" returntype="numeric" access="remote">
	<cfargument name="filterDateTime" required="true" type="date">

	<cfquery name="qryhour">
		SELECT 	COUNT(DISTINCT remote_addr) AS thecount
		FROM	dbo.Traffic
		WHERE 	CreateDate > #dateadd("n",-minute(arguments.FilterDateTime) - 1, arguments.FilterDateTime)#
		AND 	CreateDate < #dateadd("n",-minute(arguments.FilterDateTime) + 60,arguments.FilterDateTime)#
	</cfquery>
	
	<cfreturn qryHour.thecount>
</cffunction>

<cffunction name="getUsersThisDay" output="false" returntype="numeric" access="remote">
	<cfargument name="filterDateTime" required="true" type="date">

	<cfquery name="qryday">
		select 	COUNT(DISTINCT remote_addr) as thecount
		from 	dbo.Traffic
		where 	CreateDate > #createodbcdate(dateadd("h",-hour(arguments.FilterDateTime), arguments.FilterDateTime))#
		and		CreateDate < #createodbcdate(dateadd("h",-hour(arguments.FilterDateTime)+ 24,arguments.FilterDateTime))#
	</cfquery>
	
	<cfreturn qryDay.thecount>
</cffunction>


<cffunction name="getUsersThisMonth" output="false" returntype="numeric"  access="remote">
	<cfargument name="filterDateTime" required="true" type="date">

	<cfquery name="qrymonth">
		select 	count(DISTINCT remote_addr) AS thecount
		from 	dbo.Traffic
		where	CreateDate > #createodbcdate(dateadd("d",-day(arguments.FilterDateTime), arguments.FilterDateTime))#
		and 	CreateDate < #createodbcdate(dateadd("d",-day(arguments.FilterDateTime)+daysinmonth(arguments.FilterDateTime)+1, arguments.FilterDateTime))#
	</cfquery>
	
	<cfreturn qryMonth.thecount>
</cffunction>




<!--------------------------------
Data for the Filter menu
---------------------------------->

<cffunction name="getSection" access="remote" output="false" returntype="query">

	<cfset var qrySection = "">

	<cfquery name="qrySection" cachedwithin="#createtimespan(0,1,0,0)#">
		select distinct section
		FROM 	dbo.Traffic
		WHERE	CreateDate > DateAdd(d, -90, getDate()) <!--- Aging and scalabilty --->
		order by Section
	</cfquery>
	
	<cfreturn qrySection>
</cffunction>


<cffunction name="getItem" access="remote" output="false" returntype="query">
	<cfargument name="FilterSection" required="true" type="string">

	<cfset var qryItem = "">
		
	<cfquery name="qryItem" cachedwithin="#createtimespan(0,0,10,0)#">
		select DISTINCT Item
		FROM 	dbo.Traffic
		WHERE	Section = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.FilterSection#">
		AND		CreateDate > DateAdd(d, -90, getDate()) <!--- Aging and scalabilty --->
		order by Item
	</cfquery>


	<cfreturn qryItem>
</cffunction> 


<cffunction name="getLastHits" access="remote" output="false" returntype="query">
	<cfargument name="mode" required="true" type="string">

	<cfset var smallServerName = replacelist(cgi.servername, 'www.', '')>


	<cfquery name="qryLastHits">
		SELECT TOP 20 CreateDate, Section, Item, Search, Tag, OS, Browser, agent, Referer
		FROM 	dbo.Traffic
		WHERE	1 = 1
		<cfswitch expression="#arguments.mode#">
		<cfcase value="bot">
			AND	Browser LIKE '%bot%'
		</cfcase>	
		<cfcase value="search">
			AND	Search IS NOT NULL
		</cfcase>
		
		<cfcase value="referer">
			AND	Referer IS NOT NULL
			AND	NOT Referer LIKE <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="%#smallServerName#%">
		</cfcase>
		
		<cfdefaultcase>
			AND	NOT Browser LIKE '%bot%'
		</cfdefaultcase>
		</cfswitch>
						
		ORDER BY CreateDate DESC
	</cfquery> 

	
	<cfreturn qryLastHits>
</cffunction> 


</cfcomponent>

