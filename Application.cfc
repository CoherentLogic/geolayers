<cfcomponent displayName="Application" output="true">

	<cfset this.Name = "GeoLayers">
	<cfset this.ApplicationTimeout = CreateTimeSpan(0, 2, 0, 0)>
	<cfset this.SessionTimeout = CreateTimeSpan(0, 2, 0, 0)>
	<cfset this.SessionManagement = true>
	<cfset this.SetClientCookies = true>

	<cfsetting requesttimeout="500" showdebugoutput="false" enablecfoutputonly="false">

	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="true">
		

		<cfreturn true>
	</cffunction>

	<cffunction name="OnSessionStart" access="public" returntype="boolean" output="true">
		<cfset session.email = "">
		<cfset session.firstName = "Guest">
		<cfset session.lastName = "User">
		<cfset session.company = "Geodigraph">
		<cfset session.zip = "88001">
		<cfset session.picture = "img/geodigraph_icon.png">
		<cfset session.loggedIn = false>
		<cfset session.admin = false>

		<cfreturn true>
	</cffunction>

	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="true">


		<cfreturn true>
	</cffunction>

	<cffunction name="OnRequest" access="public" returntype="void" output="true">
		<cfargument name="TargetPage" type="string" required="true">
		
		<cfinclude template="#arguments.TargetPage#">

		<cfreturn>
	</cffunction>

	<cffunction name="OnRequestEnd" access="public" returntype="void" output="true">

		<cfreturn>
	</cffunction>

	<cffunction name="OnSessionEnd" access="public" returntype="void" output="false">
		<cfargument name="SessionScope" type="struct" required="true">
		<cfargument name="ApplicationScope" type="struct" required="true">

		<cfset structClear(arguments.SessionScope)>

		<cfreturn>
	</cffunction>

	<cffunction name="OnApplicationEnd" access="public" returntype="void" output="false">
		<cfargument name="ApplicationScope" type="struct" required="false" default="#structNew()#">

		<cfreturn>
	</cffunction>

	<cfscript>

		public void function addDefaultLayers(required string email) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();
			
			layers = [];

			lastResult = false;
			layerId = "";

			while(lastResult == false) {
				order = mumps.order("geodigraph", ["defaultLayers", layerId]);
				lastResult = order.lastResult;
				layerId = order.value;

				if(layerId != "") {
					layer = getLayer(layerId);

					switch(layer.renderer) {
						case 'base':
							opacity = 100;
							zIndex = 0;							
							break;
						case 'geotiff':
							opacity = 50;
							zIndex = 1;
							break;							
						case 'parcel':						
							opacity = 50;
							zIndex = 2;
							break;
					}

					addLayerToUser(layerId, arguments.email, zIndex, opacity, 1);

				}
			}
		}

		public void function addLayerToAllNewAccounts(required string layerId) output=false 
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.set("geodigraph", ["defaultLayers", arguments.layerId], "");

			mumps.close();
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

		public void function addBaseLayer(required string layerId,
										  required string layerName,
										  required string url,
										  required number minZoom,
										  required number maxZoom,
										  required string attribution,
										  required string copyright) output=false
		{
			global = new lib.cfmumps.Global("geodigraph", ["layers", arguments.layerId]);

			layer = {
				renderer: "base",
				name: arguments.layerName,
				contributor: session.email,
				timestamp: now(),
				ready: 1,
				minZoom: arguments.minZoom,
				maxZoom: arguments.maxZoom,
				attribution: arguments.attribution,
				copyright: arguments.copyright,
				url: arguments.url
			};

			global.setObject(layer);			
		}

		public void function setNotifyTargets(required array userList, required string layerId) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			for(user in arguments.userList) {
				mumps.set("geodigraph", ["notifyTargets", arguments.layerId, user.email], "");
			}

			mumps.close();

		}

		public void function grantLayerCompanyAccess(required string layerId, required string company) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.set("geodigraph", ["permissions", "layer", "company", arguments.company, arguments.layerId], "1");

			mumps.close();

			notifyTargets = getCompanyUsers(arguments.company);
			setNotifyTargets(notifyTargets, arguments.layerId);

		}

		public void function revokeLayerCompanyAccess(required string layerId, required string company) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.kill("geodigraph", ["permissions", "layer", "company", arguments.company, arguments.layerId]);

			mumps.close();
		}

		public void function grantLayerUserAccess(required string layerId, required string email) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.set("geodigraph", ["permissions", "layer", "user", arguments.email, arguments.layerId], "1");

			notifyTargets = [{email: arguments.email}];
			setNotifyTargets(notifyTargets, arguments.layerId);

			mumps.close();
		}

		public void function revokeLayerUserAccess(required string layerId, required string email) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.kill("geodigraph", ["permissions", "layer", "user", arguments.email, arguments.layerId]);

			mumps.close();
		}

		public void function grantLayerGlobalAccess(required string layerId) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.set("geodigraph", ["permissions", "layer", "global", arguments.layerId], "1");

			notifyTargets = listUsers();
			setNotifyTargets(notifyTargets, arguments.layerId);

			mumps.close();
		}

		public void function revokeLayerGlobalAccess(required string layerId) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.kill("geodigraph", ["permissions", "layer", "global", arguments.layerId]);

			mumps.close();
		}

		public void function notifyNewLayer(required string layerId,
											required array users) output=false
		{
			layer = getLayer(arguments.layerId);
			grantor = getUser(layer.contributor);



			notCaption = "New layer available!";
			notMessage = "#grantor.firstName# #grantor.lastName# has granted you access to the layer #layer.name#.";
			notIcon = "fa-key";
			notLink = "https://";

			for(i = 1; i <= arrayLen(users); i++) {
				sendNotification(users[i].email, notIcon, notCaption, notMessage, notLink);
			}
		}

		public void function completeLayer(required string layerId) output=false
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

			notification = new Notification({
				caption: "#layer.name# is ready.",
				message: "Layer #layer.name# has completed processing and is ready to view.",
				link: "https://geolayers.geodigraph.com/v2/default.cfm?showLayer=#arguments.layerId#",
				icon: "map"
			});

			notification.send(notifyTargets);
			
		}

		public void function setLayerRefresh(required string email) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.set("geodigraph", ["accounts", arguments.email, "layerRefresh"], 1);

			mumps.close();
		}

		public void function clearLayerRefresh(required string email) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			mumps.set("geodigraph", ["accounts", arguments.email, "layerRefresh"], 0);

			mumps.close();
		}



		public struct function getLayer(required string layerId) output=false
		{
			global = new lib.cfmumps.Global("geodigraph", ["layers", arguments.layerId]);

			return global.getObject();
		}

		public struct function getUser(required string email) output=false
		{
			global = new lib.cfmumps.Global("geodigraph", ["accounts", arguments.email]);

			return global.getObject();
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

		public struct function getUserLayers(required string email) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			layers = {};

			lastResult = false;
			layerId = "";

			while(lastResult == false) {
				order = mumps.order("geodigraph", ["accounts", arguments.email, "layers", layerId]);
				lastResult = order.lastResult;
				layerId = order.value;

				if(layerId != "") {
					layerObj = getLayer(layerId);
					global = new lib.cfmumps.Global("geodigraph", ["accounts", arguments.email, "layers", layerId]);

					layer = {
						layer: layerObj,
						properties: global.getObject()
 					};

 					layers[layerId] = layer;
 					
				}
			}

			mumps.close();
			return layers;
		}

		public void function addLayerToUser(required string layerId, 
										     required string email,
										     required number zIndex,
										     required number opacity,
										     required number enabled) output=false
		{
			global = new lib.cfmumps.Global("geodigraph", ["accounts", arguments.email, "layers", arguments.layerId]);

			global.setObject({
				email: arguments.email,
				zIndex: arguments.zIndex,
				opacity: arguments.opacity,
				enabled: arguments.enabled
			});
		}

		public void function removeLayerFromUser(required string layerId, required string email) output=false
		{

		}

		public void function setUserLayerZIndex(required string layerId,
											     required string email,
											     required number zIndex) output=false
		{

		}

		public void function setUserLayerOpacity(required string layerId,
												required string email,
												required number opacity) output=false
		{

		}

		public void function setUserLayerEnabled(required string layerId,
											       required string email,
											       required number enabled) output=false
		{

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

					mumps.set("geodigraph", ["accounts", session.email, "notifications", index, "delivered"], "1");				
				}
			}

			mumps.close();

			return notifications;
		}

		public string function convertHorolog(required string horolog) output=false
		{
			mumps = new lib.cfmumps.Mumps();
			mumps.open();

			datetime = parseDateTime(mumps.mumps_function("CVTHORO^KBBMGEOD", [horolog], true));

			datePart = dateFormat(datetime, "mm/dd/yyyy");
			timePart = timeFormat(datetime, "h:mm:ss tt");

			dateStr = "#datePart# #timePart#";

			mumps.close();

			return dateStr;
		}


	</cfscript>	



	
<!---
	<cffunction name="OnError" access="public" returntype="void" output="true">
		<cfargument name="Exception" type="any" required="true">
		<cfargument name="EventName" type="string" required="false" default="">

		<cfdump var="#Exception#">

		<cfreturn>
	</cffunction>
--->
</cfcomponent>
