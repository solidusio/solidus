// Shipments AJAX API
/* eslint no-extra-semi: "off", no-unused-vars: "off" */

var ShipShipmentView = Backbone.View.extend({
  initialize: function(options){
    this.shipment_number = options.shipment_number;
  },
  events: {
    "submit": "onSubmit"
  },
  onSubmit: function(e){
    Spree.ajax({
      type: "PUT",
      url: Spree.pathFor('api/shipments/' + this.shipment_number + '/ship'),
      data: {
        send_mailer: this.$("[name='send_mailer']").is(":checked")
      },
      success: function(){
        window.location.reload()
      }
    });
    return false;
  }
});

adjustShipmentItems = function(shipment_number, variant_id, quantity){
  var shipment = _.findWhere(shipments, {number: shipment_number});
  var inventory_units = _.where(shipment.inventory_units, {variant_id: variant_id});

  var url = Spree.pathFor('api/shipments/' + shipment_number);

  var new_quantity = 0;
  if(inventory_units.length<quantity){
    url += "/add";
    new_quantity = (quantity - inventory_units.length);
  }else if(inventory_units.length>quantity){
    url += "/remove";
    new_quantity = (inventory_units.length - quantity);
  }

  if(new_quantity!=0){
    Spree.ajax({
      type: "PUT",
      url: url,
      data: {
        variant_id: variant_id,
        quantity: new_quantity,
      },
      success: function() {
        window.location.reload();
      },
      error: function(response) {
        json = response.responseJSON;
        message = json.error;
        for (error in json.errors) {
          message += '<br />' + json.errors[error].join();
        }
        window.show_flash('error', message);
      }
    });
  }
};

var ShipmentSplitItemView = Backbone.View.extend({
  tagName: 'tr',
  className: 'stock-item-split',

  initialize: function(options) {
    this.variant = options.variant;
    this.shipments = options.shipments;
    this.shipment_number = options.shipment_number;
    this.max_quantity = options.max_quantity;
    this.shipmentItemView = options.shipmentItemView;
    this.render()
  },

  events: {
    "click .cancel-split": "cancelItemSplit",
    "click .save-split": "completeItemSplit",
    "submit form": "completeItemSplit",
  },

  cancelItemSplit: function(e){
    e.preventDefault();

    this.shipmentItemView.removeSplit();
    this.remove();
  },

  completeItemSplit: function(e){
    e.preventDefault();

    var quantity = this.$('.quantity').val();
    var target = this.$('[name="item_stock_location"]').val().split(':');
    var target_type = target[0];
    var target_id = target[1];

    var split_attr = {
      original_shipment_number: this.shipment_number,
      variant_id: this.variant.id,
      quantity: quantity
    };
    var jqXHR;
    if (target_type == 'stock_location') {
      // transfer to a new location
      split_attr.stock_location_id = target_id;
      jqXHR = Spree.ajax({
        type: "POST",
        url: Spree.pathFor('api/shipments/transfer_to_location'),
        data: split_attr
      });
    } else if (target_type == 'shipment') {
      // transfer to an existing shipment
      split_attr.target_shipment_number = target_id;
      jqXHR = Spree.ajax({
        type: "POST",
        url: Spree.pathFor('api/shipments/transfer_to_shipment'),
        data: split_attr
      });
    } else {
      alert('Please select the split destination.');
      return false;
    }
    jqXHR.error(function(msg) {
      alert(Spree.t("split_failed"));
    }).done(function(response) {
      if (response.success) {
        window.Spree.advanceOrder();
      } else {
        alert(response.message);
      };
    });
  },

  template: HandlebarsTemplates['variants/split'],

  render: function() {
    /* Only display other shipments */
    var shipments = _.reject(this.shipments, _.matcher({'number': this.shipment_number}))

    var renderAttr = {
      variant: this.variant,
      shipments: shipments,
      max_quantity: this.max_quantity
    };
    this.$el.html(this.template(renderAttr));

    this.$('[name="item_stock_location"]').select2({
      width: 'resolve',
      placeholder: Spree.t('choose_location'),
      minimumResultsForSearch: 8
    });
  }
});

var ShipmentItemView = Backbone.View.extend({
  initialize: function(options) {
    this.shipment_number = options.shipment_number
    this.order_number = options.order_number
    this.quantity = this.$el.data('item-quantity')
    this.variant_id = this.$el.data('variant-id')
  },

  events: {
    "click button.delete-item": "onDelete",
    "click button.split-item": "onSplit",
  },

  removeSplit: function() {
    this.$('.split-item').show();
    this.$('.delete-item').show();
  },

  onSplit: function(e) {
    e.preventDefault();
    this.$('.split-item').toggle();
    this.$('.delete-item').toggle();

    var _this = this;
    Spree.ajax({
      type: "GET",
      url: Spree.pathFor('api/variants/' + this.variant_id),
    }).success(function(variant){
      var split = new ShipmentSplitItemView({
        shipmentItemView: _this,
        shipment_number: _this.shipment_number,
        variant: variant,
        shipments: window.shipments,
        max_quantity: _this.quantity
      });

      _this.$el.after(split.$el);
    });
  },

  onDelete: function(e){
    e.preventDefault();
    if (confirm(Spree.translations.are_you_sure_delete)) {
      adjustShipmentItems(this.shipment_number, this.variant_id, 0);
    }
  },
});

var ShipmentEditView = Backbone.View.extend({
  initialize: function(){
    this.shipment_number = this.model.get('number')
    this.order_number = this.model.collection.parent.get('number')

    var shipment = this.model;

    var shipmentView = this;
    this.$("form.admin-ship-shipment").each(function(el){
      new ShipShipmentView({
        el: this,
        shipment_number: shipmentView.shipment_number
      });
    });
    this.$(".stock-item").each(function(){
      new ShipmentItemView({
        el: this,
        shipment_number: shipmentView.shipment_number,
        order_number: shipmentView.order_number
      });
    });
    this.$(".edit-shipping-method").each(function(el){
      new Spree.Views.Order.ShippingMethod({
        el: this,
        model: shipment,
        shipment_number: shipmentView.shipment_number
      });
    });
    this.$(".edit-tracking").each(function(el){
      new Spree.Views.Order.ShipmentTracking({
        el: this,
        model: shipment
      });
    });
  }
});

Spree.ready(function(){
  if($('.js-shipment-edit [data-order-number]').length) {
    $('.js-shipment-edit').hide();
    var orderNumber = $('.js-shipment-edit [data-order-number]').data('orderNumber');
    var order = Spree.Models.Order.fetch(orderNumber, {
      success: function(order){
        $('.js-shipment-edit').show();
        $(".js-shipment-edit").each(function(){
          var shipmentNumber = $('[data-shipment-number]', this).data('shipmentNumber')
          var shipment = order.get("shipments").find({number: shipmentNumber})
          new ShipmentEditView({ el: this, model: shipment });
        });
      }
    });
  }
});
