// Shipments AJAX API
$(document).ready(function () {
  'use strict';

  // handle variant selection, show stock level.
  $('#add_variant_id').change(function(){
    var variant_id = $(this).val();

    var variant = _.find(window.variants, function(variant){
      return variant.id == variant_id
    })
    $('#stock_details').html(variantStockTemplate({variant: variant}));
    $('#stock_details').show();

    $('button.add_variant').click(addVariantFromStockLocation);

    // Add some tips
    $('.with-tip').powerTip({
      smartPlacement: true,
      fadeInTime: 50,
      fadeOutTime: 50,
      intentPollInterval: 300
    });

  });

  //handle edit click
  $('a.edit-item').click(toggleItemEdit);

  //handle cancel click
  $('a.cancel-item').click(toggleItemEdit);

  //handle split click
  $('a.split-item').click(startItemSplit);

  //handle save click
  $('a.save-item').click(function(){
    var save = $(this);
    var shipment_number = save.data('shipment-number');
    var variant_id = save.data('variant-id');

    var quantity = parseInt(save.parents('tr').find('input.line_item_quantity').val());

    toggleItemEdit();
    adjustShipmentItems(shipment_number, variant_id, quantity);
    return false;
  });

  //handle delete click
  $('a.delete-item').click(function(event){
    if (confirm(Spree.translations.are_you_sure_delete)) {
      var del = $(this);
      var line_item_id = del.data('line-item-id');

      toggleItemEdit();
      deleteLineItem(line_item_id);
    }
    return false;
  });

  // add header to ship ujs ajax call
  $("form#admin-ship-shipment").on("ajax:beforeSend", function(event, xhr, settings) {
    xhr.setRequestHeader("X-Spree-Token", Spree.api_key);
  });

  $("form#admin-ship-shipment").on("ajax:success", function(event, xhr, settings) {
    window.location.reload();
  });

  // handle shipping method edit click
  $('a.edit-method').click(toggleMethodEdit);
  $('a.cancel-method').click(toggleMethodEdit);

  // handle shipping method save
  $('[data-hook=admin_shipment_form] a.save-method').on('click', function (event) {
    event.preventDefault();

    var link = $(this);
    var shipment_number = link.data('shipment-number');
    var selected_shipping_rate_id = link.parents('tbody').find("select#selected_shipping_rate_id[data-shipment-number='" + shipment_number + "']").val();
    var url = Spree.routes.shipments_api + '/' + shipment_number + '.json';

    Spree.ajax({
      type: 'PUT',
      url: url,
      data: {
        shipment: {
          selected_shipping_rate_id: selected_shipping_rate_id,
        },
        token: Spree.api_key
      }
    }).done(function () {
      window.location.reload();
    }).error(function (msg) {
      console.log(msg);
    });
  });

  var toggleTrackingEdit = function(event) {
    event.preventDefault();

    var link = $(this);
    link.parents('tbody').find('tr.edit-tracking').toggle();
    link.parents('tbody').find('tr.show-tracking').toggle();
  }

  // handle tracking edit click
  $('a.edit-tracking').click(toggleTrackingEdit);
  $('a.cancel-tracking').click(toggleTrackingEdit);

  // handle tracking save
  $('[data-hook=admin_shipment_form] a.save-tracking').on('click', function (event) {
    event.preventDefault();

    var link = $(this);
    var shipment_number = link.data('shipment-number');
    var tracking = link.parents('tbody').find('input#tracking').val();
    var url = Spree.routes.shipments_api + '/' + shipment_number + '.json';

    Spree.ajax({
      type: 'PUT',
      url: url,
      data: {
        shipment: {
          tracking: tracking
        },
        token: Spree.api_key
      }
    }).done(function (data) {
      link.parents('tbody').find('tr.edit-tracking').toggle();

      var show = link.parents('tbody').find('tr.show-tracking');
      show.toggle();
      show.find('.tracking-value').html($("<strong>").html(Spree.translations.tracking + ": ")).append(data.tracking);
    });
  });
});

adjustShipmentItems = function(shipment_number, variant_id, quantity){
    var shipment = _.findWhere(shipments, {number: shipment_number + ''});
    var inventory_units = _.where(shipment.inventory_units, {variant_id: variant_id});

    var url = Spree.routes.shipments_api + "/" + shipment_number;

    var new_quantity = 0;
    if(inventory_units.length<quantity){
      url += "/add"
      new_quantity = (quantity - inventory_units.length);
    }else if(inventory_units.length>quantity){
      url += "/remove"
      new_quantity = (inventory_units.length - quantity);
    }
    url += '.json';

    if(new_quantity!=0){
      Spree.ajax({
        type: "PUT",
        url: Spree.url(url),
        data: {
          variant_id: variant_id,
          quantity: new_quantity,
        },
        success: function(response) {
          window.location.reload();
        },
        error: function(response) {
          show_flash('error', response.responseJSON.message);
        }
      });
    }
}

