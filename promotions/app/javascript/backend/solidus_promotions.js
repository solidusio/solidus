import "@hotwired/turbo-rails";
import "backend/solidus_promotions/controllers";
import "backend/solidus_promotions/web_components/option_value_picker"
import "backend/solidus_promotions/web_components/product_picker"
import "backend/solidus_promotions/web_components/user_picker"
import "backend/solidus_promotions/web_components/taxon_picker"
import "backend/solidus_promotions/web_components/variant_picker"
import "backend/solidus_promotions/web_components/number_with_currency"
import "backend/solidus_promotions/web_components/select_two"

Turbo.session.drive = false;
