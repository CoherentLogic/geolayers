<cfheader name="Content-Type" value="application/json">
<cfset companies=listCompanies()>
<cfoutput>#serializeJSON(companies)#</cfoutput>