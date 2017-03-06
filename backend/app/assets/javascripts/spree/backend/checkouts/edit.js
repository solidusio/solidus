$(document).ready(function() {
  if ($("#customer_search").length > 0) {
    var customerSelect = new Spree.Views.Order.CustomerSelect({
      el: $('#customer_search')
    });

    customerSelect.on("select", function(customer) {
      $('#order_email').val(customer.email);
      $('#user_id').val(customer.id);
      $('#guest_checkout_true').prop("checked", false);
      $('#guest_checkout_false').prop("checked", true);
      $('#guest_checkout_false').prop("disabled", false);

      var billAddress = customer.bill_address;
      if (billAddress) {
        $('#order_bill_address_attributes_firstname').val(billAddress.firstname);
        $('#order_bill_address_attributes_lastname').val(billAddress.lastname);
        $('#order_bill_address_attributes_address1').val(billAddress.address1);
        $('#order_bill_address_attributes_address2').val(billAddress.address2);
        $('#order_bill_address_attributes_city').val(billAddress.city);
        $('#order_bill_address_attributes_zipcode').val(billAddress.zipcode);
        $('#order_bill_address_attributes_phone').val(billAddress.phone);

        $('#order_bill_address_attributes_country_id').select2("val", billAddress.country_id).promise().done(function () {
          update_state('b', function () {
            $('#order_bill_address_attributes_state_id').select2("val", billAddress.state_id);
          });
        });
      }
    });
  }

  var order_use_billing_input = $('input#order_use_billing');

  var order_use_billing = function () {
    if (!order_use_billing_input.is(':checked')) {
      $('#shipping').show();
    } else {
      $('#shipping').hide();
    }
  };

  order_use_billing_input.click(function() {
    order_use_billing();
  });

  order_use_billing();

  $('#guest_checkout_true').change(function() {
    $('#customer_search').val("");
    $('#user_id').val("");
    $('#checkout_email').val("");
  });
});
