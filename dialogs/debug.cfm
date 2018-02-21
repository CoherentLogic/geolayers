<div class="modal inmodal" id="dlgDebug" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-bug modal-icon"></i>
                <h4 class="modal-title">Debug</h4>
                <small class="font-bold">Various debugging functionality.</small>
            </div>
            <div class="modal-body">
                <div class="form-group">
                        <label>Form Target IFRAME</label>
                        <iframe name="formTarget" id="formTarget"></iframe>                       
                    </div>
                <form method="post" action="dialogs/debug_submit.cfm" target="formTarget" id="dbgNotifyForm">
                    
                    <div class="form-group">
                        <label>Send a Notification</label> 
                        
                        <input type="text" name="dbgNotifyCaption" class="form-control" placeholder="Caption"><br>
                        <input type="text" name="dbgNotifyIcon" class="form-control" placeholder="Icon"><br>
                        <input type="text" name="dbgNotifyLink" class="form-control" placeholder="Link"><br>
                        <input type="text" name="dbgNotifyMessage" class="form-control" placeholder="Message"><br>
                        <label>Recipient <select name="dbgNotifyRecipient" id="dbgNotifyRecipient" size="1"><option value="foo">John Willis</option></select></label>

                     
                    </div>


                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onclick="submitFormSilent('dbgNotifyForm');">Submit</button>
            </div>
        </div>
    </div>
</div>