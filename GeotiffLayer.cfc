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
        }

        return this;
    }
}