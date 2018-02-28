<cfheader name="Content-Type" value="application/json">
<cfscript>
o = {};

try {
    if(!session.account.admin) {
        throw("Must be an administrator in order to establish default layers");
    }

    util = createObject("component", "Util");

    layer = Util.getLayerObject(url.layerId);

    if(url.default == 1) {
        layer.setAsDefault();
        o = {
            success: true,
            message: "Layer is now a default layer"
        };
    }
    else {
        layer.clearAsDefault();
        o = {
            success: true,
            message: "Layer is no longer a default layer"
        };
    }
}
catch (any ex) {
    o = {
        success: false,
        message: ex.message
    };
}

writeOutput(serializeJSON(o));
</cfscript>