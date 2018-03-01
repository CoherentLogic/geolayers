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

        }); // end of handler for $.get()
    },

    // initialization
    init: function() {

        initializeGis({
            baseUrl: geodigraph.baseUrl
        });

        geodigraph.updateLayers();

        var diskSpacePoller = new Poller("monitor disk space", function() {

            $.get(geodigraph.baseUrl + "/modules/disk_space.cfm", function(data) {

                $("#disk-usage-pct").html(data.percentageUsed);

                var cpuLoad = parseInt((data.load * 100) / data.cpuCount);

                $("#cpu-load").html(cpuLoad + "%");

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

                    $("#sb-user-name").html(geodigraph.session.name);
                    $("#sb-user-picture").attr("src", geodigraph.session.picture);
                }
                else {
                    geodigraph.session = null;
                }
            });  
        });

        installPoller(diskSpacePoller);
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
    document.getElementById("frmAddGeoTiffLayer").reset();

    $("#geoTiffFile").on("change", function(event) {
        let file = $(this)[0].files[0];

        $("#geotiff-file-size").html(file.size);
    });


    $("#geoTiffLayerId").val(uuidv1());
    $("#geoTiffMinZoom").val(17);
    $("#geoTiffMaxZoom").val(23);
    $("#dlgAddGeoTIFF").modal();
}

function addBaseLayer()
{

    document.getElementById("dlgAddBaseLayer").reset();

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
            $("#dlgAddGeoTIFF").modal('hide');
        },
        error: function(error) {
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

function editLayer(id)
{
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