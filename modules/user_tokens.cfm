<cfheader name="Content-Type" value="application/json">
<cfscript>
o = {
    success: true,
    message: "",
    tokensAllocated: session.account.getTokensAllocated(),
    tokensTotal: session.account.getTokenPool(),
    tokensOverbooked: session.account.getTokensOverbooked()    
};

writeOutput(serializeJSON(o));
</cfscript>