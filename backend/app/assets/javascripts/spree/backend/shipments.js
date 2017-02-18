// Shipments AJAX API

var ShipmentAddVariantView = Backbone.View.extend({
  events: {
    "change #add_variant_id": "onSelect",
    "click .add_variant": "onAdd"
  },
  onSelect: function(e) {
    var variant_id = this.$("#add_variant_id").val();
    var template = HandlebarsTemplates["variants/autocomplete_stock"];
    var $stock_details = this.$('#stock_details');
    Spree.ajax({
      url: Spree.routes.variants_api + "/" + variant_id,
      success: function(variant){
        $stock_details.html(template({variant: variant})).show()
      }
    });
  },
  onAdd: function(e){
    e.preventDefault();

    this.$('#stock_details').hide();

    var variant_id = this.$('input.variant_autocomplete').val();
    var stock_location_id = $(e.target).data('stock-location-id');
    var quantity = this.$("input.quantity[data-stock-location-id='" + stock_location_id + "']").val();

    addVariantFromStockLocation(stock_location_id, variant_id, quantity)
  }
});

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
      url: Spree.routes.shipments_api + "/" + this.shipment_number + "/ship",
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

  var url = Spree.routes.shipments_api + "/" + shipment_number;

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
        window.show_flash('error', response.responseJSON.message);
      }
    });
  }
};

addVariantFromStockLocation = function(stock_location_id, variant_id, quantity) {
  var shipment = _.find(shipments, function(shipment){
    return shipment.stock_location_id == stock_location_id && (shipment.state == 'ready' || shipment.state == 'pending');
  });

  if(shipment==undefined){
    Spree.ajax({
      type: "POST",
      url: Spree.routes.shipments_api,
      data: {
        shipment: {
          order_id: window.order_number
        },
        variant_id: variant_id,
        quantity: quantity,
        stock_location_id: stock_location_id,
      }
    }).done(function(){
      window.location.reload();
    });
  }else{
    //add to existing shipment
    adjustShipmentItems(shipment.number, variant_id, quantity);
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
        url: Spree.routes.shipments_api + "/transfer_to_location",
        data: split_attr
      });
    } else if (target_type == 'shipment') {
      // transfer to an existing shipment
      split_attr.target_shipment_number = target_id;
      jqXHR = Spree.ajax({
        type: "POST",
        url: Spree.routes.shipments_api + "/transfer_to_shipment",
        data: split_attr
      });
    } else {
      alert('Please select the split destination.');
      return false;
    }
    jqXHR.error(function(msg) {
      alert(msg.responseJSON['message']);
    }).done(function() {
      window.Spree.advanceOrder();
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
      placeholder: Spree.translations.item_stock_placeholder,
      minimumResultsForSearch: 8
    });
  }
});

