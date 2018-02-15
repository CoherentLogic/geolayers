component displayname=account output=false {

    this.firstName = "";
    this.lastName = "";
    this.company = "";
    this.passwordHash = "";
    this.picture = "";
    this.zip = "";
    this.admin = false;
    this.companies = [];

    this.saved = false;

    public account function open(required string email) output=false
    {
        
        glob = new lib.cfmumps.Global("geodigraph", ["accounts", email]);

        a = glob.getObject();

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

        if(a.admin == 1) {
            this.admin = true;
        }
        else {
            this.admin = false;
        }

        this.email = email;


        return this;
    }

    public account function save() output=false
    {
        existingAccounts = new lib.cfmumps.Global("geodigraph", ["accounts"]).defined().defined;

        glob = new lib.cfmumps.Global("geodigraph", ["accounts", this.email]);
        
        if(glob.defined().defined) {
            throw(type="AccountExists", message="User account already exists");
        }

        if(existingAccounts == false) {
            adminValue = 1;
        }
        else {
            adminValue = 0;
        }

        accountStruct = {
            firstName: this.firstName,
            lastName: this.lastName,          
            passwordHash: this.passwordHash,
            picture: this.picture,
            zip: this.zip,
            admin: adminValue
        };


        glob.setObject(accountStruct);


        this.saved = true;

        return this;
    }

    public account function setPassword(required string password) output=false
    {
        this.passwordHash = hash(password);

        return this;
    }

}