component displayname=Account output=false extends="Util" {

    public Account function init(string email) output=false
    {
        this.firstName = "";
        this.lastName = "";
        this.company = "";
        this.passwordHash = "";
        this.picture = "";
        this.zip = "";
        this.admin = false;
        this.companies = [];
        this.verified = false;
        this.verificationCode = createUUID();

        this.saved = false;

        if(isDefined("arguments.email")) {
            this.open(arguments.email);
        }

        return this;
    }


    public Account function open(required string email) output=false
    {
        
        var glob = new lib.cfmumps.Global("geodigraph", ["accounts", email]);

        var a = glob.getObject();

        if(!glob.defined().defined) {
            throw(type="InvalidAccount", message="User account does not exist");
        }

        this.firstName = a.firstName;
        this.lastName = a.lastName;
        this.company = a.company;
        this.companies = a.companies;
        this.passwordHash = a.passwordHash;
        this.picture = a.picture;
        this.zip = a.zip;
        this.verificationCode = a.verificationCode;

        if(a.verified == 1) {
            this.verified = true;
        } 
        else {
            this.verified = false;
        }

        if(a.admin == 1) {
            this.admin = true;
        }
        else {
            this.admin = false;
        }

        this.email = email;


        return this;
    }

    public Account function save() output=false
    {
        var existingAccounts = new lib.cfmumps.Global("geodigraph", ["accounts"]).defined().defined;

        var glob = new lib.cfmumps.Global("geodigraph", ["accounts", this.email]);
        
        if(glob.defined().defined) {
            throw(type="AccountExists", message="User account already exists");
        }

        if(existingAccounts == false && this.admin == 0) {
            this.admin = 1;
        }
        else {
            this.admin = 0;
        }

        var verified = 0;
        if(this.verified == true) {
            verified = 1;
        }

        accountStruct = {
            firstName: this.firstName,
            lastName: this.lastName,          
            passwordHash: this.passwordHash,
            picture: this.picture,
            zip: this.zip,
            admin: this.admin,
            verificationCode: this.verificationCode,
            verified: verified
        };


        glob.setObject(accountStruct);

        module template="/modules/send_email.cfm" caption="Please verify your e-mail address" message="Please click on the link to verify your e-mail address." link="https://maps.geodigraph.com/verify.cfm?email=#this.email#&code=#this.verificationCode#" recipient=this.email;


        this.saved = true;

        return this;
    }

    public string function getFullName()
    {
        return "#this.firstName# #this.lastName#";
    }

    public Account function setPassword(required string password) output=false
    {
        this.passwordHash = hash(password, "SHA-256");

        return this;
    }

     public void function saveSessionId()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["accounts", this.email, "sessions", session.sessionID, "flags", "uiRefresh"], 0);

        mumps.close();
    }

    public void function setUiRefresh()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open(); 

        var lastResult = false;
        var sessId = "";

        while(lastResult == false) {
            order = mumps.order("geodigraph", ["accounts", this.email, "sessions", sessId]);
            lastResult = order.lastResult;
            sessId = order.value;

            if(sessId != "") {
                 mumps.set("geodigraph", ["accounts", this.email, "sessions", sessId, "flags", "uiRefresh"], 1);
            }
        }

        mumps.close();
    }

    public void function clearUiRefresh()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        mumps.set("geodigraph", ["accounts", this.email, "sessions", session.sessionID, "flags", "uiRefresh"], 0);

        mumps.close();
    }

    public boolean function getUiRefresh()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var refresh = mumps.get("geodigraph", ["accounts", session.email, "sessions", session.sessionID, "flags", "uiRefresh"]);

        mumps.close();
        
        if(refresh > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    public void function addDefaultLayers()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var layers = [];

        var lastResult = false;
        var layerId = "";

        while(lastResult == false) {
            var order = mumps.order("geodigraph", ["defaultLayers", layerId]);
            lastResult = order.lastResult;
            layerId = order.value;

            if(layerId != "") {
                var layer = getLayerObject(layerId);

                switch(layer.renderer) {
                    case 'base':
                    opacity = 100;
                    zIndex = 0;                         
                    break;
                    case 'geotiff':
                    opacity = 50;
                    zIndex = 1;
                    break;                          
                    case 'parcel':                      
                    opacity = 50;
                    zIndex = 2;
                    break;
                }

                layer.share(this, true, zIndex, opacity);

            }
        }

        mumps.close();
    }

   

    public struct function layers()
    {        
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var layers = {};

        var lastResult = false;
        var layerId = "";

        while(lastResult == false) {
            order = mumps.order("geodigraph", ["accounts", this.email, "layers", layerId]);
            lastResult = order.lastResult;
            layerId = order.value;
        

            if(layerId != "") {
               
                var layerObj = getLayerObject(layerId);

                
                global = new lib.cfmumps.Global("geodigraph", ["accounts", this.email, "layers", layerId]);

                layer = {
                    object: layerObj,
                    layer: layerObj.toStruct(),
                    properties: global.getObject()
                };

                layers[layerId] = layer;

            }
        }

        mumps.close();
        return layers;
    }


}