<cfheader name="Content-Type" value="application/json">
<cfscript>
util = createObject("component", "Util");

layer = Util.getLayerObject(url.layerId);

if((session.account.admin == true) || (layer.contributor == session.account.email)) {

    try {
        layer.unshare(new Account(url.email));

        o = {
            success: true,
            message: ""
        };
    }
    catch (any ex) {
        o = {
            success: false,
            message: ex.message
        };
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