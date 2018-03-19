<cfscript>
var layers = session.account.layers();
</cfscript>

<table class="table table-striped">
    <thead>
        <tr>
            <th>Type</th>
            <th>Layer</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>        
        <cfloop collection="#layers#" item="id">
            <cfset layer = layers[id].layer>
            <cfset props = layers[id].properties>


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
                
                <cfoutput>
                    <tr>
                        <td><i class="fa #icon#"></i></td>
                        <td>#layer.name#</td>
                        <td>
                            <cfif isDefined("props.hidden")>
                                <button type="button" class="btn btn-success btn-xs" onclick="pldShow('#id#')">Show</button>
                            <cfelse>
                                <button type="button" class="btn btn-warning btn-xs" onclick="pldHide('#id#')">Hide</button>
                            </cfif>
                        </td>
                    </tr>  
                </cfoutput>

            </cfif>      
        </cfloop>
    </tbody>
</table>