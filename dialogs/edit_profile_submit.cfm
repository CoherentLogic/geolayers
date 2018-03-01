<cfheader name="Content-Type" value="application/json">
<cfscript>

    try {
        oldPicture = session.account.picture;
        deleteError = "";
        try {
            
            fileDelete(expandPath(oldPicture));
        }
        catch (any ex) {
            deleteError = ex.message;
        }

        rawFilename = "/pool/profiles/#createUUID()#.jpg";
        filename = expandPath(rawFilename);
        fileUpload(filename, "file", "*", "overwrite");
    
        mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["accounts", session.account.email, "picture"], rawFilename);
        session.account.picture = rawFilename;

        mumps.close();

        o = {
            success: true,
            message: "",
            filename: filename,
            newPicture: rawFilename            
        };
    }
    catch (any ex) {
        o = {
            success: false,
            message: ex.message
        };
    }      

    writeOutput(serializeJSON(o));
</cfscript>
