// https://simplyian.com/2016/02/09/Using-Underscore-js-templates-within-ERB/
_.templateSettings = {
  interpolate: /\{\{\=(.+?)\}\}/g,
  evaluate: /\{\{(.+?)\}\}/g
};

// Inspired by: http://html5demos.com/dnd-upload
Spree.prepareImageUploader = function () {
  var uploadZone = document.getElementById('upload-zone');
  if(!uploadZone) return;

  var tests = {
      filereader: typeof FileReader != 'undefined',
      dnd: 'draggable' in document.createElement('span'),
      formdata: !!window.FormData,
      progress: "upload" in new XMLHttpRequest
    },
    support = {
      filereader: document.getElementById('filereader'),
      formdata:   document.getElementById('formdata'),
      progress:   document.getElementById('progress')
    },
    progressZone = document.getElementById('progress-zone'),
    progressTmpl = document.getElementById('upload-progress-tmpl').innerHTML,
    uploadForm   = document.getElementById('upload-form'),
    variantId    = uploadForm.querySelector('input[name="image[viewable_id]"').value;


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
      formData.append('image[viewable_id]', variantId);
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
      }).error(function() {
        that.set({serverError: true});
      });
    }
  }); // end ProgressModel

  var ProgressView = Backbone.View.extend({
    tagName: "div",

    // Cache the template function for a single item.
    template: _.template(progressTmpl),

    initialize: function() {
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
      this.el.innerHTML = this.template(this.model.attributes);
      return this;
    },

    // Remove the item, destroy the model.
    clear: function() {
      this.model.destroy();
    }
  }); // end Backbone


  // Hide or highlight supported browser features
  "filereader formdata progress".split(' ').forEach(function (api) {
    support[api].className = (tests[api] === false) ? 'red' : 'hidden'
  });

  function upload(file) {
    if (!tests.formdata) return;

    var progressModel = new ProgressModel({file: file});
    progressModel.previewFile();
    progressModel.uploadFile();

    var progressView = new ProgressView({model: progressModel});
    progressZone.appendChild(progressView.render().el);
  }

  // Bind area for drag & drop
  if (tests.dnd) {
    uploadZone.ondragover = function () { this.className = 'hover'; return false; };
    uploadZone.ondragleave = function () { this.className = ''; return false; };
    uploadZone.ondrop = function (e) {
      this.className = '';
      e.preventDefault();
      for (var i = 0; i < e.dataTransfer.files.length; i++) {
        upload(e.dataTransfer.files[i]);
      }
    }
  }

  // Bind file browser button
  uploadForm.querySelector('input[type="file"]').onchange = function () {
    for (var i = 0; i < this.files.length; i++) {
      upload(this.files[i]);
    }
  };
};

Spree.ready(function () {
  Spree.prepareImageUploader();
});
