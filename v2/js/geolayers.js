geodigraph = {
    // base config
    baseUrl: "/v2",

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
        });
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

        installPoller(diskSpacePoller);
        installPoller(notificationsPoller);
        installPoller(notificationDeliveryPoller);
        installPoller(layerRefreshPoller);

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
            icon: "/v2/img/geodigraph_icon.png",
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
    geodigraph.updateSelects();
    $("#geoTiffLayerId").val(uuidv1());
}

function addBaseLayer()
{
    geodigraph.updateSelects();
    $("#baseLayerId").val(uuidv1());
}

function submitGeoTiffLayer()
{
    $("#layers-tbody").append('<tr><td><i class="fa fa-upload"></i></td><td><input type="checkbox" id="ichk-uploading"></td><td colspan="3">' + $("#geoTiffLayerName").val() + ' (Uploading)</td></tr>');
    $("#ichk-uploading").iCheck();
    $("#ichk-uploading").iCheck('disable');    
    submitFormSilent('frmAddGeoTiffLayer');
}