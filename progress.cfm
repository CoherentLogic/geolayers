<cfheader name="Content-Type" value="application/json">

<cfscript>
    customerId = url.customerid;
    layerId = url.layerid;

    basePath = "/var/gis/users/geolayers/geolayers/repo/" & customerId & "/" & layerId & "/";

    statFile = basePath & "STAT.GL8";
    startFile = basePath & "START.GL8";

    if(fileExists(statFile)) {
        status = fileRead(statFile);
    }
    else {
        status = "Uploading";
    }

    if(fileExists(startFile)) {
        startTime = fileRead(startFile);
    }
    else {
        startTime = now();
    }

    outStruct = {
        status: status,
        startTime: startTime,
        layerId: layerId
    };

    writeOutput(serializeJSON(outStruct));
</cfscript>