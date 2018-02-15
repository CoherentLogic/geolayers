
<form id="addLayer" method="post" action="addlayer_sub.cfm" enctype="multipart/form-data" target="upload-target">
    <cfoutput>
	<input type="hidden" name="layerid" id="layerid" value="#CreateUUID()#">
        <input type="hidden" name="customerid"  id="customerid" value="">
    </cfoutput>
    <div class="form-group">
	<label for="file">GeoTIFF File</label>
	<input type="file" class="form-control" id="file" name="file">
    </div>
    <div class="form-group">
	<label for="email">Customer E-Mail</label>
	<input type="email" class="form-control" id="email" name="email">
    </div>
    <div class="form-group">
	<label for="customer-name">Customer Name</label>
	<input type="text" class="form-control" id="customer-name" name="customername">
    </div>
    <div class="form-group">
	<label for="project-name">Project Name (this will be the map title)</label>
	<input type="text" class="form-control" id="project-name" name="projectname">
    </div>
    
    <button class="btn btn-primary" type="submit" id="addLayerSub">Add Layer</button>
</form>
