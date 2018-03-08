geodigraph = {
    // base config
    baseUrl: "",
    session: null,

    // poller config
    pollers: [],
    pollerTick: 3000,

    // notifications
    notifications: [],
    notificationCount: function () {

        var count = 0;

        for(notification in geodigraph.notifications) {
            var n = geodigraph.notifications[notification];

            if(!n.read) {
                count++;
            }
        }

        return count;
    },

    updateLayers: function() {
        $.get(geodigraph.baseUrl + "/modules/layers.cfm", function(data) {

            $("#layers").html(data);

            $('.i-checks').iCheck({
                checkboxClass: 'icheckbox_square-green',
                radioClass: 'iradio_square-green',
            });

            $(".layer-shown").on('ifChecked', function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];

                window.map.showLayer(layerId);
                
            });

            $(".layer-shown").on('ifUnchecked', function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];

                window.map.hideLayer(layerId);
                
            });

            $(".layer-center").on('click', function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];

                window.map.centerToLayer(layerId);
            });


            $(".opacity-up,.opacity-down").click(function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];

                if($(this).is(".opacity-up")) {                    
                    window.map.increaseLayerOpacity(layerId);
                }
                else {
                    window.map.decreaseLayerOpacity(layerId);
                }
            });


            $(".layer-up,.layer-down").click(function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];               

                if($(this).is(".layer-up")) {
                    map.layers[layerId].leafletLayer.bringToFront();
                    row.insertBefore(row.prev());
                }
                else {
                    map.layers[layerId].leafletLayer.bringToBack();
                    row.insertAfter(row.next());
                }
            });

            $(".edit-layer").click(function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];               

                editLayer(layerId);
            });

            $(".view-layer").click(function() {
                var row = $(this).parents("tr:first");
                var layerId = row.attr('id').split("_")[1];               

                viewLayer(layerId);
            })

        }); // end of handler for $.get()
    },

    // initialization
    init: function() {

        tokenWarningShown = false;

        initializeGis({
            baseUrl: geodigraph.baseUrl
        });

        geodigraph.updateLayers();

        var tokensPoller = new Poller("monitor user tokens", function() {

            $.get(geodigraph.baseUrl + "/modules/user_tokens.cfm", function(data) {

               var tokensAllocated = parseInt(data.tokensAllocated);
               var tokensOverbooked = parseInt(data.tokensOverbooked);
               var tokensTotal = parseInt(data.tokensTotal);

               var totalUsed = tokensAllocated + tokensOverbooked;

               if(totalUsed > tokensTotal) {
                if(!tokenWarningShown) {
                    toastr.warning('You are using more tokens than you have purchased! Please purchase at least ' + tokensOverbooked + ' tokens in order to upload.','Uploads Blocked');
                    tokenWarningShown = true;
                }
                $("#tokens-used").css("color", "red");
               }
               else {
                tokenWarningShown = false;
                $("#tokens-used").css("color", "");
               }

               $("#tokens-used").html(totalUsed);
               $("#tokens-total").html(tokensTotal);

            });

        });

        var range_slider = document.getElementById('geotiff_zoom_range');
        range_slider.innerHtml = "";
        
        noUiSlider.create(range_slider, {
            start: [ 17, 23 ],
            behaviour: 'drag',
            connect: true,
            step: 1,
            range: {
                'min':  0,
                'max':  31
            }
        });

        range_slider.noUiSlider.on('update', function (values, handle, unencoded, tap, positions) {
            $("#geotiff-zoom-min").html(parseInt(values[0]));
            $("#geotiff-zoom-max").html(parseInt(values[1]));
            $("#geoTiffMinZoom").val(parseInt(values[0]));
            $("#geoTiffMaxZoom").val(parseInt(values[1]));
        });

        range_slider = document.getElementById('base_zoom_range');
        range_slider.innerHtml = "";
        
        noUiSlider.create(range_slider, {
            start: [ 10, 25 ],
            behaviour: 'drag',
            connect: true,
            step: 1,
            range: {
                'min':  1,
                'max':  50
            }
        });

        range_slider.noUiSlider.on('update', function (values, handle, unencoded, tap, positions) {
            $("#base-zoom-min").html(parseInt(values[0]));
            $("#base-zoom-max").html(parseInt(values[1]));
            $("#baseLayerMinZoom").val(parseInt(values[0]));
            $("#baseLayerMaxZoom").val(parseInt(values[1]));            
        });

        var resizeHandler = function () {
            var heights = {
                header: $("#navbar").outerHeight(),
                footer: $("#footer").outerHeight()
            };

            var totalHeight = heights.header + heights.footer;            
            var windowHeight = $(window).height();
            var mapHeight = windowHeight - totalHeight;

            $("#map").height(mapHeight);

            window.map.leafletMap.invalidateSize(false);            
        };

        $(window).resize(resizeHandler);

        resizeHandler();


        var notificationsPoller = new Poller("retrieve notifications", function() {
            
            $.get(geodigraph.baseUrl + "/modules/notifications.cfm", function(notifications) {

                for(index in notifications) {
                    var n = notifications[index];                    
                    var notification = new GlNotification(n.id, n.time, n.icon, n.caption, n.message, n.link, n.delivered, n.read);
                    installNotification(notification);
                }                

            });
        });

        var notificationDeliveryPoller = new Poller("deliver notifications", function() {
            for(notification in geodigraph.notifications) {
                geodigraph.notifications[notification].deliver();
            }

            $("#notificationCount").html(geodigraph.notificationCount());
        });

        var layerRefreshPoller = new Poller("check for layer refresh", function() {
            $.get(geodigraph.baseUrl + "/modules/get_layer_refresh.cfm", function(data) {
                if(data.layerRefresh) {
                    geodigraph.updateLayers();
                    initializeLayers(window.map);
                }
            });
        });

        var sessionPoller = new Poller("retrieve session data", function() {
            $.get("/modules/get_login_session.cfm", function(data) {                

                if(data.success) {
                    geodigraph.session = data;

                    if(geodigraph.session.admin) {
                        $("#sb-user-name").html(geodigraph.session.name + " (Administrator)");
                    }
                    else {
                        $("#sb-user-name").html(geodigraph.session.name);
                    }
                    $("#sb-user-picture").attr("src", geodigraph.session.picture);
                }
                else {
                    geodigraph.session = null;
                }
            });  
        });

        installPoller(tokensPoller);
        installPoller(notificationsPoller);
        installPoller(notificationDeliveryPoller);
        installPoller(layerRefreshPoller);
        installPoller(sessionPoller);

        startPoll();
    },

    updateSelects: function() {
        var companySelects = ["#baseLayerExistingCompanies", "#geoTiffExistingCompanies", "#addUserCompany"];
        var userSelects = ["#baseLayerExistingUsers", "#geoTiffExistingUsers", "#dbgNotifyRecipient"];

        $.get(geodigraph.baseUrl + "/modules/users.cfm", function(users) {

            for(ctlIndex in userSelects) {
                $(userSelects[ctlIndex]).find("option").remove();

                for(userIndex in users) {
                    var user = users[userIndex];
                    var html = '<option value="' + user.email + '">' + user.firstName + ' ' + user.lastName + '</option>';

                    $(userSelects[ctlIndex]).append(html);
                }
            }

        });

        $.get(geodigraph.baseUrl + "/modules/companies.cfm", function(companies) {

            for(ctlIndex in companySelects) {
                $(companySelects[ctlIndex]).find("option").remove();

                for(companyIndex in companies) {
                    var company = companies[companyIndex];
                    var html = '<option value="' + company + '">' + company + '</option>';

                    $(companySelects[ctlIndex]).append(html);                    
                }
            }

        });
    }
};

