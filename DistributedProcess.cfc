component displayname="DistributedProcess" {

    public DistributedProcess function init(required string processId,                                                 
                                            struct opts) output=false
    {
        var DP_WAITNODE = 0;
        var DP_PROCESSING = 1;
        var DP_FAILED = 2;
        var DP_COMPLETE = 3;

        this.distributedProcessId = arguments.processId;

        if(isDefined("arguments.opts")) {

            // opts were passed in. this implies that we're creating a new DistributedProcess.

            var mumps = new lib.cfmumps.Mumps();
            mumps.open();

            var totalProcessors = mumps.get("geodigraph", ["dp", "count"]);

            lock scope="Application" timeout="10" {
                if(mumps.lock("geodigraph", ["dp", "current"], 10)) {
                    var processorNumber = mumps.get("geodigraph", ["dp", "current"]);

                    if(processorNumber < totalProcessors) {
                        processorNumber++;
                    }
                    else {
                        processorNumber = 1;
                    }

                    mumps.set("geodigraph", ["dp", "current"], processorNumber);

                }
                else {
                    throw("Unable to acquire database lock on distributed processing global");
                }

                mumps.unlock("geodigraph", ["dp", "current"]);
            }

            this.node = mumps.get("geodigraph", ["dp", "processors", processorNumber]);
            this.workingDirectory = expandPath("/pool/inbound/#this.node#")


            var global = new lib.cfmumps.Global("geodigraph", ["processes", this.distributedProcessId]);

            this.status = "DP_WAITNODE";
            this.pid = "";
            
            this.scriptName = arguments.opts.scriptName;
            this.scriptArgs = arguments.opts.scriptArgs;
            this.description = arguments.opts.description;
            this.layerId = arguments.opts.layerId;

            var dbObj = {
                status: "DP_WAITNODE",                                
                scriptName: this.scriptName,
                scriptArgs: this.scriptArgs,
                node: this.node,
                workingDirectory: this.workingDirectory,
                description: this.description,
                layerId: this.layerId
            };

            global.setObject(dbObj);            


            if(!directoryExists(this.workingDirectory)) {
                try {
                    directoryCreate(this.workingDirectory);
                }
                catch(any ex) {
                    throw(type="DistributedProcess", message="Error creating #this.workingDirectory#");
                }            
            }

            var jobFile = this.workingDirectory & "/" & this.distributedProcessId & ".job";

            var newline = chr(10);
            var output = this.scriptName & newline & this.scriptArgs & newline & this.description & newline;

            try {
                var fileObj = fileOpen(jobFile, "write");

                fileWrite(fileObj, output);
                fileClose(fileObj);
            }
            catch(any ex) {
                throw(type="DistributedProcess", message="Could not write #jobFile#");
            }

            global.close();
            mumps.close();


        }
        else {
            this.distributedProcessId = arguments.processId;

            var global = new lib.cfmumps.Global("geodigraph", ["processes", this.distributedProcessId]);
            var p = global.getObject();

            global.close();

            this.status = p.status;
            this.filePath = p.filePath;
            this.scriptName = p.scriptName;
            this.scriptArgs = p.scriptArgs;
            this.uploadDirectory = p.uploadDirectory;
            this.layerId = p.layerId;
        }

        return this;
    }

}