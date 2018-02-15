<cfscript>

    addGeoTiffLayer(form.geoTiffLayerId, 
                    form.geoTiffLayerName, 
                    form.geoTiffMinZoom, 
                    form.geoTiffMaxZoom, 
                    form.geoTiffAttribution, 
                    form.geoTiffCopyright);

    switch(form.addGeoTiffTo) {
        case "allUsers":
            grantLayerGlobalAccess(form.geoTiffLayerId);
            break;
        case "existingUser":
            grantLayerUserAccess(form.geoTiffLayerId, form.geoTiffExistingUsers);
            break;
        case "existingCompany":
            grantLayerCompanyAccess(form.geoTiffLayerId, form.geoTiffExistingCompanies);
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
            addLayerToUser(form.geoTiffLayerId, user.email, 2, 50, 1);
            setLayerRefresh(user.email);
        }

    }

    if(isDefined("form.addGeoTiffToMyPersonal")) {
        addLayerToUser(form.geoTiffLayerId, session.email, 2, 50, 1);  
        setLayerRefresh(session.email);                       
    }

    if(isDefined("form.addGeoTiffToAllNewAccounts")) {
        addLayerToAllNewAccounts(form.geoTiffLayerId);
    }

    filename = "/var/gis/raw_files/#form.geoTiffLayerId#.tif";
    fileUpload(filename, "geoTiffFile");

    args = "-f #filename# -i '#form.geoTiffLayerId#'";
    cfexecute(name="/var/gis/users/geolayers/geolayers/v2/bin/maketiles", arguments=args);

</cfscript>
