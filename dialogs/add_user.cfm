<div class="modal inmodal" id="dlgAddUser" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-user-plus modal-icon"></i>
                <h4 class="modal-title">Add User</h4>
                <small class="font-bold">This will add a new user account.</small>
            </div>
            <div class="modal-body">
                <form>
                    <div class="form-group">
                        <label>User properties</label>

                        <div class="form-group">
                            <input type="email" class="form-control" placeholder="Email address" required="" name="addUserEmail">
                        </div>
                        <div class="form-group">
                            <input type="text" class="form-control" placeholder="First name" required="" name="addUserFirstName">
                        </div>
                        <div class="form-group">
                            <input type="text" class="form-control" placeholder="Last name" required="" name="addUserLastName">
                        </div>

                        <div class="form-group">
                            <input type="text" class="form-control" placeholder="ZIP code" required="" name="zip">
                        </div>

                        <div class="form-group">
                            <label>Company</label>
                            <select name="addUserCompany" id="addUserCompany" class="form-control" size="1">
                                <option value="">Test company</option>
                            </select>
                        </div>

                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary">Submit</button>
            </div>
        </div>
    </div>
</div>