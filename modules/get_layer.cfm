<cfheader name="Content-Type" value="application/json">
<cfscript>
util = createObject("component", "Util");

layer = Util.getLayerObject(url.layerId);

if((session.account.admin == true) || (layer.contributor == session.account.email)) {
    o = {
        success: true,
        message: "",
        shares: layer.getShares(),
        name: layer.name,
        attribution: layer.attribution,
        copyright: layer.copyright,
    };

    if(layer.renderer == "geotiff") {
        o.originalImage = "/pool/raw/#url.layerId#.tif"; 
    }
}
else {
    o = {
        success: false,
        message: "Not layer owner or site administrator"
    };
}

writeOutput(serializeJSON(o));

</cfscript>