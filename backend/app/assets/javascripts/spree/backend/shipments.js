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

$(function(){
  $(".js-shipment-add-variant").each(function(){
    new ShipmentAddVariantView({el: this});
  });
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
        send_mailer: this.$("[name='send_mailer']").val()
      },
      success: function(){
        window.location.reload()
      }
    });
    return false;
  }
});

updateShipment = function(shipment_number, attributes) {
  var url = Spree.routes.shipments_api + '/' + shipment_number;

  return Spree.ajax({
    type: 'PUT',
    url: url,
    data: {
      shipment: attributes
    }
  });
};

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

startItemSplit = function(event){
  event.preventDefault();
  var link = $(this);
  link.parent().find('a.split-item').toggle();
  link.parent().find('a.delete-item').toggle();
  var variant_id = link.data('variant-id');

  Spree.ajax({
    type: "GET",
    url: Spree.routes.variants_api + "/" + variant_id,
  }).success(function(variant){
    var max_quantity = link.closest('tr').data('item-quantity');
    var split_item_template = HandlebarsTemplates['variants/split'];
    link.closest('tr').after(split_item_template({ variant: variant, shipments: shipments, max_quantity: max_quantity }));

    $('#item_stock_location').select2({
      width: 'resolve',
      placeholder: Spree.translations.item_stock_placeholder,
      minimumResultsForSearch: 8
    });
  });
};

completeItemSplit = function(event) {
  event.preventDefault();

  if($('#item_stock_location').val() === ""){
    alert('Please select the split destination.');
    return false;
  }

  var link = $(this);
  var stock_item_row = link.closest('tr');
  var variant_id = stock_item_row.data('variant-id');
  var quantity = stock_item_row.find('#item_quantity').val();

  var stock_location_id = stock_item_row.find('#item_stock_location').val();
  var original_shipment_number = link.closest('tbody').data('shipment-number');

  var selected_shipment = stock_item_row.find($('#item_stock_location').select2('data').element);
  var target_shipment_number = selected_shipment.data('shipment-number');
  var new_shipment = selected_shipment.data('new-shipment');

  if (stock_location_id != 'new_shipment') {
    if (new_shipment != undefined) {
      // TRANSFER TO A NEW LOCATION
      Spree.ajax({
        type: "POST",
        url: Spree.routes.shipments_api + "/transfer_to_location",
        data: {
          original_shipment_number: original_shipment_number,
          variant_id: variant_id,
          quantity: quantity,
          stock_location_id: stock_location_id
        }
      }).error(function(msg) {
        alert(msg.responseJSON['message']);
      }).done(function() {
        window.Spree.advanceOrder();
      });
    } else {
      // TRANSFER TO AN EXISTING SHIPMENT
      Spree.ajax({
        type: "POST",
        url: Spree.routes.shipments_api + "/transfer_to_shipment",
        data: {
          original_shipment_number: original_shipment_number,
          target_shipment_number: target_shipment_number,
          variant_id: variant_id,
          quantity: quantity
        }
      }).error(function(msg) {
        alert(msg.responseJSON['message']);
      }).done(function() {
        window.Spree.advanceOrder();
      });
    }
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
          order_id: order_number
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

var ShipmentEditView = Backbone.View.extend({
  initialize: function(){
    var tbody = this.$("tbody[data-order-number][data-shipment-number]");
    var shipment_number = tbody.data("shipment-number");
    this.shipment_number = shipment_number;
    this.order_number = tbody.data("order-number");

    this.$("form.admin-ship-shipment").each(function(){
      new ShipShipmentView({
        el: this,
        shipment_number: shipment_number
      });
    });
  },

  events: {
    "click a.delete-item": "deleteItem",

    "click a.split-item": "startItemSplit",
    "click a.cancel-split": "cancelItemSplit",
    "click a.save-split": "completeItemSplit",

    "click a.edit-method": "toggleMethodEdit",
    "click a.cancel-method": "toggleMethodEdit",
    "click a.save-method": "saveMethod",

    "click a.edit-tracking": "toggleTrackingEdit",
    "click a.cancel-tracking": "toggleTrackingEdit",
    "click a.save-tracking": "saveTracking",
  },

  deleteItem: function(e){
    e.preventDefault();
    if (confirm(Spree.translations.are_you_sure_delete)) {
      var del = $(e.currentTarget);
      var variant_id = del.data('variant-id');

      adjustShipmentItems(this.shipment_number, variant_id, 0);
    }
  },

  startItemSplit: function(e){
    e.preventDefault();
    startItemSplit.apply(e.currentTarget, [e]);
  },

  cancelItemSplit: function(e){
    e.preventDefault();

    this.$('tr.stock-item-split').remove();
    this.$('a.split-item').show();
    this.$('a.delete-item').show();
  },

  completeItemSplit: function(e){
    completeItemSplit.apply(e.currentTarget, [e]);
  },

  toggleMethodEdit: function(e){
    e.preventDefault();
    this.$('tr.edit-method').toggle();
    this.$('tr.show-method').toggle();
  },

  saveMethod: function(e) {
    e.preventDefault();
    var selected_shipping_rate_id = this.$("select#selected_shipping_rate_id").val();
    updateShipment(this.shipment_number, {
      selected_shipping_rate_id: selected_shipping_rate_id
    }).done(function () {
      window.location.reload();
    });
  },

  toggleTrackingEdit: function(e) {
    e.preventDefault();
    this.$("tr.edit-tracking").toggle();
    this.$("tr.show-tracking").toggle();
  },

  saveTracking: function(e) {
    e.preventDefault();
    var tracking = this.$('input#tracking').val();
    var _this = this;
    updateShipment(this.shipment_number, {
      tracking: tracking
    }).done(function (data) {
      _this.$('tr.edit-tracking').toggle();

      var show = _this.$('tr.show-tracking');
      show.toggle()
          .find('.tracking-value')
          .html($("<strong>")
          .html(Spree.translations.tracking + ": "))
          .append(document.createTextNode(data.tracking));
    });
  }
});

$(function(){
  $(".js-shipment-edit").each(function(){
    new ShipmentEditView({ el: this });
  });
});