deleteLineItem = function(line_item_id){
  var url = Spree.routes.line_items_api(order_number) + "/" + line_item_id + ".json";

  Spree.ajax({
    type: "DELETE",
    url: Spree.url(url),
    success: function(response) {
      window.location.reload();
    },
    error: function(response) {
      show_flash('error', response.responseJSON.message);
    }
  });
}

toggleMethodEdit = function(){
  var link = $(this);
  link.parents('tbody').find('tr.edit-method').toggle();
  link.parents('tbody').find('tr.show-method').toggle();

  return false;
}

toggleItemEdit = function(){
  var link = $(this);
  link.parent().find('a.edit-item').toggle();
  link.parent().find('a.cancel-item').toggle();
  link.parent().find('a.split-item').toggle();
  link.parent().find('a.save-item').toggle();
  link.parent().find('a.delete-item').toggle();
  link.parents('tr').find('td.item-qty-show').toggle();
  link.parents('tr').find('td.item-qty-edit').toggle();

  return false;
}

startItemSplit = function(event){
  event.preventDefault();
  var link = $(this);
  link.parent().find('a.edit-item').toggle();
  link.parent().find('a.split-item').toggle();
  link.parent().find('a.delete-item').toggle();
  var variant_id = link.data('variant-id');

  var variant = {};
  Spree.ajax({
    type: "GET",
    async: false,
    url: Spree.routes.variants_api,
    data: {
      q: {
        "id_eq": variant_id
      },
      token: Spree.api_key
    }
  }).success(function( data ) {
    variant = data['variants'][0];
  }).error(function( msg ) {
    console.log(msg);
  });

  var max_quantity = link.closest('tr').data('item-quantity');
  var split_item_template = HandlebarsTemplates['variants/split'];
  link.closest('tr').after(split_item_template({ variant: variant, shipments: shipments, max_quantity: max_quantity }));
  $('a.cancel-split').click(cancelItemSplit);
  $('a.save-split').click(completeItemSplit);

  // Add some tips
  $('.with-tip').powerTip({
    smartPlacement: true,
    fadeInTime: 50,
    fadeOutTime: 50,
    intentPollInterval: 300
  });
  $('#item_stock_location').select2({ width: 'resolve', placeholder: Spree.translations.item_stock_placeholder });
}

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
        async: false,
        url: Spree.routes.shipments_api + "/transfer_to_location",
        data: {
            original_shipment_number: original_shipment_number,
            variant_id: variant_id,
            quantity: quantity,
            stock_location_id: stock_location_id,
            token: Spree.api_key
        }
      }).error(function(msg) {
          alert(msg.responseJSON['message']);
      }).done(function(msg) {
        window.Spree.advanceOrder();
      });
    } else {
        // TRANSFER TO AN EXISTING SHIPMENT
        Spree.ajax({
            type: "POST",
            async: false,
            url: Spree.routes.shipments_api + "/transfer_to_shipment",
            data: {
                original_shipment_number: original_shipment_number,
                target_shipment_number: target_shipment_number,
                variant_id: variant_id,
                quantity: quantity,
                token: Spree.api_key
            }
        }).error(function(msg) {
            alert(msg.responseJSON['message']);
        }).done(function(msg) {
            window.Spree.advanceOrder();
        });
    }
  }
}

cancelItemSplit = function(event) {
  event.preventDefault();
  var link = $(this);
  var prev_row = link.closest('tr').prev();
  link.closest('tr').remove();
  prev_row.find('a.edit-item').toggle();
  prev_row.find('a.split-item').toggle();
  prev_row.find('a.delete-item').toggle();
}

addVariantFromStockLocation = function(event) {
  event.preventDefault();

  $('#stock_details').hide();

  var variant_id = $('input.variant_autocomplete').val();
  var stock_location_id = $(this).data('stock-location-id');
  var quantity = $("input.quantity[data-stock-location-id='" + stock_location_id + "']").val();

  var shipment = _.find(shipments, function(shipment){
    return shipment.stock_location_id == stock_location_id && (shipment.state == 'ready' || shipment.state == 'pending');
  });

  if(shipment==undefined){
    Spree.ajax({
      type: "POST",
      url: Spree.routes.shipments_api + "?shipment[order_id]=" + order_number,
      data: {
        variant_id: variant_id,
        quantity: quantity,
        stock_location_id: stock_location_id,
      }
    }).done(function( msg ) {
      window.location.reload();
    }).error(function( msg ) {
      console.log(msg);
    });
  }else{
    //add to existing shipment
    adjustShipmentItems(shipment.number, variant_id, quantity);
  }
  return 1
}
