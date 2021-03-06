class Layer {

    constructor(id) 
    {
        this.id = id;

        return this;
    }

    get() 
    {
        let self = this;

        let promise = new Promise(function(resolve, reject) {
            let url = "/api/layer/" + self.id;
            
            $.get(url, function(data) {
                if(data.success) {
                    self.layer = data.layer;
                    resolve(data.layer);
                }
                else {
                    reject(data.message);
                }
            });
        });

        return promise;
    }
    
}