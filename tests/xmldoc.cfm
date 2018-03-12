<cfscript>
xmlDoc = xmlParse(fileRead("/pool/tiles/b111f2e0-20f5-11e8-aa54-45765dfc7668/tilemapresource.xml"));

boundingBox = xmlDoc.TileMap.SRS;

writeDump(boundingBox);


//writeDump(xmlDoc);

</cfscript>