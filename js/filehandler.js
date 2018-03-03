/**
 * filehandler.js
 *
 * A generic file uploading class and helper functions,
 * supporting XHR2 file uploads with progress bar.
 * 
 * Requires jQuery >= 3.1.1 
 *
 * Copyright (C) 2018 Coherent Logic Development LLC
 *
 * Author: John P. Willis <jpw@coherent-logic.com>
 * Date: 28 Feb 2018
 */

/**
 * @callback successCallback
 * @param {Object} data - JSON response from the server
 */

/**
 * @callback errorCallback
 * @param {Object} error - JSON response from the server
 */

 /** Handles XHR2 file uploads. */
 class FileHandler {

    /**
     * Create an XHR2 file upload handler
     * @param {Object} file - the file object acquired from the form input
     * @param {Object} opts - options
     * @param {string} opts.uploadHandler - URL for the back-end script to handle the upload
     * @param {string} opts.progressBarId - element ID of the progress bar div
     * @param {number} [opts.timeOut=999999] - upload timeout
     * @param {string[]} [opts.formFields] - additional field IDs to pass to the back-end script
     * @param {successCallback} [opts.success] - callback for successful upload
     * @param {errorCallback} [opts.error] - callback for failed upload
     */
     constructor(file, opts) {
        this.file = file;
        this.uploadHandler = opts.uploadHandler;
        this.progressBarId = `#${opts.progressBarId}`;        
        this.timeout = opts.timeout || 999999;
        this.formFields = opts.formFields || [];

        this.success = opts.success || function(data) {
            console.log(data);
        };

        this.error = opts.error || function(error) {
            console.log(error);
        };
    }

    /**
     * Get the MIME type of the file
     * @return {string} - The file's MIME type.
     */
    type() {
        return this.file.type;
    }

    /**
     * Get the file size
     * @return {number} - The file's size (in bytes)
     */
    size() {
        return this.file.size;
    }

    /**
     * Get the file name
     * @return {string} - The file's name
     */
    name() {
        return this.file.name;
    }

    /**
     * Begin the upload process.
     */
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
        
        this.formFields.map(x => formData.append(x, $(`#${x}`).val()));

        $.ajax({
            type: "POST",
            url: this.uploadHandler,
            xhr: function () {
                let myXhr = $.ajaxSettings.xhr();
                if(myXhr.upload) {
                    myXhr.upload.addEventListener("progress", onUploadProgress, false);
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

/**
 * Attach a FileHandler to an input element of type "file"
 * @param {string} elementId - id attribute of the element
 * @param {Object} opts - options; see FileHandler constructor docs
 */
function attachFileHandler(elementId, opts) {
    let selector = `#${elementId}`;

    $(selector).on("change", function(event) {
        let file = $(this)[0].files[0];
        let fh = new FileHandler(file, opts);

        fh.upload();
    });
}