var ShipmentItemView = Backbone.View.extend({
  tagName: 'tr',

  initialize: function(options) {
    this.shipment_number = options.shipment_number
    this.order_number = options.order_number
    this.quantity = this.$el.data('item-quantity')
    this.variant_id = this.$el.data('variant-id')
    this.render()
  },

  template: HandlebarsTemplates['orders/shipment_item_row'],
  render: function() {
    var price = this.model.get("line_item").price;
    var currency = this.model.shipment.order.get("currency");
    var image = this.model.get("variant").images[0];

    this.$el.html(this.template({
      image: image,
      states: this.model.get("states"),
      variant: this.model.get("variant"),
      price: Spree.formatMoney(price, currency),
      totalPrice: Spree.formatMoney(price * this.model.get("quantity"), currency),
    }))
  },

  events: {
    "click .delete-item": "onDelete",
    "click .split-item": "onSplit",
  },

  removeSplit: function() {
    this.$('.split-item').show();
    this.$('.delete-item').show();
  },

  onSplit: function(e) {
    e.preventDefault();
    this.$('.split-item').toggle();
    this.$('.delete-item').toggle();

    var model = this.model;
    var _this = this;
    Spree.ajax({
      type: "GET",
      url: Spree.routes.variants_api + "/" + this.model.get("variant").id,
    }).success(function(variant){
      var split = new ShipmentSplitItemView({
        shipmentItemView: _this,
        shipment_number: model.shipment.get("number"),
        variant: variant,
        shipments: window.shipments,
        max_quantity: model.get("quantity")
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

var ShipmentTrackingView = Backbone.View.extend({
  tagName: 'tr',
  className: 'shipment-edit-tracking',

  initialize: function(options) {
    this.editing = false;
    this.render()
  },

  events: {
    "click a.edit-tracking": "onToggleEdit",
    "click a.cancel-tracking": "onToggleEdit",
    "click a.save-tracking": "onSave",
  },

  onToggleEdit: function(e) {
    e.preventDefault();
    this.editing = !this.editing;
    this.render();
  },

  onSave: function(e) {
    e.preventDefault();
    var tracking = this.$('[name="tracking"]').val();
    this.model.save({tracking: tracking}, {patch: true});
    this.editing = false;
    this.render();
  },

  render: function() {
    this.$el.html(HandlebarsTemplates['orders/shipment_tracking']({
      editing: this.editing,
      tracking: this.model.get("tracking")
    }))
  }
})

var ShipmentEditMethodView = Backbone.View.extend({
  tagName: 'tr',

  initialize: function(options) {
    this.editing = false;
    this.render()
  },

  events: {
    "click a.edit-method": "onToggleEdit",
    "click a.cancel-method": "onToggleEdit",
    "click a.save-method": "onSave",
  },

  onToggleEdit: function(e) {
    e.preventDefault();
    this.editing = !this.editing;
    this.render()
  },

  onSave: function(e) {
    e.preventDefault();
    var selected_shipping_rate_id = this.$("[name=selected_shipping_rate_id]").val();
    this.model.save({
      selected_shipping_rate_id: Number(selected_shipping_rate_id)
    }, {patch: true});
    this.editing = false;
    this.render();
  },

  render: function() {
    var shippingRates = this.model.get("shipping_rates")
    var selectedRate = _.findWhere(shippingRates, {id: this.model.get("selected_shipping_rate_id")})
    this.$el.html(HandlebarsTemplates['orders/shipment_edit_method']({
      editing: this.editing,
      selectedRate: selectedRate,
      selectedName: (selectedRate || {}).name,
      selectedPrice: Spree.formatMoney((selectedRate || {}).cost, this.model.order.get("currency")),
      shippingRates: shippingRates
    }))
    this.$('select').select2()
  }
})

var ManifestItem = Backbone.Model.extend({
})

var ShipmentEditView = Backbone.View.extend({
  initialize: function(){
    var tbody = this.$("tbody[data-order-number][data-shipment-number]");
    this.shipment_number = tbody.data("shipment-number");
    this.order_number = tbody.data("order-number");

    var shipmentView = this;
    this.$("form.admin-ship-shipment").each(function(el){
      new ShipShipmentView({
        el: this,
        shipment_number: shipmentView.shipment_number
      });
    });

    var shipment = this.model;
    var order = shipment.order;
    var manifest = this.model.get("manifest");
    _.each(manifest, function(manifest_item) {
      var model = new ManifestItem(manifest_item);
      model.shipment = shipment;

      var view = new ShipmentItemView({
        model: model,
        shipment_number: shipmentView.shipment_number,
        order_number: shipmentView.order_number
      })
      view.render();
      tbody.append(view.el);
    });

    var editMethodView = new ShipmentEditMethodView({model: this.model});
    tbody.append(editMethodView.el);

    var trackingView = new ShipmentTrackingView({model: this.model});
    tbody.append(trackingView.el);
  },
});

var initOrderShipmentsPage = function(order) {
  $(".js-shipment-add-variant").each(function(){
    new ShipmentAddVariantView({el: this});
  });

  var shipments = order.get("shipments");

  $(".js-shipment-edit").each(function(){
    var shipment_number = $(this).find('tbody').data('shipment-number');
    var shipment = shipments.findWhere({number: shipment_number});
    new ShipmentEditView({ el: this, model: shipment });

    shipment.on("sync", function(){
      order.fetch();
    })
  });

  new Spree.Order.OrderSummaryView({
    el: $('#order_tab_summary'),
    model: order
  });

  new Spree.Order.OrderDetailsTotalView({
    el: $('#order-total'),
    model: order
  });

  new Spree.Order.OrderDetailsAdjustmentsView({
    el: $('.js-order-line-item-adjustments'),
    model: order,
    collection: order.get("line_items")
  });

  new Spree.Order.OrderDetailsAdjustmentsView({
    el: $('.js-order-shipment-adjustments'),
    model: order,
    collection: order.get("shipments")
  });

  new Spree.Order.OrderDetailsAdjustmentsView({
    el: $('.js-order-adjustments'),
    model: order
  });
}

$(function(){
  if($(".js-shipment-add-variant").length) {
    var order_number = window.order_number;

    var order = Spree.Models.Order.fetch(order_number, {
      success: function() {
        initOrderShipmentsPage(order);
      }
    })
  }
});
