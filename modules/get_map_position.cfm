<cfheader name="Content-Type" value="application/json">
<cfscript>
global = new lib.cfmumps.Global("geodigraph", ["accounts", session.email, "mapPosition"]);
writeOutput(serializeJSON(global.getObject()));
writeLog("FORK!");
</cfscript>