<cfscript>
    failure = false;
    if(url.failed > 0) {
        failure = true;
    }
    completeLayer(url.layerid, failure);
</cfscript>