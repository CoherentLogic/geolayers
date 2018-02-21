component displayname="Util" {

    public string function friendlyDate(required datetime t)
    {
        n = now();

        if(datediff("s", t, n) < 60) {
            return "A few seconds ago";
        }

        if(datediff("n", t, n) >= 1 && datediff("n", t, n) <= 50) {
            return datediff("n", t, n) & " minutes ago";
        }

        if(datediff("n", t, n) > 50 && datediff("n", t, n) < 80) {
            return "About an hour ago";
        }

        if(datediff("h", t, n) > 1 && datediff("h", t, n) < 24) {
            return datediff("h", t, n) & " hours ago";
        }

        if(datediff("h", t, n) >= 24 && datediff("h", t, n) < 48) {
            return "Yesterday";
        }

        if(datediff("d", t, n) > 1) {
            return datediff("d", t, n) & " days ago";
        }
    }

    public component function getLayerObject(required string layerId) {

        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var renderer = mumps.get("geodigraph", ["layers", arguments.layerId, "renderer"]);

        mumps.close();

        switch(renderer) {
            case 'base':
            return new BaseLayer(arguments.layerId);                    
            case 'geotiff':
            return new GeotiffLayer(arguments.layerId);                 
            case 'parcel':
            throw("Not yet implemented");

        }

    }
}