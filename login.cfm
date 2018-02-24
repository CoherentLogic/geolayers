<!DOCTYPE html>
<html>

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Geodigraph GIS 2018 | Login</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="font-awesome/css/font-awesome.css" rel="stylesheet">

    <link href="css/animate.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">

</head>

<body class="gray-bg">
    <cfset errorMessage = "">
    <cfif IsDefined("form.submit")>

       <cfscript>
            pwh = hash(form.password, "SHA-256");
            account = new Account();

            try {
                account.open(form.email);

                if(account.passwordHash == pwh) {
                    session.email = form.email;
                    session.firstName = account.firstName;
                    session.lastName = account.lastName;
                    if(account.picture != "") {
                        session.picture = account.picture;
                    }  
                    else {
                        session.picture = "img/placeholder.png";
                    }
                    session.company = account.company;
                    session.zip = account.zip;
                    session.loggedIn = true;

                    account.saveSessionId();

                    session.admin = account.admin;

                    session.account = account;

                    if(isDefined("form.showLayer")) {
                        location("default.cfm?showLayer=" & form.showLayer);
                    }
                    else {
                        location("default.cfm");
                    }
                }
                else {
                    errorMessage = "Invalid user credentials.";
                }
            }
            catch(InvalidAccount ex) {
                errorMessage = "Invalid user credentials."
            }

       </cfscript>

       
    </cfif>

        <div class="middle-box text-center loginscreen animated fadeInDown">
            <div>
                <div>

                    <h1 class="logo-name"><img src="img/login-header.png"></h1>

                </div>
                <h3>Geodigraph GIS 2018</h3>
                
                <span style="color:red;"><cfoutput>#errorMessage#</cfoutput></span>
                
                <form class="m-t" role="form" action="login.cfm" method="post">
                    <cfif isDefined("url.showLayer")>
                        <cfoutput>
                            <input type="hidden" name="showLayer" value="#url.showLayer#">
                        </cfoutput>
                    </cfif>
                    <div class="form-group">
                        <input type="email" class="form-control" placeholder="Email Address" required="" name="email">
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" placeholder="Password" required="" name="password">
                    </div>
                    <button type="submit" class="btn btn-primary block full-width m-b" name="submit">Login</button>

                    <a href="#"><small>Forgot password?</small></a>
                    <p class="text-muted text-center"><small>Do not have an account?</small></p>
                    <a class="btn btn-sm btn-white btn-block" href="register.cfm">Create an account</a>
                </form>
                <p class="m-t"> <small>Copyright &copy; 2018 Coherent Logic Development LLC</small> </p>
            </div>
        </div>

        <!-- Mainly scripts -->
        <script src="js/jquery-3.1.1.min.js"></script>
        <script src="js/bootstrap.min.js"></script> 
</body>

</html>
