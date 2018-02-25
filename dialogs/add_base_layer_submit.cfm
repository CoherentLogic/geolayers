<cfdump var="#form#">
<cfscript>

    layer = new BaseLayer(form.baseLayerId, {
        name: form.baseLayerName,
        url: form.baseLayerUrl,
        attribution: form.baseLayerAttribution,
        copyright: form.baseLayerCopyright,
        minZoom: form.baseLayerMinZoom,
        maxZoom: form.baseLayerMaxZoom,
        contributor: session.account.email
    });

    layer.grantUserAccess(session.account);
    layer.share(session.account, true, 1, 100);                   


</cfscript>
