<cfscript>
    session.loggedIn = false;
    session.admin = false;
    session.firstName = "";
    session.lastName = "";
    session.zip = "";
    session.picture = "";
    session.company = "";
</cfscript>

<cflocation url="login.cfm">