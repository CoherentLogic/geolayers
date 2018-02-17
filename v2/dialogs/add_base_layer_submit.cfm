<cfdump var="#form#">
<cfscript>
<!---required string layerId,
                                          required string layerName,
                                          required string url,
                                          required number minZoom,
                                          required number maxZoom,
                                          required string attribution,
                                          required string copyright
--->
    addBaseLayer(form.baseLayerId, form.baseLayerName, form.baseLayerUrl, form.baseLayerMinZoom, form.baseLayerMaxZoom, form.baseLayerAttribution, form.baseLayerCopyright);

    switch(form.baseLayerAddTo) {
        case "allUsers":
            grantLayerGlobalAccess(form.baseLayerId);
            break;
        case "existingUser":
            grantLayerUserAccess(form.baseLayerId, form.baseLayerExistingUsers);
            break;
        case "existingCompany":
            grantLayerCompanyAccess(form.baseLayerId, form.baseLayerExistingCompanies);
            break;
    }

    if(isDefined("form.addBaseToSelectedPersonal")) {
        switch(form.baseLayerAddTo) {
            case "allUsers":
                userList = listUsers();
                break;
            case "existingUser":
                userList = [{email: form.baseLayerExistingUsers}];
                break;
            case "existingCompany":
                userList = getCompanyUsers(form.baseLayerExistingCompanies);
                break;
        }

        for(user in userList) {
            addLayerToUser(form.baseLayerId, user.email, 1, 100, 1);
            setLayerRefresh(user.email);
        }

        notification = new Notification({
            caption: form.baseLayerName & " is ready",
            message: "A new base layer, " & form.baseLayerName & ", has been added to your personal layers display.",
            link: "https://geolayers.geodigraph.com/v2/default.cfm?showLayer=#form.baseLayerId#",
            icon: "fa-map"
        });

        notification.send(getNotifyTargets(form.baseLayerId));
    }

    if(isDefined("form.addBaseToMyPersonal")) {
        addLayerToUser(form.baseLayerId, session.email, 1, 100, 1);
        setLayerRefresh(session.email);   

        notification = new Notification({
            caption: form.baseLayerName & " is ready",
            message: "A new base layer, " & form.baseLayerName & ", has been added to your personal layers display.",
            link: "https://geolayers.geodigraph.com/v2/default.cfm?showLayer=#form.baseLayerId#",
            icon: "fa-map"
        });

        notification.send([{email: session.email}]);                      
    }    

    if(isDefined("form.addBaseToAllNewAccounts")) {
        addLayerToAllNewAccounts(form.baseLayerId);
    }

</cfscript>
