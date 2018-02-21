<cfheader name="Content-Type" value="application/json">
<cfscript>
writeOutput(serializeJSON({
    layerRefresh: session.account.getUiRefresh()
}));

session.account.clearUiRefresh();
</cfscript>