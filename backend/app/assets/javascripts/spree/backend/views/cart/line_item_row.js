Spree.Views.Cart.LineItemRow = Backbone.View.extend({
  tagName: 'tr',
  className: 'line-item',

  initialize: function(options) {
    this.listenTo(this.model, "change", this.render);
    this.editing = options.editing || this.model.isNew();
  },

  events: {
    'click .edit-line-item': 'onEdit',
    'click .cancel-line-item': 'onCancel',
    'click .save-line-item': 'onSave',
    'submit form': 'onSave',
    'click .delete-line-item': 'onDelete',
    'change .js-select-variant': 'onChangeVariant',
  },

  onEdit: function(e) {
    e.preventDefault()
    this.editing = true
    this.render()
  },

  onCancel: function(e) {
    e.preventDefault();
    if (this.model.isNew()) {
      this.remove();
      this.model.destroy();
    } else {
      this.editing = false;
      this.render();
    }
  },

  validate: function () {
    this.$('[name=quantity]').toggleClass('error', !this.$('[name=quantity]').val());
    this.$('.select2-container').toggleClass('error', !this.$('[name=variant_id]').val());

    return !this.$('.select2-container').hasClass('error') && !this.$('[name=quantity]').hasClass('error')
  },

  onSave: function(e) {
    e.preventDefault()
    if(!this.validate()) {
      return;
    }
    var attrs = {
      quantity: parseInt(this.$('input.line_item_quantity').val())
    }
    if (this.model.isNew()) {
      attrs['variant_id'] = this.$("[name=variant_id]").val()
    }
    var model = this.model;
    this.model.save(attrs, {
      patch: true,
      success: function() {
        model.order.advance()
      }
    });
    this.editing = false;
    this.render();
  },

  onDelete: function(e) {
    e.preventDefault()
    if(!confirm(Spree.translations.are_you_sure_delete)) {
      return;
    }
    this.remove()
    var model = this.model;
    this.model.destroy({
      success: function() {
        model.order.advance()
      }
    })
  },

  render: function() {
    var html = HandlebarsTemplates['orders/line_item']({
      line_item: this.model.toJSON(),
      editing: this.editing,
      isNew: this.model.isNew(),
      noCancel: this.model.isNew() && this.model.collection.length == 1
    });
    this.$el.html(html);
    this.$("[name=variant_id]").variantAutocomplete({ suppliable_only: true });
  }
});
