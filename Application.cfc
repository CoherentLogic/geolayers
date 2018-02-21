component {

	this.Name = "geodigraph";
	this.ApplicationTimeout = CreateTimeSpan(0, 2, 0, 0);
	this.SessionTimeout = CreateTimeSpan(0, 2, 0, 0);
	this.SessionManagement = true;
	this.SetClientCookies = true;

	public boolean function onApplicationStart() 
	{
		return true;
	}

	public boolean function onSessionStart() 
	{

		session.email = "";
		session.firstName = "Guest";
		session.lastName = "User";
		session.company = "Geodigraph";
		session.zip = "88001";
		session.picture = "img/geodigraph_icon.png";
		session.loggedIn = false;
		session.admin = false;
		session.account = "";

		return true;

	}

	public boolean function onRequestStart()
	{
		return true;
	}

	public void function onRequest(required string targetPage)
	{
		include arguments.targetPage;

		return;
	}

	public void function onRequestEnd()
	{
		return;
	}

	public void function onSessionEnd(required struct sessionScope, required struct applicationScope)
	{
		structClear(arguments.sessionScope);

		return;
	}

	public void function onApplicationEnd(required struct applicationScope)
	{

		return;
	}


	public void function addGeoTiffLayer(required string layerId,
		required string layerName,
		required number minZoom,
		required number maxZoom,
		required string attribution,
		required string copyright) output=false
	{
		global = new lib.cfmumps.Global("geodigraph", ["layers", arguments.layerId]);

		layer = {
			renderer: "geotiff",
			name: arguments.layerName,
			contributor: session.email,
			timestamp: now(),
			ready: 0,
			minZoom: arguments.minZoom,
			maxZoom: arguments.maxZoom,
			attribution: arguments.attribution,
			copyright: arguments.copyright
		};

		global.setObject(layer);	

	}

	public void function completeLayer(required string layerId, required boolean failed) output=false
	{
		layer = getLayer(arguments.layerId);

		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		mumps.set("geodigraph", ["layers", arguments.layerId, "ready"], 1);

		notifyTargets = [];

		lastResult = false;
		target = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["notifyTargets", arguments.layerId, target]);
			lastResult = order.lastResult;
			target = order.value;

			if(target != "") {
				notifyTargets.append({email: target});
				setLayerRefresh(target);
			}
		}

		mumps.close();

		if(failed) {

			removeLayer(arguments.layerId);

			notification = new Notification({
				caption: "Error processing #layer.name#",
				message: "Layer #layer.name# has failed processing, possibly due to a corrupt GeoTIFF file or a TIFF file that contains no georeference information.",
				link: "",
				icon: "exclamation-triangle"
			});		
		}
		else {
			notification = new Notification({
				caption: "#layer.name# is ready.",
				message: "Layer #layer.name# has completed processing and is ready to view.",
				link: "https://geolayers.geodigraph.com/v2/default.cfm?showLayer=#arguments.layerId#",
				icon: "map"
			});
		}

		notification.send(notifyTargets);

	}

	public array function getNotifyTargets(required string layerId) output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		lastResult = false;
		target = "";

		notifyTargets = [];

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["notifyTargets", arguments.layerId, target]);
			lastResult = order.lastResult;
			target = order.value;

			if(target != "") {
				notifyTargets.append({email: target});					
			}
		}

		mumps.close();

		return notifyTargets;
	}

	public array function getUserCompanies(required string email) output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		companies = [];

		lastResult = false;
		company = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["accounts", arguments.email, "companies", company]);
			lastResult = order.lastResult;
			company = order.value;

			if(company != "") {
				companies.append(company);
			}
		}

		mumps.close();

		return companies;
	}


	public string function getLayerStatus(required string layerId) output=false
	{
		layer = getLayer(arguments.layerId);

		switch(layer.renderer) {
			case 'geotiff':
			filePath = "/var/gis/users/geolayers/geolayers/v2/tiles/#arguments.layerId#/STAT.GL8";
			return fileRead(filePath);
			break;
			case 'parcel':



			break;
			default:
			return "Complete";
		}
	}


	public array function getAccessibleLayers(required string email) output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		layers = [];

		lastResult = false;
		layerId = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["permissions", "layer", "global", layerId]);
			lastResult = order.lastResult;
			layerId = order.value;

			if(layerId != "") {					
				layers.append(layerId);
			}
		}

		lastResult = false;
		layerId = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["permissions", "layer", "user", arguments.email, layerId]);
			lastResult = order.lastResult;
			layerId = order.value;

			if(layerId != "") {					
				layers.append(layerId);
			}
		}

		userCompanies = getUserCompanies(arguments.email);

		for(company in userCompanies) {
			lastResult = false;
			layerId = "";

			while(lastResult == false) {
				order = mumps.order("geodigraph", ["permissions", "layer", "company", company, layerId]);
				lastResult = order.lastResult;
				layerId = order.value;

				if(layerId != "") {					
					layers.append(layerId);
				}
			}
		}

		mumps.close();

		return layers;
	}

	public void function addCompany(required string companyName) output=false
	{	
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		mumps.set("geodigraph", ["companies", companyName], "");

		mumps.close();
	}

	public void function setUserCompany(required string email, required string companyName) output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		mumps.set("geodigraph", ["accounts", arguments.email, "company"], arguments.companyName);

		mumps.close();
	}

	public void function addUserToCompany(required string email, required string companyName) output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		mumps.set("geodigraph", ["companies", arguments.companyName, "users", arguments.email], "");
		mumps.set("geodigraph", ["accounts", arguments.email, "companies", arguments.companyName], "");

		mumps.close();
	}


	public array function listCompanies() output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		companies = [];

		lastResult = false;
		nextSubscript = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["companies", nextSubscript]);
			lastResult = order.lastResult;
			nextSubscript = order.value;

			if(nextSubscript != "") {
				companies.append(order.value);
			}
		}

		mumps.close();

		return companies;
	}

	public array function getCompanyUsers(required string companyName) output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		users = [];

		lastResult = false;
		user = "";


		while(lastResult == false) {
			order = mumps.order("geodigraph", ["companies", arguments.companyName, "users", user]);
			lastResult = order.lastResult;
			user = order.value;

			uo = {
				email: user
			};

			if(user != "") {
				users.append(uo);
			}
		}

		mumps.close();

		return users;

	}

	public array function listUsers() output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		users = [];

		lastResult = false;
		email = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["accounts", email]);
			lastResult = order.lastResult;
			email = order.value;

			if(email != "") {

				firstName = mumps.get("geodigraph", ["accounts", email, "firstName"]);
				lastName = mumps.get("geodigraph", ["accounts", email, "lastName"]);

				user = {
					email: email,
					firstName: firstName,
					lastName: lastName
				};

				users.append(user);
			}
		}

		mumps.close();

		return users;
	}

	public struct function listNotifications() output=false
	{
		mumps = new lib.cfmumps.Mumps();
		mumps.open();

		notifications = {};

		lastResult = false;
		index = "";

		while(lastResult == false) {
			order = mumps.order("geodigraph", ["accounts", session.email, "notifications", index]);
			lastResult = order.lastResult;
			index = order.value;

			if(index != "") {
				global = new lib.cfmumps.Global("geodigraph", ["accounts", session.email, "notifications", index]);
				notification = global.getObject();

				notifications[index] = notification;
				notifications[index].time = notification.time;	

				mumps.set("geodigraph", ["accounts", session.email, "notifications", index, "delivered"], "1");				
			}
		}

		mumps.close();

		return notifications;
	}

}		



