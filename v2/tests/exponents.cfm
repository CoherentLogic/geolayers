
<cfscript>
mumps = new lib.cfmumps.Mumps();
mumps.open();

mumps.set("jpw", [], 12E300000000000000000000000000000000000000000000);

writeOutput(12E300000000000000000000000000000000000000000000);

mumps.close();
</cfscript>