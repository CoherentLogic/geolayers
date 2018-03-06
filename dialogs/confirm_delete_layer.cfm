<div class="modal inmodal" id="dlgConfirmDeleteLayer" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-trash modal-icon"></i>
                <h4 class="modal-title">Delete Layer</h4>
                <small class="font-bold">Confirm deletion of layer</small>
            </div>
            <div class="modal-body">
                <form>
                    <input type="hidden" id="delete-layer-id">
                    <input type="hidden" id="delete-layer-name">
                    <div class="alert alert-danger">
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                        <span class="sr-only">Warning:</span>
                        <strong>
                            <span>Deleting a layer <em>CANNOT BE UNDONE,</em> and will also cause the users with whom the layer has been shared to lose access to that layer.<br><br>Please be <em>absolutely sure</em> you want to delete <span id="delete-layer-display"></span> before continuing.</span>
                        </strong>
                    </div>
                    <div class="form-group">                        
                        <label>Enter the full name of the layer to confirm</label>
                        <input type="text" id="delete-layer-name-confirm" class="form-control" placeholder="Layer name">
                        <span id="delete-layer-error" style="color: red; font-weight: bold;"></span>
                    </div>
            </form>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary" id="btn-delete-layer-confirm">Delete Layer</button>
        </div>
    </div>
</div>
</div>