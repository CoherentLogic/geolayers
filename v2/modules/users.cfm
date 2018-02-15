<cfheader name="Content-Type" value="application/json">
<cfset users=listUsers()>
<cfoutput>#serializeJSON(users)#</cfoutput>