
<cfheader name="Content-Type" value="application/json">
<cfscript>
notifications = listNotifications();

writeOutput(serializeJSON(notifications));
</cfscript>

