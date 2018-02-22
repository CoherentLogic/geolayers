<cfdump var="#form#">
<cfscript>

    layer = new BaseLayer(form.baseLayerId, {
        name: form.baseLayerName,
        url: form.baseLayerUrl,
        attribution: form.baseLayerAttribution,
        copyright: form.baseLayerCopyright,
        minZoom: form.baseLayerMinZoom,
        maxZoom: form.baseLayerMaxZoom,
        contributor: session.account.email
    });

    switch(form.baseLayerAddTo) {
        case "allUsers":
            layer.grantGlobalAccess();
            break;
        case "existingUser":
            user = new Account(form.baseLayerExistingUsers);
            layer.grantUserAccess(user);
            break;
        case "existingCompany":
            company = new Company(form.baseLayerExistingCompanies);
            layer.grantCompanyAccess(company);
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
            u = new Account(user.email);

            layer.share(u, true, 1, 100);
        }

        
    }

    if(isDefined("form.addBaseToMyPersonal")) {
        layer.share(session.account, true, 1, 100);               
    }    

    if(isDefined("form.addBaseToAllNewAccounts")) {
        layer.setAsDefault();
    }

</cfscript>
