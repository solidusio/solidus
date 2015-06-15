var initProductActions = function () {
  'use strict';

  // Add classes on promotion items for design
  $(document).on('mouseover mouseout', 'a.delete', function (event) {
    if (event.type === 'mouseover') {
      $(this).parent().addClass('action-remove');
    } else {
      $(this).parent().removeClass('action-remove');
    }
  });

  $('#promotion-filters').find('.variant_autocomplete').variantAutocomplete();

  $('.calculator-fields').each(function () {
    var $fields_container = $(this);
    var $type_select = $fields_container.find('.type-select');
    var $settings = $fields_container.find('.settings');
    var $warning = $fields_container.find('.warning');
    var originalType = $type_select.val();

    $warning.hide();
    $type_select.change(function () {
      if ($(this).val() === originalType) {
        $warning.hide();
        $settings.show();
        $settings.find('input').removeProp('disabled');
      } else {
        $warning.show();
        $settings.hide();
        $settings.find('input').prop('disabled', 'disabled');
      }
    });
  });

  //
  // Tiered Calculator
  //
  if ($('#tier-fields-template').length && $('#tier-input-name').length) {
    var tierFieldsTemplate = Handlebars.compile($('#tier-fields-template').html());
    var tierInputNameTemplate = Handlebars.compile($('#tier-input-name').html());

    var originalTiers = $('.js-original-tiers').data('original-tiers');
    $.each(originalTiers, function(base, value) {
      var fieldName = tierInputNameTemplate({base: base}).trim();
      $('.js-tiers').append(tierFieldsTemplate({
        baseField: {value: base},
        valueField: {name: fieldName, value: value}
      }));
    });

    $(document).on('click', '.js-add-tier', function(event) {
      event.preventDefault();
      $('.js-tiers').append(tierFieldsTemplate({valueField: {name: null}}));
    });

    $(document).on('click', '.js-remove-tier', function(event) {
      $(this).parents('.tier').remove();
    });

    $(document).on('change', '.js-base-input', function(event) {
      var valueInput = $(this).parents('.tier').find('.js-value-input');
      valueInput.attr('name', tierInputNameTemplate({base: $(this).val()}).trim());
    });
  }

};

$(document).ready(function () {

  initProductActions();

});
