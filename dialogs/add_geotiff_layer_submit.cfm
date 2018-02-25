<cfscript>

    layer = new GeotiffLayer(form.geoTiffLayerId, {
        name: form.geoTiffLayerName,
        minZoom: form.geoTiffMinZoom,
        maxZoom: form.geoTiffMaxZoom,
        attribution: form.geoTiffAttribution,
        copyright: form.geoTiffCopyright,
        contributor: session.account.email
    });

    layer.grantUserAccess(session.account);
    layer.share(session.account, true, 2, 50);                      

    filename = "/home/geodigraph/webapps/maps/pool/inbound/staging/#layer.id#.tif";
    fileUpload(filename, "geoTiffFile");

    args = "-f #filename# -i #layer.id# -m #layer.minZoom# -M #layer.maxZoom#";
    
    layer.postProcess("maketiles", args, "Conversion of GeoTIFF to tiles for layer #layer.name#");

</cfscript>
