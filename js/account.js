class Account {

    constructor(email) 
    {
        this.email = email;

        return this;
    }

    get() 
    {
        let self = this;

        let promise = new Promise(function(resolve, reject) {
            let url = "/api/account/" + self.email;
            
            $.get(url, function(data) {
                if(data.success) {
                    self.account = data.account;
                    resolve(data.account);
                }
                else {
                    reject(data.message);
                }
            });
        });

        return promise;
    }
    
}