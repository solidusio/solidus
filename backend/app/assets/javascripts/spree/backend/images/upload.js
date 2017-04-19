// Inspired by: http://html5demos.com/dnd-upload
Spree.prepareImageUploader = function () {
  var uploadZone = document.getElementById('upload-zone');
  if(!uploadZone) return;

  var UploadZone = Backbone.View.extend({
    el: uploadZone,

    events: {
      "dragover" : "onDragOver",
      "dragleave" : "onDragLeave",
      "drop" : "onDrop",
      'change input[type="file"]' : "onFileBrowserSelect"
    },

    progressZone: document.getElementById('progress-zone'),

    upload: function(file) {
      var progressModel = new ProgressModel({file: file});
      progressModel.previewFile();
      progressModel.uploadFile();

      var progressView = new ProgressView({model: progressModel});
      this.progressZone.appendChild(progressView.render().el);
    },

    dragClass: 'with-images',

    onDragOver: function(e) {
      this.el.classList.add(this.dragClass);
      e.preventDefault();
    },

    onDragLeave: function() {
      this.el.classList.remove(this.dragClass);
    },

    onDrop: function(e) {
      this.el.classList.remove(this.dragClass);
      e.preventDefault();

      _.each(e.originalEvent.dataTransfer.files, this.upload, this);
    },

    onFileBrowserSelect: function(e) {
      _.each(e.target.files, this.upload, this);
    }
  });

  var ProgressModel = Backbone.Model.extend({
    initialize: function() {
      var file = this.get("file");
      this.set({
        filename: file.name,
        size: file.size ? (file.size/1024|0) + 'K' : ''
      });
    },

    defaults: function() {
      return {
        file: null,
        imgSrc: '',
        progress: 0,
        serverError: false,
        filename: '',
        size: ''
      }
    },

    acceptedTypes: {
      'image/png': true,
      'image/jpeg': true,
      'image/gif': true
    },

    variantId: document.querySelector('input[name="image[viewable_id]"]').value,

    previewFile: function () {
      var file = this.get('file'),
          that = this;

      if (FileReader && this.acceptedTypes[file.type] === true) {
        var reader = new FileReader();
        reader.onload = function (event) {
          that.set({imgSrc: event.target.result});
        };

        reader.readAsDataURL(file);
      }
    },

    uploadFile: function () {
      var formData = new FormData(),
          that = this;

      formData.append('image[attachment]', this.get('file'));
      formData.append('image[viewable_id]', this.variantId);
      formData.append('upload_id', this.cid);

      // send the image to the server
      Spree.ajax({
        url: window.location.pathname,
        type: "POST",
        dataType: 'script',
        data: formData,
        processData: false,  // tell jQuery not to process the data
        contentType: false,  // tell jQuery not to set contentType
        xhr: function () {
          var xhr = $.ajaxSettings.xhr();
          if (xhr.upload) {
            xhr.upload.onprogress = function (event) {
              if (event.lengthComputable) {
                var complete = (event.loaded / event.total * 100 | 0);
                that.set({progress: complete})
              }
            };
          }
          return xhr;
        }
      }).done(function() {
        that.set({progress: 100})
      }).error(function(jqXHR, textStatus, errorThrown) {
        that.set({serverError: true});
      });
    }
  }); // end ProgressModel


  var ProgressView = Backbone.View.extend({
    tagName: "div",

    // Cache the template function for a single item.
    template: HandlebarsTemplates["products/upload_progress"],

    initialize: function() {
      this.listenTo(this.model, 'change:progress', this.updateProgressBar);
      this.listenTo(this.model, 'change', this.render);
      this.listenTo(this.model, 'destroy', this.remove);
    },

    events: {
      "clear" : "clear"
    },

    className: 'col-sm-6 col-md-4 mb-3',

    attributes: function() {
      return {
        "data-upload-id": this.model.cid
      }
    },

    render: function() {
      // Skip progress bar update for better performance
      var changedAttrs = Object.keys(this.model.changed);
      if(changedAttrs.length === 1 && changedAttrs[0] == 'progress') return this;

      this.el.innerHTML = this.template(this.model.toJSON());
      this.updateProgressBar();
      return this;
    },

    updateProgressBar: function() {
      var progressBar = this.el.querySelector('.progress-bar');
      var percent = this.model.get('progress');
      progressBar.setAttribute('aria-valuenow', percent);
      progressBar.style.width = percent + '%';
      progressBar.innerHTML = percent + '%';
      return this;
    },

    // Remove the item, destroy the model
    clear: function() {
      this.model.destroy();
    }
  }); // end ProgressView


  // Kick off by binding the events on the upload zone
  new UploadZone();

}; // end prepareImageUploader


Spree.ready(function () {
  Spree.prepareImageUploader();
});
