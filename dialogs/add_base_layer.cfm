<div class="modal inmodal" id="dlgAddBaseLayer" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-map-o modal-icon"></i>
                <h4 class="modal-title">Add Base Layer</h4>
                <small class="font-bold">This will add a base tile layer to the map.</small>
            </div>
            <div class="modal-body">
                <form target="formTarget" action="dialogs/add_base_layer_submit.cfm" method="post" id="frmAddBaseLayer" enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Layer properties</label>
                        <input type="text" name="baseLayerId" id="baseLayerId" value="" style="display:none;">
                        <input type="text" name="baseLayerName" class="form-control" placeholder="Name"> <br>

                        <input type="text" name="baseLayerAttribution" class="form-control" placeholder="Attribution"><br>

                        <input type="text" name="baseLayerCopyright" class="form-control" placeholder="Copyright"><br>

                        <input type="text" name="baseLayerMinZoom" class="form-control" placeholder="Minimum zoom level"><br>

                        <input type="text" name="baseLayerMaxZoom" class="form-control" placeholder="Maximum zoom level"><br>

                        <input type="text" name="baseLayerUrl" class="form-control" placeholder="URL">                        
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="submitFormSilent('frmAddBaseLayer');" data-dismiss="modal">Submit</button>
            </div>
        </div>
    </div>
</div>