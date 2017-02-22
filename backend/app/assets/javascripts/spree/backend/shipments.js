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
  tagName: 'form',
  className: 'admin-ship-shipment',

  initialize: function(options){
    this.send_mailer = true;
  },

  events: {
    "change [name=send_mailer]": "onChange",
    "click .ship-shipment-button": "onSubmit"
  },

  onChange: function() {
    this.send_mailer = $("[name=send_mailer]").is(":checked");
  },

  onSubmit: function(e) {
    var shipment_number = this.model.id;
    Spree.ajax({
      type: "PUT",
      url: Spree.routes.shipments_api + "/" + shipment_number + "/ship",
      data: {
        send_mailer: this.send_mailer
      },
      success: function(){
        window.location.reload()
      }
    });
    return false;
  },

  render: function() {
    if(this.model.get("state") == "ready") {
      this.$el.html(HandlebarsTemplates['shipments/ship_shipment']({
        send_mailer: this.send_mailer
      }));
    } else {
      this.$el.empty();
    }
  }
});

adjustShipmentItems = function(shipment_number, variant_id, quantity){
  var shipment = _.findWhere(window.shipments, {number: shipment_number});
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
  var shipment = _.find(window.shipments, function(shipment){
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
    this.variant = new Spree.Models.Variant({id: this.model.get("variant").id})
    this.variant.fetch()

    this.listenTo(this.variant, 'sync', this.render)
  },

  events: {
    "click .cancel-split": "cancelItemSplit",
    "click .save-split": "completeItemSplit",
  },

  cancelItemSplit: function(e){
    e.preventDefault();

    this.trigger("cancel")
    this.remove();
  },

  completeItemSplit: function(e){
    e.preventDefault();

    var model = this.model;
    var quantity = this.$('.quantity').val();
    var target = this.$('[name="item_stock_location"]').val().split(':');
    var target_type = target[0];
    var target_id = target[1];

    var split_attr = {
      original_shipment_number: this.model.shipment.get("number"),
      variant_id: this.variant.get("id"),
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
      model.shipment.order.advance();
    });
  },

  template: HandlebarsTemplates['variants/split'],

  render: function() {
    /* Only display other shipments */
    var shipments = this.model.shipment.order.get("shipments");
    shipments = shipments.reject(this.model.shipment);
    shipments = shipments.map(function(s){ return s.attributes });

    var renderAttr = {
      variant: this.variant.attributes,
      shipments: shipments,
      max_quantity: this.model.get("quantity")
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
  className: 'stock-item',

  initialize: function(options) {
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

    var split = new ShipmentSplitItemView({
      model: this.model,
    });
    this.$el.after(split.$el);

    this.listenTo(split, "cancel", this.removeSplit);
  },

  onDelete: function(e){
    e.preventDefault();
    if (confirm(Spree.translations.are_you_sure_delete)) {
      adjustShipmentItems(this.model.shipment.get("number"), this.model.get("variant").id, 0);
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
  className: 'shipment-edit-method',

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
  tagName: 'div',
  className: 'shipment-edit',

  initialize: function(){
    this.shipShipmentView = new ShipShipmentView({
      model: this.model
    });

    this.listenTo(this.model, 'remove', this.onRemove);
    this.listenTo(this.model, 'change', this.render);

    this.render();
  },

  onRemove: function() {
    this.shipShipmentView.remove();
    this.remove();
  },

  render: function() {
    this.$el.attr('id', "shipment_" + this.model.get("id"))
    this.$el.html(HandlebarsTemplates['shipments/edit_shipment']({
      shipment: this.model.attributes,
      order: this.model.order.attributes,
      shipment_state: Spree.t("shipment_states." + this.model.get("state"))
    }))

    var shipment = this.model;

    var tbody = this.$("tbody[data-order-number][data-shipment-number]");
    var manifest = this.model.get("manifest");
    _.each(manifest, function(manifest_item) {
      var model = new ManifestItem(manifest_item);
      model.shipment = shipment;

      var view = new ShipmentItemView({
        model: model
      })
      view.render();
      tbody.append(view.el);
    });

    var editMethodView = new ShipmentEditMethodView({model: this.model});
    tbody.append(editMethodView.el);

    var trackingView = new ShipmentTrackingView({model: this.model});
    tbody.append(trackingView.el);

    this.shipShipmentView.render();
    this.$el.find('fieldset').append(this.shipShipmentView.el);
  },
});

var OrderEditShipmentsView = Backbone.View.extend({
  initialize: function(options){
    this.listenTo(this.collection, 'add', this.addShipment)

    this.collection.each(this.addShipment.bind(this))
  },

  addShipment: function(shipment) {
    var view = new ShipmentEditView({ model: shipment });
    this.$el.append(view.el);
  }
});

var initOrderShipmentsPage = function(order) {
  $(".js-shipment-add-variant").each(function(){
    new ShipmentAddVariantView({el: this});
  });

  var shipments = order.get("shipments");

  new OrderEditShipmentsView({
    el: $(".js-order-edit-shipments"),
    collection: shipments
  });

  var watchShipment = function(shipment){
    shipment.on("sync", function(){
      order.fetch();
    })
  };
  shipments.each(watchShipment);
  shipments.on('add', watchShipment);

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
  if($(".js-order-edit-shipments").length) {
    var order_number = window.order_number;

    var order = Spree.Models.Order.fetch(order_number, {
      success: function() {
        initOrderShipmentsPage(order);
      }
    })
  }
});
