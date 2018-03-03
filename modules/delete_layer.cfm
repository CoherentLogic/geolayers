<cfheader name="Content-Type" value="application/json">
<cfscript>
util = new Util();

layer = util.getLayerObject(url.id);

if((!session.account.admin) || (session.account.email != layer.contributor)) {
    o = {
        success: false,
        message: "Must be administrator or layer owner to delete a layer."
    };
}
else {
    layer.delete();

    o = {
        succes: true,
        message: "Layer deleted."
    };
}

writeOutput(serializeJSON(o));
</cfscript>