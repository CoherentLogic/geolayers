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

            // Make sure arguments.opts.renderer is 'geotiff'
            // to match this subclass of Layer
            arguments.opts.renderer = 'geotiff';
            arguments.opts.ready = 0;

            super.init(arguments.id, arguments.opts);
        }
        else {
            super.init(arguments.id);
        }

        return this;
    }

    public void function upload(required string file) output=false
    {

    }

}