Spree.Models.ImageUpload = Backbone.Model.extend({
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
    formData.append('image[viewable_id]', this.get('variant_id'));
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
});
