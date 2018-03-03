<cfheader name="Content-Type" value="application/json">
<cfscript>
u = new Util();

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

        filename = expandPath("/pool/inbound/staging/#layer.id#.tif");

        fileUpload(filename, "file");

        tokensNeeded = u.bytesToTokens(getFileInfo(filename).Size);
        tokensAvailable = session.account.getTokensFree();

        if(tokensNeeded < tokensAvailable) {
            try {
                session.account.allocateTokens(tokensNeeded);

                mumps = new lib.cfmumps.Mumps();
                mumps.open();
                mumps.set("geodigraph", ["layers", layer.id, "tokens"], tokensNeeded);
            }
            catch (any ex) {
                layer.delete();
                fileDelete(filename);
                session.account.setUiRefresh();
                throw("Could not allocate tokens: " & ex.message);
            }
        }
        else {
            layer.delete();
            fileDelete(filename);
            session.account.setUiRefresh();

            throw("You need #tokensNeeded# tokens in order to upload this file, but you only have #tokensAvailable# available.<br><br>Please purchase at least #tokensNeeded - tokensAvailable# token(s) and try again.");
        }

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
