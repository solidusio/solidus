Spree.Views.Images.UploadProgress = Backbone.View.extend({
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
});
