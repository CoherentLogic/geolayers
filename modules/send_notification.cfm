<cfheader name="Content-Type" value="application/json">
<cfscript>
    if(!session.loggedIn) {
        throw(type="AccessDenied", message="Access denied");
    }

    status = {}; 

    try {
        notification = new Notification({
            caption: url.caption,
            message: url.message,
            link: url.link,
            icon: url.icon
        });

        notification.send([url.recipient]);

        status = {
            ok: 1,
            message: "Notification sent"
        };
    }
    catch(any ex) {
        status = {
            ok: 0,
            message: ex.message
        };
    }

    writeOutput(serializeJSON(status));
</cfscript>