<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>User Accounts</title>
    </head>
    <body>
        <cfinclude template="admin_header.cfm">
        <cfif session.account.admin EQ true>

            <cfset users=listUsers()>
            <h2>User Accounts</h2>
            <table border="1">
                <thead>
                    <tr>
                        <th>E-Mail</th>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Picture</th>
                        <th>Permissions</th>
                        <th>Tokens (Allocated/Overbooked/Total)</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop array="#users#" item="u">
                        <cfscript>
                        user = new Account(u.email);
                        </cfscript>
                        <cfoutput>
                            <tr>
                                <td>#user.email#</td>
                                <td>#user.firstName#</td>
                                <td>#user.lastName#</td>
                                <td><img src="#user.picture#" width="50" height="50"></td>
                                <td>
                                    <cfif user.admin>
                                        Site Admin
                                    <cfelse>
                                        Standard User
                                    </cfif>
                                </td>
                                <td>#user.getTokensAllocated()#/#user.getTokensOverbooked()#/#user.getTokenPool()#</td>
                            </tr>
                        </cfoutput>
                    </cfloop>
                </tbody>
            </table>
        <cfelse>
            <h1>Access Denied</h1>
        </cfif>
    </body>
</html>