function GlNotification(id, time, icon, caption, message, link, delivered, read)
{
    this.id = id;
    this.time = time;
    this.icon = icon;
    this.caption = caption;
    this.message = message;
    this.link = link;
    this.delivered = false;
    this.read = false;

    if(delivered > 0) this.delivered = true;
    if(read > 0) this.read = true;

    return this;
}

GlNotification.prototype.deliver = function() {

    if(!this.delivered) {

        var notifyOptions = {
            body: this.message,
            icon: "/img/geodigraph_icon.png",
        };

        if(Notification.permission === "granted") {
            var notify = new Notification(this.caption, notifyOptions);
        }
        else {
            Notification.requestPermission(function (permission) {
                if(permission === "granted") {
                    var notify = new Notification(this.caption, notifyOptions);
                }
            });
        }

        var html = '<li id="not_' + this.id + '"><a href="#' + this.link +'"><div><i class="fa ' + this.icon + ' fa-fw"></i> ' + this.caption;
        html += '<span class="pull-right text-muted small">' + this.time + '</span></div></a></li><li class="divider"></li>'

        $("#notifications").append(html);

        this.markDelivered();

    }


    return this;
}

GlNotification.prototype.markRead = function() {
    this.read = true;

    //TODO: mark on server

    return this;
}

