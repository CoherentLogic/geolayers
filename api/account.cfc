component extends="Util" {

    remote struct function account(required string email) returnformat="JSON"
    {
        if(!session.loggedIn) {
            return {
                success: false,
                message: "Not logged in"
            };
        }

        var method = getHTTPRequestData().method;

        switch(method) {
            case "GET":
                return this.get(arguments.email);
                break;
            case "POST":
                return {
                    success: false,
                    message: "POST not implemented"
                };
                break;
            case "DELETE":
                return {
                    success: false,
                    message: "DELETE not implemented"
                };
                break;
        }

        return {
            success: false,
            message: "Invalid HTTP method"
        };
    } 

    private struct function get(required string email)
    {
        var glob = new lib.cfmumps.Global("geodigraph", ["accounts", arguments.email]);

        if(glob.defined().defined) {    

            try {
                var a = glob.getObject();
           
                glob.close();

                return {
                    success: true,
                    message: "",
                    account: {
                        email: arguments.email,
                        picture: a.picture,
                        name: "#a.firstName# #a.lastName#",                    
                    }
                };
            }
            catch (any ex) {
                glob.close();

                return {
                    success: false,
                    message: ex.message,
                    email: arguments.email
                };
            }
            
        }
        else {
            glob.close();
            return {
                success: false,
                message: "Invalid account #arguments.email#"
            };
        }
        
    }

}