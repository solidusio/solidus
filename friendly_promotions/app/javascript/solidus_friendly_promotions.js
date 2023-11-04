import "@hotwired/turbo-rails";
import "solidus_friendly_promotions/controllers";
import "solidus_friendly_promotions/jquery/option_value_picker"

Turbo.session.drive = false;

const initPickers = ({ _target }) => {
  Spree.initNumberWithCurrency();
  $(".product_picker").productAutocomplete();
  $(".user_picker").userAutocomplete();
  $(".taxon_picker").taxonAutocomplete();
  $(".variant_autocomplete").variantAutocomplete();
};
document.addEventListener("turbo:frame-load", initPickers);
document.addEventListener("DOMContentLoaded", initPickers);
