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



