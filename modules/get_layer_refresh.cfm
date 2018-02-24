<cfheader name="Content-Type" value="application/json">
<cfscript>
writeOutput(serializeJSON({
    layerRefresh: session.account.getUiRefresh()
}));

session.account.clearUiRefresh();
var mumps = new lib.cfmumps.Mumps();
mumps.open();

mumps.kill("geodigraph", ["accounts", session.account.email, "layerRefresh"]);
</cfscript>