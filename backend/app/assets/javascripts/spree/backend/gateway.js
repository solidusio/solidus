Spree.ready(function() {
  var $gateway_type = $('select.js-gateway-type');
  var $preference_source = $('select.js-preference-source');
  var original_gateway_type = $gateway_type.val();
  var original_preference_source = $preference_source.val();

  var render = function() {
    var gateway_type = $gateway_type.val();
    var preference_source = $preference_source.val();
    $('.js-preference-source-wrapper').toggle(gateway_type === original_gateway_type);
    if (gateway_type === original_gateway_type && preference_source === original_preference_source) {
      $('.js-gateway-settings').show();
      $('.js-gateway-settings-warning').hide();
    } else {
      $('.js-gateway-settings').hide();
      $('.js-gateway-settings-warning').show();
    }
  };
  $gateway_type.change(render);
  $preference_source.change(render);
  render();
});
