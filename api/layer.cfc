component extends="Util" {

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
                var layer = this.getLayerObject(arguments.id).toStruct();
           
                return {
                    success: true,
                    message: "",
                    layer: layer
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