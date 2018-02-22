<cfscript>

//for(i = 1; i < 5; i++) {
    id = createUUID();
    p = new DistributedProcess(id, {
        scriptName: "/home/geodigraph/webapps/maps/bin/maketiles",
        scriptArgs: "-i 38c43310-15bb-11e8-afa7-312d3d418c44 -f /home/geodigraph/webapps/maps/pool/raw/38c43310-15bb-11e8-afa7-312d3d418c44.tif -m 17 -M 18",
        description: "Testing the DistributedProcess API"
    });

    writeOutput("This process will run on node #p.node#<br>");
//}

</cfscript>