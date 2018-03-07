component {

    remote struct function authenticate() returnformat="JSON"
    {
        var method = getHTTPRequestData().method;

        var invalidCred = {
            success: false,
            message: "Invalid credentials."
        };

        if(method != "POST") {
            return {
                success: false,
                message: "Can only authenticate via HTTP POST."
            };
        }
        else {
            var glob = new lib.cfmumps.Global("geodigraph", ["accounts", form.username]);
            if(!glob.defined().hasSubscripts) {
                return invalidCred;
            }
            else {
                var user = glob.getObject();

                var passwordHash = hash(form.password, "SHA-256");

                if(!user.verified) {
                    return invalidCred;
                }

                if(user.passwordHash != passwordHash) {
                    return invalidCred;
                }
                else {
                    session.loggedIn = true;
                    session.account = new Account(form.username);   
                    
                    return {
                        success: true,
                        message: "Authentication successful"
                    };                 
                }
            }
        }


        return form;
    }

    remote struct function logout() returnformat="JSON"
    {
        session.loggedIn = false;
        session.account = {};

        return {
            success: true,
            message: "Logged out"
        };
    }

}