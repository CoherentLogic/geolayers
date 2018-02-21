<cfscript>
global = new lib.cfmumps.Global("geodigraph", ["accounts", session.email, "mapPosition"]);
position = {
    lat: url.lat,
    lng: url.lng,
    zoom: url.zoom
};
global.setObject(position);
</cfscript>