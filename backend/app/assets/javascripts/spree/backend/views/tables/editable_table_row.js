Spree.Views.Tables.EditableTableRow = Backbone.View.extend({
  events: {
    "select2-open": "onEdit",
    "focus input": "onEdit",
    "click [data-action=save]": "onSave",
    "click [data-action=cancel]": "onCancel",
    'keyup input': 'onKeypress'
  },

  onEdit: function(e) {
    if (this.$el.hasClass('editing')) {
      return;
    }
    this.$el.addClass('editing');
    this.$el.find('input, select').each(function() {
      var $input = $(this);
      $input.data('original-value', $input.val());
    });
  },

  onCancel: function(e) {
    e.preventDefault();
    this.$el.removeClass("editing");
    this.$el.find('input, select').each(function() {
      var $input = $(this);
      var originalValue = $input.data('original-value');
      $input.val(originalValue).change();
    });
  },

  onSave: function(e) {
    e.preventDefault();
    var view = this;
    Spree.ajax(this.$el.find('.actions [data-action=save]').attr('href'), {
      data: this.$el.find('select, input').serialize(),
      dataType: 'json',
      method: 'put',
      success: function(response) {
        view.$el.removeClass("editing");
      },
      error: function(response) {
        show_flash('error', response.responseJSON.error);
      }
    });
  },

  ENTER_KEY: 13,
  ESC_KEY: 27,

  onKeypress: function(e) {
    var key = e.keyCode || e.which;
    switch (key) {
      case this.ENTER_KEY:
        this.onSave(e);
        break;
      case this.ESC_KEY:
        this.onCancel(e);
        break;
    }
  }
});
