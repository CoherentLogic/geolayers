<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Processes</title>
    </head>
    <body>
        <cfinclude template="admin_header.cfm">
        <cfif session.account.admin EQ true>

            <cfset mumps = new lib.cfmumps.Mumps()>
            <cfset mumps.open()>

            <cfset lastResult = false>
            <cfset nextSubscript = "">

            <table border="1">
                <thead>
                    <tr>
                        <th>Process UUID</th>
                        <th>Node</th>
                        <th>Status</th>
                        <th>Message</th>
                        <th>Working Directory</th>
                        <th>Description</th>
                        <th>Layer ID</th>
                        <th>Command</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop condition="lastResult EQ false">
                        <cfset order = mumps.order("geodigraph", ["processes", nextSubscript])>
                        <cfset lastResult = order.lastResult>
                        <cfset nextSubscript = order.value>
                        <cfif nextSubscript NEQ "">                            
                            <cfset g = new lib.cfmumps.Global("geodigraph", ["processes", nextSubscript])>
                            <cfset p = g.getObject()>

                            <cfoutput>
                                <tr>
                                    <td>#nextSubscript#</td>
                                    <td>#p.node#</td>
                                    <td>#p.status#</td>
                                    <td>#p.statusMessage#</td>
                                    <td>#p.workingDirectory#</td>
                                    <td>#p.description#</td>
                                    <td>#p.layerId#</td>
                                    <td>#p.scriptName# #p.scriptArgs#</td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </cfloop>
                </tbody>
            </table>

        <cfelse>
            <h1>Access Denied</h1>
        </cfif>
    </body>
</html>