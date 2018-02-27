<!DOCTYPE html>
<html>

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Geodigraph GIS 2018 | Verify Account</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="font-awesome/css/font-awesome.css" rel="stylesheet">
    <link href="css/plugins/iCheck/custom.css" rel="stylesheet">
    <link href="css/animate.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">

</head>

<body class="gray-bg">

    <cfif IsDefined("form.submit")>        
        <cfscript>
            

        </cfscript>        
    <cfelse>
        <cfscript>
        account = new Account(url.email);

        if(account.verificationCode == url.code) {

            o = {
                verificationCode: "",
                verified: 1
            };

            glob = new lib.cfmumps.Global("geodigraph", ["accounts", url.email]);
            glob.setObject(o);
            glob.close();

            needMoreInfo = false;

            if(account.firstName == "") {
                needMoreInfo = true;
            }

            if(account.lastName == "") {
                needMoreInfo = true;
            }

            if(account.passwordHash == "") {
                needMoreInfo = true;
            }

            if(account.zip == "") {
                needMoreInfo = true;
            }

            verifyGood = true;
        }
        else {
            verifyGood = false;
        }
        </cfscript>
        <div class="middle-box text-center loginscreen animated fadeInDown">
            <div>
                <div>

                    <h1 class="logo-name"><img src="img/login-header.png"></h1>

                </div>
                <cfif verifyGood>                    
                    <cfif needMoreInfo>

                        <h3>Set Up Account</h3>
                        <p>Your account has been verified. Please fill out this form to complete the account setup process.</p>

                        <form class="m-t" role="form" action="register.cfm"  method="post">
                            
                            <cfif account.passwordHash EQ "">
                                <div class="form-group">
                                    <input type="password" class="form-control" placeholder="Password" required="" name="password">
                                </div>
                            </cfif>

                            <cfif account.firstName EQ "">
                                <div class="form-group">
                                    <input type="text" class="form-control" placeholder="First Name" required="" name="firstName">
                                </div>
                            </cfif>

                            <cfif account.lastName EQ "">
                                <div class="form-group">
                                    <input type="text" class="form-control" placeholder="Last Name" required="" name="lastName">
                                </div>
                            </cfif>

                            <cfif account.zip EQ "">
                                <div class="form-group">
                                    <input type="text" class="form-control" placeholder="ZIP Code" required="" name="zip">
                                </div>
                            </cfif>
                                                        
                            <button type="submit" class="btn btn-primary block full-width m-b" name="submit">Set Up Account</button>

                            <p class="text-muted text-center"><small>Already have an account?</small></p>
                            <a class="btn btn-sm btn-white btn-block" href="login.cfm">Login</a>
                        </form>
                    <cfelse>
                        <cflocation url="login.cfm">
                    </cfif>
                <cfelse>
                    <h3>Invalid verification code</h3>
                    <p>Please try again.</p>
                </cfif>
                <p class="m-t"> <small>Copyright &copy; 2018 Coherent Logic Development LLC</small> </p>
            </div>
        </div>

        <!-- Mainly scripts -->
        <script src="js/jquery-3.1.1.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
        <!-- iCheck -->
        <script src="js/plugins/iCheck/icheck.min.js"></script>
        <script>
            $(document).ready(function(){
                $('.i-checks').iCheck({
                    checkboxClass: 'icheckbox_square-green',
                    radioClass: 'iradio_square-green',
                });
            });
        </script>
    </cfif> 
</body>

</html>
