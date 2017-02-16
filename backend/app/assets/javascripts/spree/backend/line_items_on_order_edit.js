// This file contains the code for interacting with line items in the manual cart
$(document).ready(function () {
    'use strict';

    // handle variant selection, show stock level.
    $('#add_line_item_variant_id').change(function(){
        var variant_id = $(this).val();

        var variant = _.find(window.variants, function(variant){
            return variant.id == variant_id
        })

        var variantLineItemTemplate = HandlebarsTemplates["variants/line_items_autocomplete_stock"];
        $('#stock_details').html(variantLineItemTemplate({variant: variant}));
        $('#stock_details').show();

        $('button.add_variant').click(addVariant);
    });
});

addVariant = function() {
    $('#stock_details').hide();

    var variant_id = $('input.variant_autocomplete').val();
    var total_quantity = $("input#variant_quantity").val();

    adjustLineItems(order_number, variant_id, total_quantity);
    return 1
}

adjustLineItems = function(order_number, variant_id, quantity){
    var url = Spree.routes.orders_api + "/" + order_number + '/line_items';

    Spree.ajax({
        type: "POST",
        url: url,
        data: {
          line_item: {
            variant_id: variant_id,
            quantity: quantity
          },
        }
    }).done(function( msg ) {
        window.Spree.advanceOrder();
        window.location.reload();
    });

}
