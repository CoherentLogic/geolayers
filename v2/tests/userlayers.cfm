<cfscript>
    userLayers = getAccessibleLayers(session.email);

    for(layer in userLayers) {
        writeOutput(layer);
    }
</cfscript>
