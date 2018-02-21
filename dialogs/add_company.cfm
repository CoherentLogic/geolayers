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
                    
                    <div class="form-group">
                        <label>Company properties</label>
                        <input type="text" name="addCompanyName" class="form-control" placeholder="Company name">
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="submitFormSilent('frmAddCompany');">Submit</button>
            </div>
        </div>
    </div>
</div>