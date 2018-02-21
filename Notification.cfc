component accessors="true" displayname="Notification" {

    public Notification function init(struct options) output=false
    {
        if(isDefined("options")) {
            this.caption = options.caption;
            this.message = options.message;
            this.link = options.link;
            this.icon = options.icon;
        }

        return this;
    }

    public Notification function send(required Account user) output=true
    {
        mumps = new lib.cfmumps.Mumps();
        mumps.open();


        
        if(mumps.lock("geodigraph", ["accounts", user.email, "notifyIndex"], 10)) {

            hasNotifyIndex = mumps.data("geodigraph", ["accounts", user.email, "notifyIndex"]).hasData;

            if(!hasNotifyIndex) {
                mumps.set("geodigraph", ["accounts", user.email, "notifyIndex"], 1);
                notifyIndex = 1;
            }
            else {
                notifyIndex = mumps.get("geodigraph", ["accounts", user.email, "notifyIndex"]);
                mumps.set("geodigraph", ["accounts", user.email, "notifyIndex"], notifyIndex + 1);
            }

            mumps.unlock("geodigraph", ["accounts", user.email, "notifyIndex"]);

            global = new lib.cfmumps.Global("geodigraph", ["accounts", user.email, "notifications", notifyIndex]);

            notification = {
                id: createUUID(),
                time: now(),
                caption: this.caption,
                message: this.message,
                link: this.link,
                icon: this.icon,                    
                delivered: 0,               
                read: 0
            };

            global.setObject(notification);

            module template="/modules/send_email.cfm" caption=this.caption message=this.message link=this.link icon=this.icon recipient=user.email;


        }
        else {
            throw("Could not acquire lock on notification index", "LockError");
        }
        

        mumps.close();

        return this;
    }

}