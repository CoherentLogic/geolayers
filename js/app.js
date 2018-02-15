function loadContent(url, done)
{
    $.ajax({
	url: url,
	success: function(result) {
	    $("#content").html(result);
	    if(done) done();
	}
    });
}

function addLayer()
{
    loadContent('addlayer.cfm', function () {

        $("#customer-name").keyup(function() {
            
            $("#customerid").val($("#customer-name").val().replace(/[^A-Za-z]+/g, '').toLowerCase());
        });

        $("#addLayerSub").click(function() {
            var uploadData = {
                customerId: $("#customerid").val(),
                customerName: $("#customer-name").val(),
                email: $("#email").val(),
                projectName: $("#project-name").val(),
                layerId: $("#layerid").val()
            };

            beginUpload(uploadData);
        });
    });
}

function manageLayers()
{
    loadContent('managelayers.cfm');
}

function beginUpload(uploadData)
{
    var list = $("#queue");

    list.append('<li class="list-group-item"><h3>' + uploadData.projectName + '</h3><div id="progress-' + uploadData.layerId + '">Uploading</div></li>');

    addLayer();

    poll(uploadData);
}

function poll(uploadData) 
{
    var url = "progress.cfm?customerid=" + uploadData.customerId + "&layerid=" + uploadData.layerId;

    $.get(url, function(data) {
        var layerId = data.layerId;
        var progressId = "#progress-" + layerId;

        $(progressId).html(data.status);
    });

    setTimeout(function() {
        poll(uploadData);
    }, 3000);

}