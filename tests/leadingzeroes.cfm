<cfscript>

data = "792500000.0000000";

mumps = new lib.cfmumps.Mumps();
mumps.open();

mumps.set("testy", [data], data);

mumps.close();

</cfscript>