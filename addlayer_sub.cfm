<cfset layerid="#form.layerid#">
<cfset filename="/var/gis/raw_files/#layerid#.tif">

<cffile action="upload" destination="#filename#" fileField="file">

<cfscript>
    basedir = "/var/gis/users/geolayers/geolayers/repo/";
    fixedname = form.customerid;
    fullname = "#basedir##fixedname#";
    if(!DirectoryExists(fullname)) {
     DirectoryCreate(fullname);
    };
    url="http://geolayers.geodigraph.com/repo/#fixedname#/#layerid#/openlayers.html";
</cfscript>


<cfset args="-t '#form.projectname#' -k AIzaSyC4-UOmAvykBv-fnS2erO_nY9K-w4He8HY -f #filename# -c '#form.customername#' -s '#fixedname#' -i '#layerid#' -e '#form.email#'">

<cfoutput>#args#</cfoutput>
    
<cfexecute name="/var/gis/users/geolayers/geolayers/bin/maketiles"
	   arguments="#args#"
	   outputFile="/tmp/output.gl8"
	   errorFile="/tmp/error.gl8">
</cfexecute>






