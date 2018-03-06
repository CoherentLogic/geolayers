<div class="modal inmodal" id="dlgAddCompany" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-building-o modal-icon"></i>
                <h4 class="modal-title">Add Company</h4>
                <small class="font-bold">This will add a new company.</small>
            </div>
            <div class="modal-body">
                <form target="formTarget" action="dialogs/add_company_submit.cfm" method="post" id="frmAddCompany">
                    <div class="alert alert-danger" style="display: none;">
                        <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                        <span class="sr-only">Warning:</span>
                        <strong>
                            <span>Deleting a layer CANNOT BE UNDONE!<br><br>Please be absolutely sure that you want to do this.</span>
                        </strong>
                    </div>

                    <div class="form-group">
                        <label>Please enter the complete name of the layer to confirm deletion</label>
                        <input type="text" id="delete-layer-name-confirm" class="form-control" placeholder="Enter the name of the layer here">
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="delete-layer-btn">Delete Layer</button>
            </div>
        </div>
    </div>
</div>