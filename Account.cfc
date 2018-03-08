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
        this.uploadsEnabled = true;
        this.tokensOverbooked = 0;

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
        //this.companies = a.companies;
        this.passwordHash = a.passwordHash;

        if(a.picture != "") {
            this.picture = a.picture;
        }
        else {
            this.picture = "/img/placeholder.png";
        }
        
        this.zip = a.zip;
        this.verificationCode = a.verificationCode;
        this.tokensOverbooked = a.tokensOverbooked;

        if(a.uploadsEnabled == 0) {
            this.uploadsEnabled = false;
        } 
        else {
            this.uploadsEnabled = true;
        }

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

    public numeric function getTokenPool()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var t = mumps.get("geodigraph", ["accounts", this.email, "tokenPool"]);

        mumps.close();

        return t;
    }

    public numeric function getTokensAllocated()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var t = mumps.get("geodigraph", ["accounts", this.email, "tokensAllocated"]);

        mumps.close();

        return t;
    }

    public numeric function getTokensOverbooked()
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var t = mumps.get("geodigraph", ["accounts", this.email, "tokensOverbooked"]);

        mumps.close();

        return t;       
    }

    public numeric function getTokensFree()
    {
        return this.getTokenPool() - this.getTokensAllocated();
    }

    public void function expandTokenPool(required number tokensRequested)
    {
        var auditAction = "expandTokenPool_" & createUUID();

        audit(auditAction, "BEGIN expanding token pool for #this.email# by #arguments.tokensRequested#");

        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        lock scope="Application" timeout="10" {
            if(mumps.lock("geodigraph", ["tokensAllocated"], 10)) {
                var systemTokenPool = mumps.get("geodigraph", ["tokenPool"]);
                var systemTokensAllocated = mumps.get("geodigraph", ["tokensAllocated"]);
                var systemTokensAvailable = systemTokenPool - systemTokensAllocated;
                var userTokensOverbooked = this.getTokensOverbooked();

                if(arguments.tokensRequested > systemTokensAvailable) {
                    audit(auditAction, "FAIL expanding token pool for #this.email# by #arguments.tokensRequested#; system token pool exhausted");

                    mumps.unlock("geodigraph", ["tokensAllocated"]);
                    mumps.close();
                    throw("System token pool exhausted");
                }

                systemTokensAllocated += arguments.tokensRequested;

                mumps.set("geodigraph", ["tokensAllocated"], systemTokensAllocated);
                
                if(mumps.lock("geodigraph", ["accounts", this.email, "tokenPool"], 10)) {
                    var userTokens = this.getTokenPool();
                    userTokens += arguments.tokensRequested;
                    

                    if(userTokensOverbooked > 0) {
                        userTokensOverbooked -= arguments.tokensRequested;
                    
                        if(userTokensOverbooked < 0) {
                            userTokensOverbooked = 0;
                        }

                        mumps.set("geodigraph", ["accounts", this.email, "tokensOverbooked"], userTokensOverbooked);
                    }

                    if(userTokensOverbooked == 0) {
                        mumps.set("geodigraph", ["accounts", this.email, "uploadsEnabled"], 1);
                    }

                    audit(auditAction, "SUCCESS expanding token pool for #this.email# by #arguments.tokensRequested#");

                    mumps.set("geodigraph", ["accounts", this.email, "tokenPool"], userTokens);
                }
                else {
                    audit(auditAction, "FAIL expanding token pool for #this.email# by #arguments.tokensRequested#; unable to acquire lock on user token pool");

                    mumps.unlock("geodigraph", ["tokenPool"]);
                    mumps.close();
                    throw("Unable to acquire lock on user token pool");
                }

                mumps.unlock("geodigraph", ["accounts", this.email, "tokenPool"]);

            }
            else {        
                audit(auditAction, "FAIL expanding token pool for #this.email# by #arguments.tokensRequested#; unable to acquire lock on system token pool");
                mumps.close();        
                throw("Unable to acquire lock on system token pool");
            }

            mumps.unlock("geodigraph", ["tokensAllocated"]);
        }

        mumps.close();
    }

    public void function contractTokenPool(required number tokenCount)
    {
        var auditAction = "contractTokenPool_" & createUUID();
        audit(auditAction, "BEGIN contracting token pool for #this.email# by #arguments.tokenCount#");

        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        lock scope="Application" timeout="10" {
            
            // don't allow the token pool to contract below what the user already has allocated
            var newTokenPoolSize = this.getTokenPool() - arguments.tokenCount;

            if(newTokenPoolSize < this.getTokensAllocated()) {
                audit(auditAction, "FAIL contracting token pool for #this.email# by #arguments.tokenCount#; new poolSize < tokensAllocated");
                mumps.close();
                throw("Reduced user token pool size cannot be less than the number of user tokens currently allocated");
            }


            if(mumps.lock("geodigraph", ["accounts", this.email, "tokenPool"], 10)) {
                mumps.set("geodigraph", ["accounts", this.email, "tokenPool"], newTokenPoolSize);
            }
            else {
                audit(auditAction, "FAIL contracting token pool for #this.email# by #arguments.tokenCount#; cannot get lock on user token pool");
                mumps.close();
                throw("Unable to acquire lock on user token pool.");
            }

            if(mumps.lock("geodigraph", ["tokensAllocated"], 10)) {
                var systemTokensAllocated = mumps.get("geodigraph", ["tokensAllocated"]);
                systemTokensAllocated -= arguments.tokenCount;

                mumps.set("geodigraph", ["tokensAllocated"], systemTokensAllocated);
            }
            else {
                audit(auditAction, "FAIL contracting token pool for #this.email# by #arguments.tokenCount#; cannot get lock on system token pool");
                mumps.close();
                throw("Unable to acquire lock on system token pool.")
            }
            audit(auditAction, "SUCCESS contracting token pool for #this.email# by #arguments.tokenCount#");

        }

    }

    public void function allocateTokens(required number tokenCount)
    {
        var auditAction = "allocateTokens_" & createUUID();
        audit(auditAction, "BEGIN allocating #arguments.tokenCount# tokens for #this.email#");

        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        lock scope="Application" timeout="10" {
            if(this.getTokensFree() < arguments.tokenCount) {
                audit(auditAction, "FAIL allocating #arguments.tokenCount# tokens for #this.email#; user token pool exhausted");
                throw("User token pool exhausted");
            }

            if(mumps.lock("geodigraph", ["accounts", this.email, "tokensAllocated"])) {
                var tokensAllocated = this.getTokensAllocated();

                tokensAllocated += arguments.tokenCount;
                mumps.set("geodigraph", ["accounts", this.email, "tokensAllocated"], tokensAllocated);
                audit(auditAction, "SUCCESS allocating #arguments.tokenCount# tokens for #this.email#");
            }
            else {
                audit(auditAction, "FAIL allocating #arguments.tokenCount# tokens for #this.email#; could not acquire lock on user token pool");
                mumps.close();
                throw("Could not acquire lock on user token pool");
            }
            mumps.unlock("geodigraph", ["accounts", this.email, "tokensAllocated"]);
        }

        mumps.close();
    }

    public void function overbook(required number tokenCount)
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        lock scope="Application" timeout="10" {
            var currentOverbook = mumps.get("geodigraph", ["accounts", this.email, "tokensOverbooked"]);
            mumps.set("geodigraph", ["accounts", this.email, "tokensOverbooked"], currentOverbook + arguments.tokenCount);
            mumps.set("geodigraph", ["accounts", this.email, "uploadsEnabled"], 0); 
        }

        mumps.close();
    }

    public void function deallocateTokens(required number tokenCount)
    {
        var auditAction = "deallocateTokens_" & createUUID();
        audit(auditAction, "BEGIN deallocating #arguments.tokenCount# tokens for #this.email#");

        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        lock scope="Application" timeout="10" {

            if(mumps.lock("geodigraph", ["accounts", this.email, "tokensAllocated"], 10)) {
                var tokensAllocated = this.getTokensAllocated();

                if(tokensAllocated < tokenCount) {
                    tokensAllocated = 0;
                }
                else {
                    tokensAllocated -= arguments.tokenCount;
                }

                mumps.set("geodigraph", ["accounts", this.email, "tokensAllocated"], tokensAllocated);
            }
            else {
                audit(auditAction, "FAIL deallocating #arguments.tokenCount# tokens for #this.email#; could not acquire lock on user token pool");
                mumps.close();
                throw("Could not acquire lock on user token pool");
            }
            audit(auditAction, "SUCCESS deallocating #arguments.tokenCount# tokens for #this.email#");

            mumps.unlock("geodigraph", ["accounts", this.email, "tokensAllocated"]);
            
        }

        mumps.close();
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

        var uploadsEnabled = 0;
        if(this.uploadsEnabled == true)
        {
            uploadsEnabled = 1;
        }

        accountStruct = {
            firstName: this.firstName,
            lastName: this.lastName,          
            passwordHash: this.passwordHash,
            picture: this.picture,
            zip: this.zip,
            admin: this.admin,
            verificationCode: this.verificationCode,
            verified: verified,
            company: this.email,
            tokenPool: 0,
            tokensAllocated: 0,
            tokensOverbooked: this.tokensOverbooked,
            uploadsEnabled: uploadsEnabled
        };


        glob.setObject(accountStruct);

        this.expandTokenPool(10);
        this.addDefaultLayers();

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

                layer.addToAccount(this, true, zIndex, opacity);
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