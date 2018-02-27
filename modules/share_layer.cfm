<cfheader name="Content-Type" value="application/json">
<cfscript>
    util = createObject("component", "Util");

    layer = Util.getLayerObject(url.layerId);

    if(url.email == session.account.email) {
        o = {
            success: false,
            message: "Cannot share a layer with yourself."
        };

    }
    else {

        if((session.account.admin == true) || (layer.contributor == session.account.email)) {

            opacity = 100;
            zIndex = 1;

            switch(layer.renderer) {
                case 'geotiff':
                opacity = 50;
                zIndex = 2;
                break;
                case 'base':
                opacity = 100;
                zIndex = 1;
                break;
                case 'parcel':
                opacity = 50;
                zIndex = 3;
                break;        
            }

            try {
                layer.share(new Account(url.email), true, zIndex, opacity);

                o = {
                    success: true,
                    message: ""
                };
            }
            catch (any ex) {
                o = {
                    success: false,
                    message: ex.message
                };
            }

        }
        else {
            o = {
                success: false,
                message: "Not layer owner or site administrator"
            };
        }
    }
    writeOutput(serializeJSON(o));


    </cfscript>