GlNotification.prototype.markDelivered = function() {
    this.delivered = true;

    //TODO: mark on server

    return this;
}

function findNotification(id) 
{
    for(notification in geodigraph.notifications) {
        if(geodigraph.notifications[notification].id === id) {
            return geodigraph.notifications[notification];
        }
    }

    return false;
}

function installNotification(notification) {
    if(!findNotification(notification.id)) {
        geodigraph.notifications.push(notification);   
    }
    else {
        findNotification(notification.id).markDelivered();
    }
}

function showAlert(id) {
    console.log(id);
}


function Poller(name, func)
{
    this.func = func || function () {
        console.log("Misconfigured poller");
    };

    this.name = name || "Anonymous poller";
    this.enabled = true;

    return this;
}

Poller.prototype.run = function() {
    //console.log("Running poller " + this.name);
    
    if(this.enabled) {
        this.func();
    }
};

Poller.prototype.disable = function() { 
    console.log("Disabling poller " + this.name);

    this.enabled = false; 
};

Poller.prototype.enable = function() {
    console.log("Enabling poller " + this.name);

    this.enabled = true;
};

function installPoller(poller)
{
    geodigraph.pollers.push(poller);
}

function startPoll() {
    setInterval(function() {
        for(poller in geodigraph.pollers) {
            geodigraph.pollers[poller].run();
        }
    }, geodigraph.pollerTick);
}



function submitFormSilent(id, hideDiv) 
{
    console.log("Submitting form " + id);
    $("#" + id).submit();

    if(hideDiv) {
        $("#" + hideDiv).hide();
    }
}

function addGeoTiffLayer()
{
    $("#geoTiffFormError").hide();
    $("#geoTiffFormBody").show();

    document.getElementById("frmAddGeoTiffLayer").reset();

    $("#geoTiffFile").on("change", function(event) {
        let file = $(this)[0].files[0];

        $("#geotiff-upload-controls").show();
        $("#geotiff-file-size").html(file.size);
    });


    $("#geoTiffLayerId").val(uuidv1());
    $("#geoTiffMinZoom").val(17);
    $("#geoTiffMaxZoom").val(23);
    $("#geotiff-upload-controls").hide();
    $("#dlgAddGeoTIFF").modal();
}

function beginDeleteLayer(id)
{
    $("#delete-layer-name-confirm").val("");
    $("#delete-layer-error").html("");
    $("#delete-layer-id").val(id);
    let layerName = $("#editLayerName").val();

    $("#delete-layer-name").val(layerName);
    $("#delete-layer-display").html(layerName);

    $("#btn-delete-layer-confirm").on('click', function(event) {

        let confirmedValue = $("#delete-layer-name-confirm").val();

        if(confirmedValue == layerName) {
            deleteLayer(id);
        }
        else {
            $("#delete-layer-error").html("Layer names do not match.");
        }

    });

    $("#dlgConfirmDeleteLayer").modal();
}

