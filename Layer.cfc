component displayname="Layer" {

    public Layer function init(required string id, struct opts) output=false
    {
        this.id = arguments.id;
        this.subs = ["layers", this.id];
        this.global = new lib.cfmumps.Global("geodigraph", this.subs);

        this.extensions = {};

        if(this.global.defined().hasSubscripts) {

            // bomb out if the layer is in the database and the user
            // is attempting to create a new one with the same ID
            if(isDefined("arguments.opts")) {
                throw(type="LayerExists", message="Attempting to create a layer that already exists");
            }

            // the layer is defined in the DB
            var global = new lib.cfmumps.Global("geodigraph", this.subs);
            var l = global.getObject();

            this.name = l.name;
            this.attribution = l.attribution;
            this.contributor = l.contributor;
            this.copyright = l.copyright;
            this.maxZoom = l.maxZoom;
            this.minZoom = l.minZoom;
            this.ready = l.ready;
            this.renderer = l.renderer;
            this.timestamp = l.timestamp;            
        }
        else {
            // layer not defined; instantiate myself from arguments.opts
            this.timestamp = now();

            if(isDefined("arguments.opts")) {
                this.attribution = opts.attribution;
                this.contributor = opts.contributor;
                this.copyright = opts.copyright;
                this.maxZoom = opts.maxZoom;
                this.minZoom = opts.minZoom;
                this.ready = opts.ready;
                this.renderer = opts.renderer;
                this.name = opts.name;
            }
            else {
                this.attribution = ""
                this.contributor = "";
                this.copyright = "";
                this.maxZoom = 17;
                this.minZoom = 23;
                this.ready = 0;
                this.renderer = "base";       
                this.name = "";         
            }

            this.save();
        }

        return this;
    }

    public void function addStringAttribute(required string key, required string value)
    {
        this.extensions[arguments.key] = arguments.value;
    }

    public void function addNumericAttribute(required string key, required number value)
    {
        this.extensions[arguments.key] = arguments.value;
    }

    public string function getAttribution()
    {
        return this.attribution;
    }

    public void function setAttribution(required string value)
    {
        this.attribution = arguments.value;
    }

    public string function getContributor()
    {
        return this.contributor;
    }

    public void function setContributor(required string value)
    {
        this.contributor = arguments.value;
    }

    public string function getCopyright()
    {
        return this.copyright;
    }

    public void function setCopyright(required string value)
    {
        this.copyright = arguments.value;
    }


    public struct function getZoom()
    {
        return {
            minimum: this.minZoom,
            maximum: this.maxZoom
        };
    }

    public void function setZoom(required struct zoom)
    {
        this.minZoom = zoom.minimum;
        this.maxZoom = zoom.maximum;
    }

    public boolean function isReady()
    {
        if(this.ready == 0) {
            return false;
        }
        else {
            return true;
        }
    }

    public boolean function save()
    {
        try {
            this.global.setObject(this.toStruct());
            return true;
        }
        catch(any ex) {
            return false;
        }
    }

    public struct function toStruct()
    {
        var outputStruct = {
            contributor: this.contributor,
            timestamp: this.timestamp,
            attribution: this.attribution,
            copyright: this.copyright,
            maxZoom: this.maxZoom,
            minZoom: this.minZoom,
            ready: this.ready,
            renderer: this.renderer,
            name: this.name
        };

        outputStruct.append(this.extensions);

        return outputStruct;
    }

    public string function toJson()
    {
        return serializeJSON(this.toStruct());
    }

    public void function grantGlobalAccess()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["permissions", "layer", "global", this.id], 1);

        mumps.close();
    }

    public void function revokeGlobalAccess()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.kill("geodigraph", ["permissions", "layer", "global", this.id]);

        mumps.close();
    }

    public void function grantCompanyAccess(required Company company)
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["permissions", "layer", "company", arguments.company.name, this.id], 1);

        mumps.close();
    }

    public void function revokeCompanyAccess(required Company company)
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.kill("geodigraph", ["permissions", "layer", "company", arguments.company.name, this.id]);

        mumps.close();
    }

    public void function grantUserAccess(required Account user)
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["permissions", "layer", "user", arguments.user.email, this.id], 1);

        mumps.close();
    }

    public void function revokeUserAccess(required Account user)
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.kill("geodigraph", ["permissions", "layer", "user", arguments.user.email, this.id]);

        mumps.close();
    }

    public void function addNotifyTarget(required Account user)
    {
        var global = new lib.cfmumps.Global("geodigraph", ["notifyTargets", this.id, arguments.user.email]);

        global.value("");

        global.close();
    }

    public void function removeNotifyTarget(required Account user)
    {
        var global = new lib.cfmumps.Global("geodigraph", ["notifyTargets", this.id, arguments.user.email]);

        global.delete();

        global.close();
    }

    public void function share(required Account user, required boolean enabled, required number zIndex, required number opacity)
    {
        var global = new lib.cfmumps.Global("geodigraph", ["accounts", arguments.user.email, "layers", this.id]);

        var en = 0;
        if(arguments.enabled) {
            en = 1;
        }

        global.setObject({
            enabled: en,
            zIndex: arguments.zIndex,
            opacity: arguments.opacity 
        });

        global.close();

        var notification = new Notification({
            caption: "A layer has been shared",
            message: arguments.user.getFullName() & " has shared a new base layer, " & this.name & ", with you.",
            link: "https://maps.geodigraph.com/default.cfm?showLayer=#this.id#",
            icon: "fa-map"
        });

        notification.send(arguments.user);

        this.grantUserAccess(arguments.user);
        this.addNotifyTarget(arguments.user);

        arguments.user.setUiRefresh();
    }

    public void function unshare(required Account user)
    {
        var global = new lib.cfmumps.Global("geodigraph", ["accounts", arguments.user.email, "layers", this.id]);
        global.delete();

        this.revokeUserAccess(arguments.user);
        this.removeNotifyTarget(arguments.user);
    
        arguments.user.setUiRefresh();
    }

    public void function setAsDefault()
    {
        mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["defaultLayers", this.id], "");

        mumps.close();
    }

    public void function clearAsDefault()
    {
        mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.kill("geodigraph", ["defaultLayers", arguments.layerId]);

        mumps.close();
    }

}