component extends="Util" {

    remote struct function showlayer(required string id) returnformat="JSON"
    {
        if(!session.loggedIn) {
            return {
                success: false,
                message: "Not logged in"
            };
        }

        
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var subs = ["accounts", session.account.email, "layers", arguments.id, "hidden"];

        if(mumps.data("geodigraph", ["accounts", session.account.email, "layers", arguments.id]).hasSubscripts) {

            mumps.kill("geodigraph", subs);

            session.account.setUiRefresh();

            mumps.close();

            return {
                success: true,
                message: "Layer shown"
            };

        }
        else {

            mumps.close();

            return {
                success: false,
                message: "Layer does not exist in user's Personal Layer Display"
            };
        }

    }

    remote struct function hidelayer(required string id) returnformat="JSON"
    {
        if(!session.loggedIn) {
            return {
                success: false,
                message: "Not logged in"
            };
        }

        
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();

        var subs = ["accounts", session.account.email, "layers", arguments.id, "hidden"];

        if(mumps.data("geodigraph", ["accounts", session.account.email, "layers", arguments.id]).hasSubscripts) {

            mumps.set("geodigraph", subs, "1");

            session.account.setUiRefresh();

            mumps.close();

            return {
                success: true,
                message: "Layer hidden"
            };

        }
        else {

            mumps.close();

            return {
                success: false,
                message: "Layer does not exist in user's Personal Layer Display"
            };
        }

    }

 

    remote struct function layer(required string id) returnformat="JSON"
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
                return this.get(arguments.id);
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

    private struct function get(required string id)
    {
        var mumps = new lib.cfmumps.Mumps();
        mumps.open();        

        if(mumps.data("geodigraph", ["layers", arguments.id]).defined) {    

            mumps.close();

            try {
                var layerObj = this.getLayerObject(arguments.id);
                var layer = layerObj.toStruct();
                var shares = layerObj.getShares();
                var sharedEmails = [];

                for(share in shares) {
                    sharedEmails.append(share.email);
                }

                layer.created = lcase(friendlyDate(layer.timestamp));
                layer.tokenSize = mumps.get("geodigraph", ["tokenSize"]);

                if(mumps.data("geodigraph", ["permissions", "layer", "global", arguments.id]).defined) {
                    layer.public = true;
                }
                else {
                    layer.public = false;
                }

                if(mumps.data("geodigraph", ["defaultLayers", arguments.id]).defined) {
                    layer.default = true;
                }
                else {
                    layer.default = false;
                }

                layer.shares = sharedEmails;


                return {
                    success: true,
                    message: "",
                    layer: layer,                    
                };
            }
            catch (any ex) {

                return {
                    success: false,
                    message: ex.message
                };
            }
            
        }
        else {
            return {
                success: false,
                message: "Invalid layer ID #arguments.id#"
            };
        }
        
    }

}