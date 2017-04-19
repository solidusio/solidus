// Inspired by: http://html5demos.com/dnd-upload
Spree.prepareImageUploader = function () {
  var uploadZone = document.getElementById('upload-zone');
  if(!uploadZone) return;

  // Kick off by binding the events on the upload zone
  var imageUploads = new Backbone.Collection();
  var progressZone = document.getElementById('progress-zone');
  var variantId = document.querySelector('input[name="image[viewable_id]"]').value;

  new Spree.Views.Images.UploadZone({
    el: uploadZone,
    collection: imageUploads
  });

  imageUploads.on('add', function(progressModel) {
    progressModel.set({variant_id: variantId});

    var progressView = new Spree.Views.Images.UploadProgress({model: progressModel});
    progressZone.appendChild(progressView.render().el);
  });
};


Spree.ready(function () {
  Spree.prepareImageUploader();
});
