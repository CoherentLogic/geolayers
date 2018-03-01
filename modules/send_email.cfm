<cfif isDefined("attributes")>
    <cfset attr=attributes>
<cfelse>
    <cfset attr=url>
</cfif>

<cfmail from="alerts@geodigraph.com" to="#attr.recipient#" subject="[Geodigraph] #attr.caption#" type="text/html">
    <cfoutput>
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <title>#attr.caption#</title>
                <style>
                    .wrapper {
                        margin: 10px;
                        width: 600px;
                        padding: 40px;
                        background-color: ##efefef;
                        border: 1px solid ##c0c0c0;    
                        font-family: "open sans", "Helvetica Neue", Arial, Helvetica, sans-serif;       
                        text-align: center;         
                    }
                </style>
            </head>
            <body>

                <div class="wrapper">
                    <img src="https://maps.geodigraph.com/img/login-header.png" alt="Geodigraph logo">

                    <p>#attr.message#</p>

                    <p><a href="#attr.link#">#attr.link#</a></p>

                    <hr>

                    <p style="color: ##c0c0c0; font-size: 8px;">Copyright &copy; 2018 Coherent Logic Development LLC</p>
                </div>

            </body>
        </html>
    </cfoutput>
</cfmail>