/*
 * GeotiffLayer: Extends the Layer class for methods specific
 * to GeoTIFF layers
 */
component displayname="GeotiffLayer" extends="Layer" {

    public GeotiffLayer function init(required string id, struct opts) output=false
    {
        // Invoke the superclass constructor so that we can use 
        // its methods.
        if(isDefined("arguments.opts")) {

            // GeotiffLayers are always renderer == 'geotiff'
            arguments.opts.renderer = 'geotiff';

            // GeotiffLayers always begin their lifecycle as ready == 0
            arguments.opts.ready = 0;

            super.init(arguments.id, arguments.opts);
        }
        else {
            super.init(arguments.id);

            var mumps = new lib.cfmumps.Mumps();
            mumps.open(); 

            super.addStringAttribute("processorId", mumps.get("geodigraph", ["layers", arguments.id, "processorId"]));

            mumps.close();
            
            var tileTokens = mumps.get("geodigraph", ["layers", arguments.id, "tileTokens"]);
            var imageTokens = mumps.get("geodigraph", ["layers", arguments.id, "imageTokens"]);


            if(tileTokens == "") tileTokens = 0;
            if(imageTokens == "") imageTokens = 0;

            super.addNumericAttribute("tileTokens", tileTokens);
            super.addNumericAttribute("imageTokens", imageTokens);

            try {
                var xmlDoc = xmlParse(fileRead("/pool/tiles/#arguments.id#/tilemapresource.xml"));
                var bbox = xmlDoc.TileMap.BoundingBox.XmlAttributes;

                super.addStringAttribute("maxx", bbox.maxx);
                super.addStringAttribute("maxy", bbox.maxy);
                super.addStringAttribute("minx", bbox.minx);
                super.addStringAttribute("miny", bbox.miny);
                super.addStringAttribute("srs", xmlDoc.TileMap.SRS.XmlText);
            }
            catch (any ex) {
                writeLog(ex.message);
            }   
            
        }

        return this;
    }

    public string function getStatus()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        if(isDefined("this.extensions.processorId")) {
            if(this.extensions.processorId != "") {
                var status = mumps.get("geodigraph", ["processes", this.extensions.processorId, "statusMessage"]);
            }
            else {
                var status = "";
            }
        }
        else {
            var status = "";
        }

        return status;
    }

    public void function delete()
    {
        try {
            var mumps = new lib.cfmumps.Mumps();
            mumps.open();

            var imageTokens = mumps.get("geodigraph", ["layers", this.id, "imageTokens"]);
            var tileTokens = mumps.get("geodigraph", ["layers", this.id, "tileTokens"]);

            mumps.close();

            var owner = super.getOwner();

            owner.deallocateTokens(imageTokens + tileTokens);

            fileDelete(expandPath("/pool/inbound/staging/#this.id#.tif"));
            directoryDelete(expandPath("/pool/tiles/#this.id#"), true);
        }
        catch (any ex) {
            writeLog(ex.message);
        }

        super.delete();
    }

}