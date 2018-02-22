<cfscript>

    layer = new GeotiffLayer(form.geoTiffLayerId, {
        name: form.geoTiffLayerName,
        minZoom: form.geoTiffMinZoom,
        maxZoom: form.geoTiffMaxZoom,
        attribution: form.geoTiffAttribution,
        copyright: form.geoTiffCopyright,
        contributor: session.account.email
    });

   
    switch(form.addGeoTiffTo) {
        case "allUsers":
            layer.grantGlobalAccess();
            break;
        case "existingUser":
            layer.grantUserAccess(new Account(form.geoTiffExistingUsers));
            break;
        case "existingCompany":
            layer.grantCompanyAccess(new Company(form.geoTiffExistingCompanies));
            break;
    }

    if(isDefined("form.addGeoTiffToSelectedPersonal")) {
        switch(form.addGeoTiffTo) {
            case "allUsers":
                userList = listUsers();
                break;
            case "existingUser":
                userList = [{email: form.geoTiffExistingUsers}];
                break;
            case "existingCompany":
                userList = getCompanyUsers(form.geoTiffExistingCompanies);
                break;
        }


        for(user in userList) {
            u = new Account(user.email);

            layer.share(u, true, 2, 50);
        }
    }

    if(isDefined("form.addGeoTiffToMyPersonal")) {
        layer.share(session.account, true, 2, 50);                      
    }

    if(isDefined("form.addGeoTiffToAllNewAccounts")) {
        layer.setAsDefault();
    }

    filename = "/home/geodigraph/webapps/maps/pool/inbound/staging/#layer.id#.tif";
    fileUpload(filename, "geoTiffFile");

    args = "-f '#filename#' -i '#layer.id#' -m #layer.minZoom# -M #layer.maxZoom#";
    
    layer.postProcess("maketiles", args, "Convert GeoTIFF to Tiles");

</cfscript>
