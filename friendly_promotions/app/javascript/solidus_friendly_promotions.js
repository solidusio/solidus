import "@hotwired/turbo-rails";
import "solidus_friendly_promotions/controllers";
import "solidus_friendly_promotions/web_components/option_value_picker"
import "solidus_friendly_promotions/web_components/product_picker"
import "solidus_friendly_promotions/web_components/user_picker"
import "solidus_friendly_promotions/web_components/taxon_picker"

Turbo.session.drive = false;

const initPickers = ({ _target }) => {
  Spree.initNumberWithCurrency();
  $(".variant_autocomplete").variantAutocomplete();
};
document.addEventListener("turbo:frame-load", initPickers);
