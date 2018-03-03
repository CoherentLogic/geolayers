<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Grant Tokens</title>
    </head>
    <body>
        <cfinclude template="admin_header.cfm">
        <cfif session.account.admin EQ true>
            <cfif isDefined("form.submit")>
                <h2>Results</h2>
                <cfscript>
                try {
                    user = new Account(form.account);
                    user.expandTokenPool(form.tokenCount);

                    message = "#form.tokenCount# tokens added to #form.account#";
                }
                catch(any ex) {                    
                    message = ex.message;
                }
                </cfscript>
                <p><cfoutput>#message#</cfoutput></p>
            <cfelse>
                <h2>Grant Tokens</h2>
                <form method="POST" action="grant_tokens.cfm">
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
            <h1>Access Denied</h1>
        </cfif>
    </body>
</html>