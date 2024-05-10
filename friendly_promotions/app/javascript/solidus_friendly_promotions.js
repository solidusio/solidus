import "@hotwired/turbo-rails";
import "solidus_friendly_promotions/controllers";
import "solidus_friendly_promotions/jquery/option_value_picker"
import "solidus_friendly_promotions/web_components/product_picker"

Turbo.session.drive = false;

const initPickers = ({ _target }) => {
  Spree.initNumberWithCurrency();
  $(".user_picker").userAutocomplete();
  $(".taxon_picker").taxonAutocomplete();
  $(".variant_autocomplete").variantAutocomplete();
};
document.addEventListener("turbo:frame-load", initPickers);
