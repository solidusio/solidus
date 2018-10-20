// This is called on page load and via an ajax request in
// app/views/spree/admin/promotion_actions/create.js.erb
window.initPromotionActions = function() {
  $('#promotion-filters').find('.variant_autocomplete').variantAutocomplete();

  $('.promo-rule-option-values').each(function() {
    if (!$(this).data('has-view')) {
      $(this).data('has-view', true);
      new Spree.Views.Promotions.OptionValuesRule({
        el: this
      });
    }
  });

  $('.js-tiered-calculator').each(function() {
    if (!$(this).data('has-view')) {
      $(this).data('has-view', true);
      new Spree.Views.Calculators.Tiered({
        el: this
      });
    }
  });
};

Spree.ready(function() {
  // Add classes to boxes when hovering over delete
  $('#promotion-filters').on('mouseover', 'a.delete', function(event) {
    $(this).parent().addClass('action-remove');
  });
  $('#promotion-filters').on('mouseout', 'a.delete', function(event) {
    $(this).parent().removeClass('action-remove');
  });

  window.initPromotionActions();
});
