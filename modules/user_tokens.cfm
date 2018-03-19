<cfheader name="Content-Type" value="application/json">
<cfscript>

if(isDefined("session.account.getTokensAllocated")) {
    o = {
        success: true,
        message: "",
        tokensAllocated: session.account.getTokensAllocated(),
        tokensTotal: session.account.getTokenPool(),
        tokensOverbooked: session.account.getTokensOverbooked()    
    };
}
else {
    o = {
        success: false,
        message: "Not logged in"
    };
}


writeOutput(serializeJSON(o));
</cfscript>