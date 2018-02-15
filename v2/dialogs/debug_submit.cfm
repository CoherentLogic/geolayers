 <!---<input type="text" name="dbgNotifyCaption" class="form-control" placeholder="Caption"><br>
                        <input type="text" name="dbgNotifyIcon" class="form-control" placeholder="Icon"><br>
                        <input type="text" name="dbgNotifyLink" class="form-control" placeholder="Link"><br>
                        <input type="text" name="dbgNotifyMessage" class="form-control" placeholder="Message"><br>
                        <label>Recipient <select name="dbgNotifyRecipient" id="dbgNotifyRecipient" size="1"><option value="foo">John Willis</option></select></label>
--->

<cfscript>
    notification = new Notification({
        caption: form.dbgNotifyCaption,
        message: form.dbgNotifyMessage,
        link: form.dbgNotifyLink,
        icon: form.dbgNotifyIcon
    });

    user = createObject("account");
    user.open(form.dbgNotifyRecipient);

    notification.send([user]);
</cfscript>
<cfdump var="#form#">