function deleteLayer(id)
{

    console.log("Deleting layer " + id);

    var url = "/modules/delete_layer.cfm?id=" + id;
    $.get(url, function(data) {
        if(data.success) {            
            $("#dlgEditLayer").modal('hide');     
            $("#dlgConfirmDeleteLayer").modal('hide');       
        }
        else {
            $("#delete-layer-error").html(data.message);
        }
    });
}

function addBaseLayer()
{

    document.getElementById("frmAddBaseLayer").reset();

    $("#baseLayerMinZoom").val(10);
    $("#baseLayerMaxZoom").val(25);
    $("#baseLayerId").val(uuidv1()); 
    $("#dlgAddBaseLayer").modal();
}

function submitGeoTiffLayer()
{
    $("#layers-tbody").append('<tr><td><i class="fa fa-upload"></i></td><td><input type="checkbox" class="ichk-uploading"></td><td colspan="3">' + $("#geoTiffLayerName").val() + ' (Uploading)</td></tr>');
    $(".ichk-uploading").iCheck();
    $(".ichk-uploading").iCheck('disable');    
    
    var file = $("#geoTiffFile")[0].files[0];
    var fh = new FileHandler(file, {
        uploadHandler: "dialogs/add_geotiff_layer_submit.cfm",
        progressBarId: "geotiff-upload-progress",
        timeout: 999999,
        formFields: [
            "geoTiffLayerId",
            "geoTiffLayerName",
            "geoTiffAttribution",
            "geoTiffCopyright",
            "geoTiffMinZoom",
            "geoTiffMaxZoom"
        ],
        success: function(data) {
            if(data.success) {
                $("#dlgAddGeoTIFF").modal('hide');
            }
            else {
                $("#geoTiffError").html(data.message);

                $("#geoTiffFormBody").hide();
                $("#geoTiffFormError").show();                
            }
        },
        error: function(error) {
            console.log(error);
            alert(error.message);
        }
    });

    $("#geotiff-file-size").html(fh.size());

    fh.upload();
}

function addShare(event)
{
    var id = $("#editLayerId").val();
    var url = '/modules/share_layer.cfm?layerId=' + id + '&email=' + escape(event.item);

    $.get(url, function(data) {
        if(!data.success) {
            $('#editShares').off('beforeItemRemove');
            $("#editShares").tagsinput('remove', event.item);
            $("#editShares").on('beforeItemRemove', removeShare);
            $("#layerShareError").html(data.message);            
        }
    });
}

function removeShare(event)
{
    var id = $("#editLayerId").val();
    var url = '/modules/unshare_layer.cfm?layerId=' + id + '&email=' + escape(event.item);

    $.get(url, function(data) {
        if(!data.success) {
            $('#editShares').off('beforeItemAdd');
            $("#editShares").tagsinput('add', event.item);
            $('#editShares').on('beforeItemAdd', addShare);
            $("#layerShareError").html(data.message);           
        }
    });    
}

function viewProfile(email) 
{

}

var changeTimer = false;
function editProfile()
{
    $("#ep-firstname").val(geodigraph.session.firstName);
    $("#ep-lastname").val(geodigraph.session.lastName);
    $("#ep-zip").val(geodigraph.session.zip);
    $("#ep-picture").attr("src", geodigraph.session.picture);

    $(".profile-edit-control").on("keyup", function(event) {
        if(changeTimer) clearTimeout(changeTimer);
        changeTimer = setTimeout(function() {
            var url = '/modules/set_profile_info.cfm?firstName=' + escape($("#ep-firstname").val());
            url += '&lastName=' + escape($("#ep-lastname").val());
            url += '&zip=' + escape($("#ep-zip").val());            

            $.get(url, function(data) {
                if(!data.success) {
                    alert(data.message);
                }
            });

        }, 300);
    });

    attachFileHandler("ep-picture-upload", {
        uploadHandler: "dialogs/edit_profile_submit.cfm",
        progressBarId: "ep-picture-progress",
        timeout: 999999,
        success: function(data) {
            console.log(data);
            $("#ep-picture").attr("src", "");
            $("#sb-user-picture").attr("src", "");
            $("#ep-picture").attr("src", data.newPicture);
            $("#sb-user-picture").attr("src", data.newPicture);
        },
        error: function(error) {
            console.log(error);
        }
    });


    $("#dlgEditProfile").modal();
}

