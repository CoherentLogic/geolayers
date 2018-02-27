<!DOCTYPE html>
<html>

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Geodigraph GIS 2018 | Register</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="font-awesome/css/font-awesome.css" rel="stylesheet">
    <link href="css/plugins/iCheck/custom.css" rel="stylesheet">
    <link href="css/animate.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">

</head>

<body class="gray-bg">

    <cfif IsDefined("form.submit")>
        <cfscript>
            user = new Account();

            user.email = form.email;
            user.firstName = form.firstName;
            user.lastName = form.lastName;
            user.company = user.email;
            user.zip = form.zip;

            user.setPassword(form.password);
            user.save();   

            user.addDefaultLayers();
            
            addUserToCompany(user.email, user.company);
            setUserCompany(user.email, user.company); 
            
        </cfscript> 

        <div class="middle-box text-center loginscreen animated fadeInDown">
            <div>
                <div>

                    <h1 class="logo-name"><img src="img/login-header.png"></h1>

                </div>
                <h3>Thank you!</h3>
                <p>Please check your e-mail for a message you can use to verify your new account.</p>
            </div>
        </div>


        
    <cfelse>
        <div class="middle-box text-center loginscreen animated fadeInDown">
            <div>
                <div>

                    <h1 class="logo-name"><img src="img/login-header.png"></h1>

                </div>
                <h3>Register Account</h3>

                <form class="m-t" role="form" action="register.cfm"  method="post">
                    <div class="form-group">
                        <input type="email" class="form-control" placeholder="Email Address" required="" name="email">
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" placeholder="Password" required="" name="password">
                    </div>
                    <div class="form-group">
                        <input type="text" class="form-control" placeholder="First Name" required="" name="firstName">
                    </div>
                    <div class="form-group">
                        <input type="text" class="form-control" placeholder="Last Name" required="" name="lastName">
                    </div>
                    <!---
                    <div class="form-group">
                        <input type="text" class="form-control" placeholder="Company Name" required="" name="company">
                    </div>
                    --->
                    <div class="form-group">
                        <input type="text" class="form-control" placeholder="ZIP Code" required="" name="zip">
                    </div>
                    
                    
                    <div class="form-group">
                        <div class="checkbox i-checks">
                            <label>
                                <input type="checkbox"><i></i> I agree to abide by our terms of use and privacy policy
                            </label>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary block full-width m-b" name="submit">Register</button>

                    <p class="text-muted text-center"><small>Already have an account?</small></p>
                    <a class="btn btn-sm btn-white btn-block" href="login.cfm">Login</a>
                </form>
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
