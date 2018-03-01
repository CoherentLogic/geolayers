<cfheader name="Content-Type" value="application/json">
<cfscript>

    try {

        layer = new GeotiffLayer(form.geoTiffLayerId, {
            name: form.geoTiffLayerName,
            minZoom: form.geoTiffMinZoom,
            maxZoom: form.geoTiffMaxZoom,
            attribution: form.geoTiffAttribution,
            copyright: form.geoTiffCopyright,
            contributor: session.account.email
        });

        layer.addToAccount(session.account, true, 2, 50);                      

        filename = "/home/geodigraph/webapps/maps/pool/inbound/staging/#layer.id#.tif";
        fileUpload(filename, "file");

        args = "-f #filename# -i #layer.id# -m #layer.minZoom# -M #layer.maxZoom#";
        
        layer.postProcess("maketiles", args, "Conversion of GeoTIFF to tiles for layer #layer.name#");

        o = {
            success: true,
            message: "",
            fields: form
        };
    }
    catch (any ex) {
        o = {
            success: false,
            message: ex.message,
            fields: form
        };
    }

    writeOutput(serializeJSON(o));

</cfscript>
