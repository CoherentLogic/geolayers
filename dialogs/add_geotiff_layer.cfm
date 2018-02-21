<div class="modal inmodal" id="dlgAddGeoTIFF" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-picture-o modal-icon"></i>
                <h4 class="modal-title">Add GeoTIFF Layer</h4>
                <small class="font-bold">This will add a GeoTIFF image overlay to the map.</small>
            </div>
            <div class="modal-body">
                <form target="formTarget" action="dialogs/add_geotiff_layer_submit.cfm" method="post" id="frmAddGeoTiffLayer" enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Layer properties</label>
                        <input type="text" name="geoTiffLayerId" id="geoTiffLayerId" value="" style="display:none;">
                        <input type="text" name="geoTiffLayerName" id="geoTiffLayerName" class="form-control" placeholder="Layer name"><br>
                        <input type="text" name="geoTiffAttribution" class="form-control" placeholder="Attribution"><br> 
                        <input type="text" name="geoTiffCopyright" class="form-control" placeholder="Copyright"><br> 
                        <input type="text" name="geoTiffMinZoom" class="form-control" placeholder="Minimum zoom level"><br> 
                        <input type="text" name="geoTiffMaxZoom" class="form-control" placeholder="Maximum zoom level"><br>                      
                    </div>
                    <div class="form-group">
                        <label>GeoTIFF file</label>
                        <input type="file" name="geoTiffFile" class="form-control" placeholder="GeoTIFF file">
                    </div>
                    <div class="form-group">
                        <label>Share with</label> 

                        <div class="radio"><label><input type="radio" name="addGeoTiffTo" value="allUsers" selected="selected"> All users</label></div>                    


                        <div class="radio"><label><input type="radio" name="addGeoTiffTo" value="existingUser"> Existing user <select name="geoTiffExistingUsers" id="geoTiffExistingUsers" size="1"></select></label></div>

                        <cfif session.admin>
                            <div class="radio"><label><input type="radio" name="addGeoTiffTo" value="existingCompany"> Existing company <select name="geoTiffExistingCompanies" id="geoTiffExistingCompanies" size="1"></select></label></div>
                        </cfif>
                        

                    </div>
                    <div class="form-group">
                        <label>Personal layer display</label>
                        <cfif session.admin>
                            <div class="checkbox">
                                <label><input type="checkbox" name="addGeoTiffToSelectedPersonal"> Add to selected group's personal layers</label>
                            </div>
                        </cfif>
                        <div class="checkbox">
                            <label><input type="checkbox" name="addGeoTiffToMyPersonal"> Add to my personal layers</label>
                        </div>
                        <br>
                        <cfif session.admin>
                            <div class="checkbox">
                                <label><input type="checkbox" name="addGeoTiffToAllNewAccounts"> Add to all new user accounts</label>
                            </div>              
                        </cfif>          
                    </div>


                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="submitGeoTiffLayer();">Submit</button>
            </div>
        </div>
    </div>
</div>