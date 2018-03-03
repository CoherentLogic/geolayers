<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Remove Tokens</title>        
    </head>
    <body>
        <cfinclude template="admin_header.cfm">
        <cfif session.account.admin EQ true>
            <cfif isDefined("form.submit")>
                <h2>Results</h2>
                <cfscript>
                try {
                    user = new Account(form.account);
                    user.contractTokenPool(form.tokenCount);

                    message = "#form.tokenCount# tokens removed from #form.account#";
                }
                catch(any ex) {                    
                    message = ex.message;
                }
                </cfscript>
                <p><cfoutput>#message#</cfoutput></p>
            <cfelse>
                <h2>Remove Tokens</h2>
                <form method="POST" action="remove_tokens.cfm">
                    <table>
                        <tr>
                            <td>Account:</td>
                            <td><input type="text" name="account"></td>
                        </tr>
                        <tr>
                            <td>Token Count:</td>
                            <td><input type="text" name="tokenCount"></td>                    
                        </tr>
                        <tr>
                            <td colspan="2" align="right">
                                <input type="reset" name="reset" value="Reset">
                                <input type="submit" name="submit" value="Submit">
                            </td>
                        </tr>
                    </table>
                </form>
            </cfif>
        <cfelse>
            <h2>Access Denied</h2>
        </cfif>
    </body>
</html>