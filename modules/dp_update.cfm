<cfscript>

util = createObject("component", "Util");

global = new lib.cfmumps.Global("geodigraph", ["processes", url.distributedProcessId]);
process = global.getObject();

mumps = new lib.cfmumps.Mumps();
mumps.open();

switch(url.newState) {
    case 0: 
        newStatus = "DP_WAITNODE";
        statStr = "waiting in the processing queue";
        statSum = "Layer waiting for processing";
        icon = "fa-clock";
        break;
    case 1:
        newStatus = "DP_PROCESSING";
        statStr = "processing on node " & process.node;
        statSum = "Layer is processing on " & process.node;
        icon = "fa-spinner";
        break;
    case 3:
        newStatus = "DP_COMPLETE";
        statStr = "finished processing";
        statSum = "Layer completed processing";
        icon = "fa-check";
        mumps.set("geodigraph", ["layers", process.layerId, "ready"], 1);
        break;
    case 2:
        newStatus = "DP_FAILED";
        statStr = "had an unrecoverable error in processing, likely due to a corrupt or invalid file";
        statSum = "Layer failed to process";
        icon = "fa-exclamation-triangle";
        break;
}

mumps.set("geodigraph", ["processes", url.distributedProcessId, "status"], newStatus);
mumps.set("geodigraph", ["processes", url.distributedProcessId, "statusMessage"], statSum);

layer = util.getLayerObject(process.layerId);

if(newStatus == "DP_COMPLETE" && layer.renderer == "geotiff") {

 
    layerOwner = new Account(layer.contributor);

    dirSize = util.dirSize(expandPath("/pool/tiles/#layer.id#")) * 1024;

    tokensNeeded = util.bytesToTokens(dirSize);
    mumps.set("geodigraph", ["layers", layer.id, "tileTokens"], tokensNeeded);

    tokensAvailable = layerOwner.getTokensFree(); 

    if(tokensNeeded > tokensAvailable) {
        overbook = tokensNeeded - tokensAvailable;

        layerOwner.allocateTokens(tokensAvailable);
        layerOwner.overbook(overbook);
    }
    else {
        layerOwner.allocateTokens(tokensNeeded);
    }

}

var notification = new Notification({
    caption: statSum,
    message: "Layer #layer.name# #statStr#",
    icon: icon,
    link: "https://maps.geodigraph.com/default.cfm?showLayer=#layer.id#"
});

for(user in layer.getNotifyTargets()) {
    notification.send(user);
    user.setUiRefresh();
}

mumps.close();

if(newStatus == "DP_FAILED") {
    layer.delete();
}

</cfscript>