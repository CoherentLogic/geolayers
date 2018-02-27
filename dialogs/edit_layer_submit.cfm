<cfheader name="Content-Type" value="application/json">
<cfscript>

util = createObject("component", "Util");
layer = Util.getLayerObject(url.layerId);

if((session.account.admin == true) || (layer.contributor == session.account.email)) {

    try {
        glob = new lib.cfmumps.Global("geodigraph", ["layers", url.layerId]);

        o = {
            copyright: url.copyright,
            attribution: url.attribution,
            name: url.name
        };

        glob.setObject(o);
        glob.close();

        out = {
            success: true,
            message: "",
            newAttributes: o
        };

        session.account.setUiRefresh();
    }
    catch (any ex) {
        out = {
            success: false,
            message: ex.message
        };
    }
}
else {
    out = {
        success: false,
        message: "You are neither the owner of this layer nor the site administrator."
    };
}

writeOutput(serializeJSON(out));
</cfscript>