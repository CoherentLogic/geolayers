/**
 * filehandler.js
 *
 * A generic file uploading class and helper functions,
 * supporting XHR2 file uploads with progress bar.
 *
 * Copyright (C) 2018 Coherent Logic Development LLC
 *
 * Author: John P. Willis <jpw@coherent-logic.com>
 * Date: 28 Feb 2018
 */

class FileHandler {
    constructor(file, opts) {
        this.file = file;
        this.uploadHandler = opts.uploadHandler;
        this.progressBarId = "#" + opts.progressBarId;        
        this.timeout = opts.timeout || 999999;
        this.formFields = opts.formFields || [];

        this.success = opts.success || function(data) {
            console.log(data);
        };

        this.error = opts.error || function(error) {
            console.log(error);
        };
    }

    type() {
        return this.file.type;
    }

    size() {
        return this.file.size;
    }

    name() {
        return this.file.name;
    }

    upload() {
        let self = this;

        let onUploadProgress = function(event) {
            let percent = 0;
            let position = event.loaded || event.position;
            let total = event.total;
            let progressBarId = self.progressBarId;

            if(event.lengthComputable) {
                percent = Math.ceil(position / total * 100);
            }

            $(self.progressBarId + " .progress-bar").css("width", +percent + "%");
            $(self.progressBarId + " .status").text(percent + "%");
        };

        let formData = new FormData();

        formData.append("file", this.file, this.name());
        formData.append("upload_file", true);

        

        let index = null;
        for(index in this.formFields) {            
            formData.append(this.formFields[index], $("#" + this.formFields[index]).val());
        }
       

        $.ajax({
            type: "POST",
            url: this.uploadHandler,
            xhr: function () {
                let myXhr = $.ajaxSettings.xhr();
                if(myXhr.upload) {
                    myXhr.upload.addEventListener('progress', onUploadProgress, false);
                }

                return myXhr;
            },
            success: self.success,
            error: self.error,
            async: true,
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            timeout: self.timeout            
        });
    }
}

function attachFileHandler(elementId, opts) {
    let selector = "#" + elementId;

    $(selector).on("change", function(event) {
        let file = $(this)[0].files[0];
        let fh = new FileHandler(file, opts);

        fh.upload();
    });
}