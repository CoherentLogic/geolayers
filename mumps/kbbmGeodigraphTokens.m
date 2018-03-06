kbbmGeodigraphTokens
    quit $$encodeResult(0,"cannot call routine directly",0)
    ;
    ; Tokens work like this:
    ;    -The system has an overall pool of tokens, based on available storage.
    ;      the number of tokens in the entire pool is in ^geodigraph("tokenPool").
    ;      This is called the "system token pool".
    ;    
    ;     -The number of tokens that have been allocated to users is stored in
    ;       ^geodigraph("tokensAllocated").
    ;  
    ;     -Each user also has a "user token pool", consisting of the total number of
    ;       tokens allocated to that user out of the system token pool.
    ;       This is in ^geodigraph("accounts",email,"tokenPool").
    ; 
    ;     -When users store data on Geodigraph servers, the number of tokens needed in 
    ;       order to store the data is calculated, and that number added to the user's
    ;       "tokens allocated" record, at ^geodigraph("accounts",email,"tokensAllocated") 
    ;
    ;      -Expanding a user's token pool involves allocating system tokens, and increasing
    ;        the user's token pool.
    ;
    ;      -Contracting a user's token pool involves deallocating system tokens, and decreasing
    ;        the user's token pool.
    ;
encodeResult(success,message,result)
    quit "{""success"":"_success_",""message"":"""_message_""",""counter"":"_result_"}"
    ;
    ;
audit(message,userEmail)
    ; initialize the audit index if needed
    i '$d(^tknaudit("index",userEmail)) s ^tknaudit("index",userEmail)=0
    ; begin setting up the audit log entry
    s ^tknaudit("a",userEmail,$increment(^tknaudit("index",userEmail)),$h)=message
    quit
    ;
    ;
allocSystemTokensToUser(tokensRequested,sourceUser,userEmail)
    n sysTokensAvailable
    ; write the planned operation to the audit log
    d audit("BEGIN allocating "_tokensRequested_" system tokens to "_userEmail,sourceUser)    
    ;
    ; tokens available 
    ;
    s sysTokensAvailable=^geodigraph("tokenPool")-^geodigraph("tokensAllocated")
    ;
    ; quit out if this request would exhaust the system token pool
    ;
    i tokensRequested>sysTokensAvailable d  quit $$encodeResult(0,"system token pool exhausted",0)
    . d audit("FAIL allocating "_tokensRequested_" system tokens to "_userEmail_"; system token pool exhausted",sourceUser)
    . q
    ;
    ; allocate the tokens
    ;
    ts ():serial
    s ^geodigraph("tokensAllocated")=^geodigraph("tokensAllocated")+tokensRequested
    s ^geodigraph("accounts",userEmail,"tokenPool")=^geodigraph("accounts",userEmail,"tokenPool")+tokensRequested
    tc
    d audit("SUCCESS allocating "_tokensRequested_" system tokens to "_userEmail,sourceUser)
    quit $$encodeResult(1,"tokens succesfully allocated",tokensRequested)
    ;
    ;
deallocSystemTokensFromUser(tokensRequested,sourceUser,userEmail)
    n userPoolSize s userPoolSize=^geodigraph("accounts",userEmail,"tokenPool")
    n userTokensAllocated s userTokensAllocated=^geodigraph("accounts",userEmail,"tokensAllocated")
    n newUserPoolSize s newUserPoolSize=userPoolSize-tokensRequested
    n auditStr s auditStr="deallocating "_tokensRequested_" system tokens from "_userEmail
    ;write the planned operation to the audit log
    d audit("BEGIN "_auditStr,userEmail,sourceUser)
    ;
    ; make sure we're not deallocating more tokens than the user's free pool
    ;
    i newUserPoolSize<userTokensAllocated  d  quit $$encodeResult(0,"new user token pool would be smaller than tokens in use",0)
    . d audit("FAIL "_auditStr_"new user token pool would be smaller than tokens in use",sourceUser)
    . q
    ;
    ; dealloc tokens
    ;
    ts ():serial
    s ^geodigraph("tokensAllocated")=^geodigraph("tokensAllocated")-tokensRequested
    s ^geodigraph("accounts",userEmail,"tokenPool")=^geodigraph("accounts",userEmail,"tokenPool")-tokensRequested
    d audit("SUCCESS "_auditStr,sourceUser)
    quit $$encodeResult(1,"tokens successfully deallocated",tokensRequested)
    ;
    ;
allocUserTokens(tokensRequested,userEmail)
    n auditStr s auditStr="allocating "_tokensRequested_" user tokens from "_userEmail
    

deallocUserTokens(tokensRequested,userEmail)