function viewLayer(id)
{
    let layer = new Layer(id);

    let onSuccess = function(data) {

        let layerType = "";

        $("#vl-initial-tab").trigger('click');

        switch(data.renderer) {
            case 'geotiff':
                layerType = '<i class="fa fa-picture-o"></i> GeoTIFF Imagery';

                $("#vl-tab-basic").show();
                $("#vl-tab-geography").show();
                $("#vl-tab-sharing").show();
                $("#vl-tab-storage").show();

                $("#vl-original-image").attr("href", "/pool/inbound/staging/" + id + ".tif");

                break;
            case 'base':
                layerType = '<i class="fa fa-map"></i> Basemap Tiles';

                $("#vl-tab-basic").show();
                $("#vl-tab-geography").hide();
                $("#vl-tab-sharing").show();
                $("#vl-tab-storage").hide();
                
                break;
        }

        let zoomRange = "";
        if(data.minZoom === data.maxZoom) {
            zoomRange = data.minZoom + " Only";
        }
        else {
            zoomRange = data.minZoom + "-" + data.maxZoom;
        }

        $(".vl-layer-name").html(data.name);
        $(".vl-layer-type").html(layerType);
        $("#vl-layer-timestamp").html(data.created);
        $("#vl-layer-zoomrange").html(zoomRange);
        $("#vl-layer-attribution").html(data.attribution);
        $("#vl-layer-copyright").html(data.copyright || "None");

        if(data.renderer == "geotiff") {
            let min = L.latLng(data.miny, data.minx);
            let max = L.latLng(data.maxy, data.maxx);
            let bounds = L.latLngBounds(min, max);
            let centroid = bounds.getCenter();

            let srs = data.srs.split(":");

            let provider = srs[0];
            let code = srs[1];

            let srsVal = "";
            if(provider === "EPSG") {
                srsVal = '<a href="https://epsg.io/' + code + '" target="_blank">' + data.srs + '</a>';
            }
            else {
                srsVal = '<a href="http://spatialreference.org/ref/' + provider + '/' + code + '" target="_blank">' + data.srs + '</a>';
            }

            $("#vl-layer-srs").html(srsVal);
            $("#vl-layer-nw").html(data.miny + ", " + data.minx);
            $("#vl-layer-se").html(data.maxy + ", " + data.maxx);        
            $("#vl-layer-centroid").html(centroid.lat + ", " + centroid.lng);



            $("#vl-tile-thumbnail").attr("src", "/pool/thumbnails/" + id + ".jpg");

            let imageTokens = parseInt(data.imageTokens);
            let tileTokens = parseInt(data.tileTokens);
            let totalTokens = imageTokens + tileTokens;
            let tokenSize = parseInt(data.tokenSize);

            let imageMiB = (imageTokens * tokenSize) / 1048576;
            let tileMiB = (tileTokens * tokenSize) / 1048576;
            let totalMiB = (totalTokens * tokenSize) / 1048576;


            $("#vl-image-tokens").html(imageTokens + " tokens/" + imageMiB + " MiB");
            $("#vl-tile-tokens").html(tileTokens + " tokens/" + tileMiB + " MiB");
            $("#vl-total-tokens").html(totalTokens + " tokens/" + totalMiB + " MiB");

            let chartData = {
                labels: ["Original Image", "Tileset"],
                datasets: [{
                    data: [data.imageTokens, data.tileTokens],
                    backgroundColor: ["#a3e1d4", "#b5b8cf"]
                }]
            };

            let ctx = document.getElementById("vl-storage-chart").getContext("2d");
            new Chart(ctx, {type: 'doughnut', data: chartData, options: {responsive: true}});
        }        

        if(data.public) {
            $("#vl-layer-public").html("Yes");
        }
        else {
            $("#vl-layer-public").html("No");
        }

        if(data.default) {
            $("#vl-layer-default").html("Yes");
        }
        else {
            $("#vl-layer-default").html("No");
        }

        $("#vl-shares-container").html('<h3>Shared With</h3><ul id="vl-shares"></ul>');

        for(index in data.shares) {
            share = data.shares[index];

            let account = new Account(share);
            account.get().then(function(account) {
                if(account.name !== " ") {
                    $("#vl-shares").append("<li>" + account.name + "</li>");
                }
                else {
                    $("#vl-shares").append("<li>" + account.email + "</li>");
                }
            },
            function(error) {

            });
        }

        let contributor = new Account(data.contributor);

        contributor.get().then(function(account) {
            $("#vl-contributor-picture").attr("src", account.picture || "/img/placeholder.png");
            $("#vl-contributor-name").html(account.name);
        },
        function(error) {
            $("#vl-contributor-picture").attr("src", "/img/placeholder.png");
            $("#vl-contributor-name").html("Unknown");
        });

        $("#dlgViewLayer").modal();
    };

    let onError = function(error) {
        console.log(error);
    };

    layer.get().then(onSuccess, onError);
}

