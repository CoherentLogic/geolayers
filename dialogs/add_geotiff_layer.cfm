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
                <div id="geoTiffFormBody" style="display: block;">
                    <form target="formTarget" action="dialogs/add_geotiff_layer_submit.cfm" method="post" id="frmAddGeoTiffLayer" enctype="multipart/form-data">
                        <div class="form-group">
                            <label>Layer properties</label>
                            <input type="text" name="geoTiffLayerId" id="geoTiffLayerId" value="" style="display:none;">
                            <input type="text" name="geoTiffLayerName" id="geoTiffLayerName" class="form-control" placeholder="Layer name"><br>
                            <input type="text" name="geoTiffAttribution" id="geoTiffAttribution" class="form-control" placeholder="Attribution"><br> 
                            <input type="text" name="geoTiffCopyright" id="geoTiffCopyright" class="form-control" placeholder="Copyright"><br> 
                            <div style="display:none;">
                            <input type="text" name="geoTiffMinZoom" id="geoTiffMinZoom" class="form-control" placeholder="Minimum zoom level"><br> 
                            <input type="text" name="geoTiffMaxZoom" id="geoTiffMaxZoom" class="form-control" placeholder="Maximum zoom level"><br> 
                            </div>                     
                        </div>
                        <div class="form-group">
                            <label>Zoom range</label>
                            <div id="geotiff_zoom_range"></div>
                        </div>
                        <div class="form-group">
                            <label>GeoTIFF file</label>
                            <input type="file" name="geoTiffFile" id="geoTiffFile" class="form-control" placeholder="GeoTIFF file">
                            <div id="geotiff-upload-controls" style="display:none; margin-top: 8px;">
                                <label>File size:</label> <span id="geotiff-file-size"></span>
                                <div id="geotiff-upload-progress" class="filehandler-progress-bar">
                                    <div class="progress-bar"></div>
                                    <div class="status">0%</div>
                                </div>
                            </div>
                        </div>
                        
                    </form>
                </div>
                <div id="geoTiffFormError" class="alert alert-danger" style="display: none;">
                    <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                    <span class="sr-only">Error:</span>
                    <strong>
                    <span id="geoTiffError"></span>
                    </strong>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="submitGeoTiffLayer();">Submit</button>
            </div>
        </div>
    </div>
</div>