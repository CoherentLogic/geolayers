<cfset userCompanies=getUserCompanies(session.email)>

<cfscript>
for(company in userCompanies) {
    writeOutput(company);
}
</cfscript>