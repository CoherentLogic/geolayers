<cfscript>
mumps = new lib.cfmumps.Mumps();
mumps.open();

mumps.set("geodigraph", ["accounts", session.email, "layers", url.layerId, "opacity"], url.opacity);

mumps.close();
</cfscript>