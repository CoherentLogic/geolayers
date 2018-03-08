<cftry>
<cfscript>
    layers = session.account.layers();
</cfscript>

<cfif isDefined("url.json")>
    <cfheader name="Content-Type" value="application/json">

    <cfscript>
          writeOutput(serializeJSON(layers));
    </cfscript>

<cfelse>
    <div class="table-responsive">
        <table class="table table-striped" id="layers-table">
            <thead>
                <tr id="layers-table-header">
                    <th>&nbsp;</th>
                    <th>Show</th>
                    <th>Layer</th>
                    <th>Opacity</th>
                    <th>Order</th>
                    <th>&nbsp;</th>
                </tr>
            </thead>
            <tbody id="layers-tbody">
                <cfif layers.len() LT 1>
                    <tr>
                        <td colspan="5" style="font-weight: bold;">No layers found.</td>
                    </tr>
                </cfif>
                <cfloop collection="#layers#" item="id">
                    <cfset layer = layers[id].layer>

                    <cfif layer.ready GT 0>
                        <cfswitch expression="#layer.renderer#">
                            <cfcase value="geotiff">
                                <cfset icon="fa-picture-o">                                                
                            </cfcase>
                            <cfcase value="base">
                                <cfset icon="fa-map">                           
                            </cfcase>
                            <cfcase value="parcel">
                                <cfset icon="fa-square-full">
                            </cfcase>
                        </cfswitch>
                    <cfelse>
                        <cfset icon="fa-spinner fa-spin">
                    </cfif>
                    <cfset opacity = layers[id].properties.opacity & "%">
                    <cfoutput>
                        <tr id="lc_#id#">
                            <td>
                                <i class="fa #icon#"></i>
                            </td>
                            <td>
                                <cfif layer.ready GT 0>
                                    <input type="checkbox" checked="checked" class="i-checks layer-shown" id="shown_#id#">
                                <cfelse>
                                    <input type="checkbox" class="i-checks layer-shown" id="shown_#id#">
                                </cfif>
                            </td>
                            
                            <cfif layer.renderer NEQ "base">
                                <cfif layer.ready GT 0>
                                    <td><a href="##" class="layer-center">#layer.name#</a></td>
                                <cfelse>
                                    <td colspan="4">#layer.name# (#trim(layers[id].object.getStatus())#)</td>
                                </cfif>
                            <cfelse>
                                    <td>#layer.name#</td>
                            </cfif>
                            
                            <cfif layer.ready GT 0>
                                <td>
                                    <a href="##"><i class="fa fa-circle-o opacity-down"></i></a>                                
                                    <span class="text-muted small opacity-display" id="opacity_#id#">#opacity#</span>
                                    <a href="##"><i class="fa fa-circle opacity-up"></i></a>                                
                                    
                                </td>
                                <td>
                                    <a href="##"><i class="fa fa-chevron-down layer-down"></i></a>
                                    <a href="##"><i class="fa fa-chevron-up layer-up"></i></a>
                                </td>   
                                <td>
                                    <cfif layers[id].layer.contributor EQ session.account.email>
                                        <a  href="##" class="edit-layer"><i class="fa fa-edit"></i></a>&nbsp;
                                    </cfif>  
                                    <a href="##" class="view-layer"><i class="fa fa-info-circle"></i></a>                                 
                                </td>                                                        
                            </cfif>
                        </tr>
                    </cfoutput>
                </cfloop>
            </tbody>
        </table>
    </div>
</cfif>
<cfcatch type="any">
    <cfoutput>
        #cfcatch.message#<br>
        #cfcatch.detail#<br>
    </cfoutput>
    <cfdump var="#layers#">
    <cfdump var="#session#">

</cfcatch>
</cftry>