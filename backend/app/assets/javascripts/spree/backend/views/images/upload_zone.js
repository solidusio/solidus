Spree.Views.Images.UploadZone = Backbone.View.extend({
  events: {
    "dragover" : "onDragOver",
    "dragleave" : "onDragLeave",
    "drop" : "onDrop",
    'change input[type="file"]' : "onFileBrowserSelect"
  },

  upload: function(file) {
    var progressModel = new Spree.Models.ImageUpload({file: file});

    this.collection.add(progressModel);

    progressModel.previewFile();
    progressModel.uploadFile();
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
