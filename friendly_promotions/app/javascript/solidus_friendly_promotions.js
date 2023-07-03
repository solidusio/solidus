import "@hotwired/turbo-rails";
import "solidus_friendly_promotions/controllers";
import "solidus_friendly_promotions/jquery/option_value_picker"

Turbo.session.drive = false;

document.addEventListener("turbo:frame-load", ({ _target }) => {
  Spree.initNumberWithCurrency();
  $(".product_picker").productAutocomplete();
  $(".user_picker").userAutocomplete();
  $(".taxon_picker").taxonAutocomplete();
});
