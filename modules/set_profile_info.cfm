<cfheader name="Content-Type" value="application/json">
<cfscript>

try {
    var global = new lib.cfmumps.Global("geodigraph", ["accounts", session.account.email]);

    global.setObject({
        firstName: url.firstName,
        lastName: url.lastName,
        zip: url.zip
    });

    session.account.firstName = url.firstName;
    session.account.lastName = url.lastName;
    session.account.zip = url.zip;

    o = {
        success: true,
        message: "Profile updated"
    };

}
catch(any ex) {
    o = {
        success: false,
        message: ex.message
    };
}


writeOutput(serializeJSON(o));
</cfscript>
