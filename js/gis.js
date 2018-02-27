var writeBackQueue = {};
var writeBackDequeueing = false;


function initializeGis(opts) 
{
    window.map = new GlMap(opts, function(m) {
       initializeLayers(m); 
    });

    setInterval(function() {
        

        for(id in writeBackQueue) {
            console.log("writeback: dequeueing " + id + " (writeback url = '" + writeBackQueue[id] + "')");

            $.get(writeBackQueue[id], function() {
                writeBackDequeueing = true;
                delete writeBackQueue[id];
                writeBackDequeueing = false;
            });

        }

        
    }, 5000);
}

function queueUpdate(update)
{
    if(!writeBackDequeueing) {
        writeBackQueue[update.id] = update.url; 
    }
}

function initializeLayers(m) {

    if(window.map.leafletMap) {
        window.map.leafletMap.eachLayer(function(layer) {
            window.map.leafletMap.removeLayer(layer);
        });
        
        m.layers = {};
    }

    $.get("/modules/layers.cfm?json=1", function(layers) {
        
        for(id in layers) {

            var l = {};           
            var opacity = null;            

            if(layers[id].layer.renderer === 'parcel') {
                //TODO: parcel layers
            }
            else {
                switch(layers[id].layer.renderer) {
                    case 'base':
                        l.url = layers[id].layer.url;
                        l.tms = false;                    
                        break;
                    case 'geotiff':
                        console.log(m.opts.baseUrl);
                        l.url = 'https://maps.geodigraph.com' + m.opts.baseUrl + '/pool/tiles/' + id + '/{z}/{x}/{y}.png';
                        l.tms = true;
                        break;                    
                }

                opacity = layers[id].properties.opacity;
                l.opacity = opacityPctToDecimal(opacity);

                l.id = id;
                l.attribution = layers[id].layer.attribution || "&copy; Geodigraph";
                l.copyright = layers[id].layer.copyright || "";
                l.minZoom = layers[id].layer.minZoom || 9;
                l.maxZoom = layers[id].layer.maxZoom || 23; 
                l.errorTileUrl = "https://geolayers.geodigraph.com/img/no_tile.png";

                m.layers[id] = {
                    opacity: opacity,
                    prevOpacity: opacity,
                    leafletLayer: L.tileLayer(l.url, l)
                };

                
                m.layers[id].leafletLayer.addTo(map.leafletMap);
               
                m.layers[id].leafletLayer.setZIndex(layers[id].properties.zIndex);
                
            }

            var params = getAllUrlParams();
            
            if(params.showlayer) {     
                setTimeout(function() {           
                    m.centerToLayer(params.showlayer);
                }, 2000);
            }
            else {
                $.get("/modules/get_map_position.cfm", function(position) {
                    var pos = L.latLng(position.lat, position.lng);                    
                    m.leafletMap.setView(pos, position.zoom);
                });
            }
        }
    });
}

function GlMap(opts, done)
{
    var self = this;

    this.opts = opts;
    this.leafletMap = L.map('map').setView([32.3199, -106.7637], 17);
    this.layers = {};  

    var mapPosChanged = function(e) {

        var center = self.leafletMap.getCenter();
        var zoom = self.leafletMap.getZoom();


        queueUpdate({
            url: "/modules/set_map_position.cfm?lat=" + center.lat + "&lng=" + center.lng + "&zoom=" + zoom,
            id: "updateMapPosition"
        });
    };

    this.leafletMap.on('moveend', mapPosChanged);
    this.leafletMap.on('zoomend', mapPosChanged);  

    this.measureControl = new L.Control.Measure();
    this.measureControl.addTo(this.leafletMap);

    if(done) done(this);
    
    return this;
}



GlMap.prototype.hideLayer = function(layerId) {
    this.setLayerOpacity(layerId, 0);
};

GlMap.prototype.showLayer = function(layerId) {
    this.setLayerOpacity(layerId, this.layers[layerId].prevOpacity);
};

GlMap.prototype.centerToLayer = function(layerId) {
    var self = this;

    $.get("/pool/tiles/" + layerId + "/tilemapresource.xml", function(data) {
        xml = $(data);
        bbox = xml.find("BoundingBox");

        minx = bbox.attr('minx');
        miny = bbox.attr('miny');
        maxx = bbox.attr('maxx');
        maxy = bbox.attr('maxy');

        min = L.latLng(miny, minx);
        max = L.latLng(maxy, maxx);

        bounds = L.latLngBounds(min, max);
        centroid = bounds.getCenter();

        self.leafletMap.flyTo(centroid);

    });
};

