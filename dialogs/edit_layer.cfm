<div class="modal inmodal" id="dlgEditLayer" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-edit modal-icon"></i>
                <h4 class="modal-title">Edit Layer</h4>
                <small class="font-bold">Edit the properties of a layer.</small>
            </div>
            <div class="modal-body">
                <form target="formTarget" action="dialogs/edit_layer_submit.cfm" method="post" id="frmEditLayer" enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Properties</label>
                        <input type="text" name="editLayerId" id="editLayerId" value="" style="display:none;">
                        <input type="text" name="editLayerName" id="editLayerName" class="form-control layer-edit-control" placeholder="Layer name"><br>
                        <input type="text" name="editAttribution" id="editAttribution" class="form-control layer-edit-control" placeholder="Attribution"><br> 
                        <input type="text" name="editCopyright" id="editCopyright" class="form-control layer-edit-control" placeholder="Copyright"><br> 
                        <span id="layerEditError" style="color: red;"></span>
                    </div>
                    <div class="form-group" id="editGeotiffProps" style="display: none;">
                        <label>GeoTIFF Properties</label><br>
                        <span id="originalImage"></span>
                    </div>                   
                    <div class="form-group">
                        <label>Shared with</label><br>
                        <input style="width: 540px !important;" class="tagsinput form-control" id="editShares" type="text" value="" placeholder="Type an e-mail address to share this layer"/><br>
                        <span id="layerShareError" style="color: red;"></span>
                        <br>
                        <div id="editLayerAdmin">                            
                            <label><input type="checkbox" id="make-layer-default"> Deploy to all new accounts</label>                     
                        </div>
                    </div>                  
                    <div class="form-group">
                        <label>Delete layer</label>
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <h3>Please note that deleting a layer <strong>cannot be undone!</strong></h3>
                                <button type="button" class="btn btn-danger" id="btn-delete-layer">Delete Layer</button>
                            </div>
                        </div>
                    </div>                    
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>                
            </div>
        </div>
    </div>
</div>