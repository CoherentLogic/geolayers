<div class="modal inmodal" id="dlgViewLayer" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content animated bounceInRight">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                <i class="fa fa-info-circle modal-icon"></i>
                <h4 class="modal-title">View Layer</h4>
                <small class="font-bold">View the properties of a layer.</small>
            </div>
            <div class="modal-body">
                <div class="tabs-container">
                    <ul class="nav nav-tabs">                        
                        <li id="vl-tab-basic" class="active"><a data-toggle="tab" href="#vl-basic">Layer</a></li>
                        <li id="vl-tab-geography"><a data-toggle="tab" href="#vl-geography">Geography</a></li>  
                        <li id="vl-tab-sharing"><a data-toggle="tab" href="#vl-sharing">Sharing</a></li>   
                        <li id="vl-tab-storage"><a data-toggle="tab" href="#vl-storage">Storage</a></li>                                                                
                    </ul>
                    <div class="tab-content">
                        <div id="vl-basic" class="tab-pane active">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-7">
                                        <h1><span id="vl-layer-name">Sonoma Ortho World</span></h1>
                                        <p><span id="vl-layer-type">GeoTIFF Imagery</span></p>
                                        
                                        <cfscript>
                                        util = new Util();

                                        date = util.friendlyDate(now());
                                        </cfscript>

                                        <table class="table" style="margin-top: 40px;">
                                            <tbody>                                                
                                                <tr>
                                                    <td class="property-key">Attribution</td>
                                                    <td><span id="vl-layer-attribution">&copy; Gutierrez Industries LLC</span></td>
                                                </tr>
                                                <tr>
                                                    <td class="property-key">Copyright</td>
                                                    <td><span id="vl-layer-copyright">&copy; 2017</span></td>
                                                </tr>
                                                <tr>
                                                    <td class="property-key">Zoom Range</td>
                                                    <td><span id="vl-layer-zoomrange">17-23</span></td>
                                                </tr>
                                            </tbody>
                                        </table>                                        
                                    </div>
                                    <div class="col-md-5">                                        
                                        <div class="well">
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <cfoutput>
                                                    <img alt="image" id="vl-contributor-picture" class="img-circle" width="48" src="/img/placeholder.png" />
                                                    </cfoutput>
                                                </div>
                                                <div class="col-md-8">
                                                    Contributed <span id="vl-layer-timestamp"></span> by <strong class="font-bold" id="vl-contributor-name">?</strong><br><br>
                                                    <button id="vl-follow-user" type="button" class="btn btn-primary btn-xs">Follow</button>
                                                    <button id="vl-message-user" type="button" class="btn btn-primary btn-xs">Message</button>
                                                </div>
                                            </div>
                                        </div>                                        
                                    </div>
                                </div>
                            </div>    
                        </div>
                        <div id="vl-geography" class="tab-pane">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-7">
                                        <h2>Coordinates</h2>

                                        <table class="table" style="margin-top: 40px;">
                                            <tbody>                                                
                                                <tr>
                                                    <td class="property-key">NW</td>
                                                    <td><span id="vl-layer-nw"></span></td>
                                                </tr>
                                                <tr>
                                                    <td class="property-key">SE</td>
                                                    <td><span id="vl-layer-se"></span></td>
                                                </tr>
                                                <tr>
                                                    <td class="property-key">Centroid</td>
                                                    <td><span id="vl-layer-centroid"></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="col-md-5">
                                        <div class="well">
                                            <img id="vl-tile-thumbnail" width="220" height="220" src="/img/transparent.gif">
                                        </div>
                                    </div>                                    
                                </div>                                
                            </div>    
                        </div>
                        <div id="vl-sharing" class="tab-pane">  
                            <div class="panel-body">         
                                
                            </div> 
                        </div>
                        <div id="vl-storage" class="tab-pane">
                            <div class="panel-body">              
                               
                            </div>       
                        </div>
                    </div>
                </div>                           
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-white" data-dismiss="modal">Close</button>                
            </div>
        </div>
    </div>
</div>