GlMap.prototype.increaseLayerOpacity = function (layerId) {    
    var opacity = this.layers[layerId].opacity;
    
    if(opacity < 100 && !writeBackDequeueing) {
        newOpacity = opacity + 10;
        this.setLayerOpacity(layerId, newOpacity);

        queueUpdate({
            id: "increaseOpacity/" + layerId,
            url: "/modules/set_layer_opacity.cfm?layerId=" + layerId + "&opacity=" + newOpacity
        });
    }
};

GlMap.prototype.decreaseLayerOpacity = function (layerId) {
    var opacity = this.layers[layerId].opacity;
    
    if(opacity > 0 && !writeBackDequeueing) {
        newOpacity = opacity - 10;
        this.setLayerOpacity(layerId, newOpacity);

        queueUpdate({
            id: "decreaseOpacity/" + layerId,
            url: "/modules/set_layer_opacity.cfm?layerId=" + layerId + "&opacity=" + newOpacity
        });
    }


};

GlMap.prototype.setLayerOpacity = function(layerId, pct) {
    this.layers[layerId].prevOpacity = this.layers[layerId].opacity;

    var opacities = {
        0: 0,
        10: 0.1,
        20: 0.2,
        30: 0.3,
        40: 0.4,
        50: 0.5,
        60: 0.6,
        70: 0.7,
        80: 0.8,
        90: 0.9,
        100: 1
    };

    this.layers[layerId].opacity = pct;
    this.layers[layerId].leafletLayer.setOpacity(opacities[pct]);

    var elementId = "#opacity_" + layerId;
    var chkElementId = "#shown_" + layerId;

    if(pct > 0) {
        //$(chkElementId).iCheck('check');
        $(elementId).html(pct + "%");
    }
    else {
        //$(chkElementId).iCheck('uncheck');
        $(elementId).html('<i class="fa fa-eye-slash"></i>');
    }
};

function opacityPctToDecimal(pct)
{
        var opacities = {
            0: 0,
            10: 0.1,
            20: 0.2,
            30: 0.3,
            40: 0.4,
            50: 0.5,
            60: 0.6,
            70: 0.7,
            80: 0.8,
            90: 0.9,
            100: 1
        };

        return opacities[pct];
}

function getAllUrlParams(url) {

  // get query string from url (optional) or window
  var queryString = url ? url.split('?')[1] : window.location.search.slice(1);

  // we'll store the parameters here
  var obj = {};

  // if query string exists
  if (queryString) {

    // stuff after # is not part of query string, so get rid of it
    queryString = queryString.split('#')[0];

    // split our query string into its component parts
    var arr = queryString.split('&');

    for (var i=0; i<arr.length; i++) {
      // separate the keys and the values
      var a = arr[i].split('=');

      // in case params look like: list[]=thing1&list[]=thing2
      var paramNum = undefined;
      var paramName = a[0].replace(/\[\d*\]/, function(v) {
        paramNum = v.slice(1,-1);
        return '';
      });

      // set parameter value (use 'true' if empty)
      var paramValue = typeof(a[1])==='undefined' ? true : a[1];

      // (optional) keep case consistent
      paramName = paramName.toLowerCase();
      paramValue = paramValue.toLowerCase();

      // if parameter name already exists
      if (obj[paramName]) {
        // convert value to array (if still string)
        if (typeof obj[paramName] === 'string') {
          obj[paramName] = [obj[paramName]];
        }
        // if no array index number specified...
        if (typeof paramNum === 'undefined') {
          // put the value on the end of the array
          obj[paramName].push(paramValue);
        }
        // if array index number specified...
        else {
          // put the value at that index number
          obj[paramName][paramNum] = paramValue;
        }
      }
      // if param name doesn't exist yet, set it
      else {
        obj[paramName] = paramValue;
      }
    }
  }

  return obj;
}

L.Polyline = L.Polyline.include({
    getDistance: function(system) {
        // distance in meters
        var mDistanse = 0,
            length = this._latlngs.length;
        for (var i = 1; i < length; i++) {
            mDistanse += this._latlngs[i].distanceTo(this._latlngs[i - 1]);
        }
        // optional
        if (system === 'imperial') {
            return mDistanse / 1609.34;
        } else {
            return mDistanse / 1000;
        }
    }
});
