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

    // Hide or highlight supported browser features
    initialize: function() {
      "filereader formdata progress".split(' ').forEach(function (api) {
        this.support[api].className = (this.tests[api] === false) ? 'red' : 'hidden'
      }, this);
    },

    upload: function(file) {
      if (!this.tests.formdata) return;

      var progressModel = new ProgressModel({file: file});
      progressModel.previewFile();
      progressModel.uploadFile();

      var progressView = new ProgressView({model: progressModel});
      this.progressZone.appendChild(progressView.render().el);
    },

    onDragOver: function() {
      this.el.className = 'hover';
      return false;
    },

    onDragLeave: function() {
      this.el.className = '';
      return false;
    },

    onDrop: function(e) {
      this.el.className = '';
      e.preventDefault();

      for (var i = 0; i < e.originalEvent.dataTransfer.files.length; i++) {
        this.upload(e.originalEvent.dataTransfer.files[i]);
      }
    },

    onFileBrowserSelect: function(e) {
      for (var i = 0; i < e.target.files.length; i++) {
        this.upload(e.target.files[i]);
      }
    },

    tests: {
      filereader: typeof FileReader != 'undefined',
      dnd: 'draggable' in document.createElement('span'),
      formdata: !!window.FormData,
      progress: "upload" in new XMLHttpRequest
    },

    support: {
      filereader: document.getElementById('filereader'),
      formdata:   document.getElementById('formdata'),
      progress:   document.getElementById('progress')
    }
  });

  var ProgressModel = Backbone.Model.extend({
    initialize: function() {
      this.set({summary: this.get("file").name});
    },

    defaults: function() {
      return {
        file: null,
        imgSrc: '',
        progress: 0,
        serverError: false,
        summary: ''
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
      } else {
        var summary = 'Uploading ' + file.name + ' ' + (file.size ? (file.size/1024|0) + 'K' : '');
        this.set({summary: summary});
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
          xhr = $.ajaxSettings.xhr();
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
    template: _.template(document.getElementById('upload-progress-tmpl').innerHTML),

    initialize: function() {
      this.listenTo(this.model, 'change:progress', this.updateProgressBar);
      this.listenTo(this.model, 'change', this.render);
      this.listenTo(this.model, 'destroy', this.remove);
    },

    events: {
      "clear" : "clear"
    },

    attributes: function() {
      return {
        "data-upload-id": this.model.cid
      }
    },

    render: function() {
      // Skip progress bar update for better performance
      var changedAttrs = Object.keys(this.model.changed);
      if(changedAttrs.length === 1 && changedAttrs[0] == 'progress') return this;

      this.el.innerHTML = this.template(this.model.attributes);
      return this;
    },

    updateProgressBar: function() {
      var progressBar = this.el.querySelector('progress');
      progressBar.value = progressBar.innerHTML = this.model.get('progress');
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
