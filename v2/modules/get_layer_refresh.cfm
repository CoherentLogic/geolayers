<cfheader name="Content-Type" value="application/json">
<cfscript>
mumps = new lib.cfmumps.Mumps();
mumps.open();

o = {};

layerRefresh = mumps.get("geodigraph", ["accounts", session.email, "layerRefresh"]);

mumps.close();

if(layerRefresh > 0) {
    o.layerRefresh = true;
}
else {
    o.layerRefresh = false;
}

writeOutput(serializeJSON(o));

clearLayerRefresh(session.email);
</cfscript>