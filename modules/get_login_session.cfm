<cfheader name="Content-Type" value="application/json">
<cfscript>
if(session.loggedIn) {
    admin = false;
    if(session.account.admin == 1) {
        admin = true;
    }

    o = {
        success: true,
        message: "",
        name: session.account.firstName & " " & session.account.lastName,
        firstName: session.account.firstName,
        lastName: session.account.lastName,
        admin: admin,
        email: session.account.email,
        picture: session.account.picture,
        zip: session.account.zip
    };
}
else {
    o = {
        success: false,
        message: "Not logged in"
    };
}

writeOutput(serializeJSON(o));
</cfscript>