function editLayer(id)
{
    $("#btn-delete-layer").on('click', function(e) {
        beginDeleteLayer(id);
    });

    if(geodigraph.session.admin) {
        $("#editLayerAdmin").show();
    }
    else {
        $("#editLayerAdmin").hide();
    }

    $(".layer-edit-control").on("keyup", function(event) {
        if(changeTimer) clearTimeout(changeTimer);
        changeTimer = setTimeout(function() {
            var url = '/dialogs/edit_layer_submit.cfm?layerId=' + $("#editLayerId").val();
            url += '&name=' + escape($("#editLayerName").val());
            url += '&attribution=' + escape($("#editAttribution").val());
            url += '&copyright=' + escape($("#editCopyright").val());

            $.get(url, function(data) {
                if(!data.success) {
                    $("#layerEditError").html(data.message);
                }
            });

        }, 300);
    });

    $('#editShares').tagsinput({
        tagClass: 'label label-primary'
    });

    $('#editShares').off('beforeItemAdd');
    $('#editShares').off('beforeItemRemove');

    $('#editShares').tagsinput('removeAll');

    $.get('/modules/get_layer.cfm?layerId=' + id, function(data) {
        
        if(data.success) {

            $('#make-layer-default').iCheck({
                checkboxClass: 'icheckbox_square-green',
                radioClass: 'iradio_square-green',
            });
            
            $('#make-layer-default').off('ifChecked');
            $('#make-layer-default').off('ifUnchecked');


            if(data.isDefault) {
                $('#make-layer-default').iCheck('check');
            }
            else {
                $('#make-layer-default').iCheck('uncheck');
            }


            if(geodigraph.session.admin) {                
                $('#make-layer-default').on('ifChecked', function(event) {
                    var url = "/modules/set_layer_default.cfm?layerId=" + id + "&default=1";
                    $.get(url, function(data) {
                        if(!data.success) {
                            alert(data.message);
                        }
                    });
                });

                $('#make-layer-default').on('ifUnchecked', function(event) {
                    var url = "/modules/set_layer_default.cfm?layerId=" + id + "&default=0";                    
                    $.get(url, function(data) {
                        if(!data.success) {
                            alert(data.message);
                        }
                    });                    
                });
            }
            else {
                $('#make-layer-default').iCheck('disable');
            }


            $("#editAttribution").val(data.attribution);
            $("#editCopyright").val(data.copyright);
            $("#editLayerId").val(id);
            $("#editLayerName").val(data.name);

            if(data.originalImage) {
                $("#editGeotiffProps").show();
                $("#originalImage").html('<a href="' + data.originalImage + '" target="about:blank">Download Original Image</a>');
            }
            else {
                $("#editGeotiffProps").hide();
            }

            var shareList = "";
            for(index in data.shares) {
                $("#editShares").tagsinput('add', data.shares[index].email);
            }

            $('#editShares').on('beforeItemAdd', addShare);
            $("#editShares").on('beforeItemRemove', removeShare);


            $("#dlgEditLayer").modal();
        }
        else {
            alert(data.message);
        }
    });
}