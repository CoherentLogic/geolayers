/*
 * BaseLayer: Extends the Layer class for methods specific
 * to Base layers
 */
component displayname="BaseLayer" extends="Layer" {

    public BaseLayer function init(required string id, struct opts) output=false
    {
        // Invoke the superclass constructor so that we can use 
        // its methods
        if(isDefined("arguments.opts")) {

            // Base layers are always renderer = 'base'
            arguments.opts.renderer = 'base';

            // Base layers are always ready
            arguments.opts.ready = 1;

            if(!isDefined("arguments.opts.url")) {
                throw("Must supply URL property.");
            }

            super.init(arguments.id, arguments.opts);
            super.addStringAttribute("url", arguments.opts.url);
            super.save();
        }
        else {            
            super.init(arguments.id);      

            var mumps = new lib.cfmumps.Mumps();
            mumps.open(); 

            super.addStringAttribute("url", mumps.get("geodigraph", ["layers", arguments.id, "url"]));
            
            mumps.close();  
        }

        return this;
    }



}