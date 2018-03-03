<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Audit Log</title>
    </head>
    <body>
        <cfinclude template="admin_header.cfm">
        <cfif session.account.admin EQ true>
            
        <cfelse>
            <h1>Access Denied</h1>
        </cfif>
    </body>
</html>