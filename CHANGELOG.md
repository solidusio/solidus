## Solidus 2.5.0 (master, unreleased)

## Solidus 2.4.0 (unreleased)

### Major changes

- Replace RABL with Jbuilder [#2147](https://github.com/solidusio/solidus/pull/2147) [#2146](https://github.com/solidusio/solidus/pull/2146) ([jhawthorn](https://github.com/jhawthorn))

  We've changed our JSON templating language for both the API and admin from
  [RABL](https://github.com/nesquena/rabl) to [Jbuilder](https://github.com/rails/jbuilder).
  Jbuilder is faster and much more widely used (ships with Rails).

  API responses should be identical, but stores which customized API responses
  using RABL or added their own endpoints which extended Solidus' RABL partials
  will need to be updated.

- Remove rescue\_from StandardError in Api::BaseController [#2139](https://github.com/solidusio/solidus/pull/2139) ([jhawthorn](https://github.com/jhawthorn))

  Previously, exceptions raised in the API were caught (via `rescue_from`) and
  didn't reach the default Rails error handler. This caused many exceptions to
  avoid notice, both in production and in tests.

  This has been removed and exceptions are now reported and handled normally.

- New admin table design [#2159](https://github.com/solidusio/solidus/pull/2159) [#2100](https://github.com/solidusio/solidus/pull/2100) [#2143](https://github.com/solidusio/solidus/pull/2143) [#2123](https://github.com/solidusio/solidus/pull/2123) [#2165](https://github.com/solidusio/solidus/pull/2165) ([Mandily](https://github.com/Mandily), [graygilmore](https://github.com/graygilmore), [tvdeyen](https://github.com/tvdeyen))

  Tables throughout the admin have been redesigned to be simpler and clearer.
  Borders between cells of the same row have been dropped, row striping has been
  removed, and icons are simpler and more clearly attached to their row.

- Introduce Stock::SimpleCoordinator [#2199](https://github.com/solidusio/solidus/pull/2199) ([jhawthorn](https://github.com/jhawthorn))

  The previous stock coordinator had incorrect behaviour when any stock location was low on stock.

  The existing stock coordinator classes, Coordinator, Adjuster, Packer, and
  Prioritizer, have been replaced with the new Stock::SimpleCoordinator. In most
  cases this will coordinate stock identically to the old system, but will
  succeed for several low-stock cases the old Coordinator incorrectly failed on.

  Stores which have customized any of the old Coordinator classes will need to
  either update their customizations or include the [solidus_legacy_stock_system](https://github.com/solidusio-contrib/solidus_legacy_stock_system)
  extension, which provides the old classes.


### Core

- Replace Stock::Coordinator with Stock::SimpleCoordinator [#2199](https://github.com/solidusio/solidus/pull/2199) ([jhawthorn](https://github.com/jhawthorn))
- Wrap Splitter chaining behaviour in new Stock::SplitterChain class [#2189](https://github.com/solidusio/solidus/pull/2189) ([jhawthorn](https://github.com/jhawthorn))
- Remove Postal Code Format Validation (and Twitter CLDR dependency) [#2233](https://github.com/solidusio/solidus/pull/2233) ([mamhoff](https://github.com/mamhoff))
- Switch factories to strings instead of constants [#2230](https://github.com/solidusio/solidus/pull/2230) ([cbrunsdon](https://github.com/cbrunsdon))
- Roll up migrations up to Solidus 1.4 into a single migration [#2229](https://github.com/solidusio/solidus/pull/2229) ([cbrunsdon](https://github.com/cbrunsdon))
- Support non-promotion line-level adjustments [#2188](https://github.com/solidusio/solidus/pull/2188) ([jordan-brough](https://github.com/jordan-brough))
- Fix StoreCredit with multiple currencies [#2183](https://github.com/solidusio/solidus/pull/2183) ([jordan-brough](https://github.com/jordan-brough))
- Add `Spree::Price` to `ProductManagement` role [#2182](https://github.com/solidusio/solidus/pull/2182) ([swcraig](https://github.com/swcraig))
- Remove duplicate error on StoreCredit#authorize failure [#2180](https://github.com/solidusio/solidus/pull/2180) ([jordan-brough](https://github.com/jordan-brough))
- Add `dependent: :destroy` for ShippingMethodZones join model [#2175](https://github.com/solidusio/solidus/pull/2175) ([jordan-brough](https://github.com/jordan-brough))
- Fix method missing error in ReturnAuthorization#amount [#2162](https://github.com/solidusio/solidus/pull/2162) ([luukveenis](https://github.com/luukveenis))
- Use constants instead of translations for `StoreCreditType` names [#2157](https://github.com/solidusio/solidus/pull/2157) ([swcraig](https://github.com/swcraig))
- Enable custom shipping promotions via config.spree.promotions.shipping_actions [#2135](https://github.com/solidusio/solidus/pull/2135) ([jordan-brough](https://github.com/jordan-brough))
- Validate that Refunds have an associated Payment [#2130](https://github.com/solidusio/solidus/pull/2130) ([melissacarbone](https://github.com/melissacarbone))
- Include completed payment amounts when summing totals for store credit [#2129](https://github.com/solidusio/solidus/pull/2129) ([luukveenis](https://github.com/luukveenis))
- Allow dev mode code reloading of configured classes [#2126](https://github.com/solidusio/solidus/pull/2126) ([jhawthorn](https://github.com/jhawthorn))
- Override model_name.human for PaymentMethod [#2107](https://github.com/solidusio/solidus/pull/2107) ([jhawthorn](https://github.com/jhawthorn))
- Fix class/module nesting [#2098](https://github.com/solidusio/solidus/pull/2098) ([cbrunsdon](https://github.com/cbrunsdon))
- Reduce number of SQL statements in countries seeds [#2097](https://github.com/solidusio/solidus/pull/2097) ([jhawthorn](https://github.com/jhawthorn))
- Rename Order#update! to order.recalculate [#2072](https://github.com/solidusio/solidus/pull/2072) ([jhawthorn](https://github.com/jhawthorn))
- Rename Adjustment#update! to Adjustment#recalculate [#2086](https://github.com/solidusio/solidus/pull/2086) ([jhawthorn](https://github.com/jhawthorn))
- Rename Shipment#update! to Shipment#update_state [#2085](https://github.com/solidusio/solidus/pull/2085) ([jhawthorn](https://github.com/jhawthorn))
- Fix shipping method factory for stores with alternate currency [#2084](https://github.com/solidusio/solidus/pull/2084) ([Sinetheta](https://github.com/Sinetheta))

- Added a configurable `Spree::Payment::Cancellation` class [\#2111](https://github.com/solidusio/solidus/pull/2111) ([tvdeyen](https://github.com/tvdeyen))

- Remove `set_current_order` calls in `Spree::Core::ControllerHelpers::Order`
  [\#2185](https://github.com/solidusio/solidus/pull/2185) ([Murph33](https://github.com/murph33))

  Previously a before filter added in
  `core/lib/spree/core/controller_helpers/order.rb` would cause SQL queries to
  be used on almost every request in the frontend. If you do not use Solidus
  Auth you will need to hook into this helper and call `set_current_order` where
  your user signs in. This merges incomplete orders a user has going with their
  current cart. If you do use Solidus Auth you will need to make sure you use a
  current enough version (>= v1.5.0) that includes this explicit call. This
  addresses [\#1116](https://github.com/solidusio/solidus/issues/1116).

- Remove `ffaker` as a runtime dependency in production. It needs to be added to the Gemfile for factories to be used in tests [#2163](https://github.com/solidusio/solidus/pull/2163) [\#2140](https://github.com/solidusio/solidus/pull/2140) ([cbrunsdon](https://github.com/cbrunsdon), [swcraig](https://github.com/swcraig))

- Invalidate existing non store credit payments during checkout [2075](https://github.com/solidusio/solidus/pull/2075) ([tvdeyen](https://github.com/tvdeyen))

- The all configuration objects now use static preferences by default. It's no longer necessary to call `use_static_preferences!`, as that is the new default. For the old behaviour of loading preferences from the DB, call `config.use_legacy_db_preferences!`. [\#2112](https://github.com/solidusio/solidus/pull/2112) ([jhawthorn](https://github.com/jhawthorn))

- Assign and initialize Spree::Config earlier, before rails initializers [\#2178](https://github.com/solidusio/solidus/pull/2178) ([cbrunsdon](https://github.com/cbrunsdon))

### API
- Replace RABL with Jbuilder [#2147](https://github.com/solidusio/solidus/pull/2147) [#2146](https://github.com/solidusio/solidus/pull/2146) ([jhawthorn](https://github.com/jhawthorn))
- Move API pagination into a common partial [#2181](https://github.com/solidusio/solidus/pull/2181) ([jhawthorn](https://github.com/jhawthorn))
- Fix references to nonexistent API attributes [#2153](https://github.com/solidusio/solidus/pull/2153) ([jhawthorn](https://github.com/jhawthorn))
- Remove rescue_from StandardError in Api::BaseController [#2139](https://github.com/solidusio/solidus/pull/2139) ([jhawthorn](https://github.com/jhawthorn))
- Fix error when passing coupon_code to api/checkouts#update [#2136](https://github.com/solidusio/solidus/pull/2136) ([jhawthorn](https://github.com/jhawthorn))
- Improved error handling and performance for moving inventory units between shipments and stock locations [\#2070](https://github.com/solidusio/solidus/pull/2070) ([mamhoff](https://github.com/mamhoff))
- Remove unnecessary Api::Engine.root override [#2128](https://github.com/solidusio/solidus/pull/2128) ([jhawthorn](https://github.com/jhawthorn))

### Admin
- Upgrade to Bootstrap 4.0.0-beta [#2156](https://github.com/solidusio/solidus/pull/2156) ([jhawthorn](https://github.com/jhawthorn))
- Admin Sass Organization [#2133](https://github.com/solidusio/solidus/pull/2133) ([graygilmore](https://github.com/graygilmore))
- Remove Skeleton Grid CSS from the admin and complete its transition to Bootstrap. [\#2127](https://github.com/solidusio/solidus/pull/2127) ([graygilmore](https://github.com/graygilmore))
- Fix issue with user_id not being set on "customer" page [#2176](https://github.com/solidusio/solidus/pull/2176) ([ericsaupe](https://github.com/ericsaupe), [swcraig](https://github.com/swcraig))
- Removed the admin functionality to modify countries and states [\#2118](https://github.com/solidusio/solidus/pull/2118) ([graygilmore](https://github.com/graygilmore)). This functionality, if required, is available through the [solidus_countries_backend](https://github.com/solidusio-contrib/solidus_countries_backend) extension.
- Change table action icons style [#2100](https://github.com/solidusio/solidus/pull/2100) ([tvdeyen](https://github.com/tvdeyen))
- Use number_with_currency widget on new refund page [#2088](https://github.com/solidusio/solidus/pull/2088) ([jhawthorn](https://github.com/jhawthorn))
- Fix admin user order history table [#2226](https://github.com/solidusio/solidus/pull/2226) ([Sinetheta](https://github.com/Sinetheta))
- Replace Admin table styles [#2159](https://github.com/solidusio/solidus/pull/2159) ([Mandily](https://github.com/Mandily), [graygilmore](https://github.com/graygilmore), [tvdeyen](https://github.com/tvdeyen), [jhawthorn](https://github.com/jhawthorn))
- Inherit body colour for labels [#2242](https://github.com/solidusio/solidus/pull/2242) ([jhawthorn](https://github.com/jhawthorn))
- Remove action button background color [#2144](https://github.com/solidusio/solidus/pull/2144) ([tvdeyen](https://github.com/tvdeyen))
- Remove images border in tables [#2143](https://github.com/solidusio/solidus/pull/2143) ([tvdeyen](https://github.com/tvdeyen))
- Pill Component [#2123](https://github.com/solidusio/solidus/pull/2123) ([graygilmore](https://github.com/graygilmore))
- Display a pointer cursor hovering add variant buttons [#2062](https://github.com/solidusio/solidus/pull/2062) ([kennyadsl](https://github.com/kennyadsl))
- Use translated model names in admin payment methods form [#1975](https://github.com/solidusio/solidus/pull/1975) ([tvdeyen](https://github.com/tvdeyen))
- Add missing default_currency field on admin/stores [#2091](https://github.com/solidusio/solidus/pull/2091) ([oeN](https://github.com/oeN))
- UI Fixes for taxons tree [#2148](https://github.com/solidusio/solidus/pull/2148) ([tvdeyen](https://github.com/tvdeyen))
- Make checkout billing address inputs full width [#2171](https://github.com/solidusio/solidus/pull/2171) ([notapatch](https://github.com/notapatch))
- Fixes padding of lists in form fields [#2170](https://github.com/solidusio/solidus/pull/2170) ([tvdeyen](https://github.com/tvdeyen))
- Capitalize event buttons in `OrdersHelper` [#2177](https://github.com/solidusio/solidus/pull/2177) ([swcraig](https://github.com/swcraig))
- Fix backend data-action across multiple files [#2184](https://github.com/solidusio/solidus/pull/2184) ([kennyadsl](https://github.com/kennyadsl))
- New users table layout [#1842](https://github.com/solidusio/solidus/pull/1842) ([tvdeyen](https://github.com/tvdeyen))
- Add headers to shipment method and tracking number [#2169](https://github.com/solidusio/solidus/pull/2169) ([tvdeyen](https://github.com/tvdeyen))
- Fix typo on shipment method edit [#2168](https://github.com/solidusio/solidus/pull/2168) ([jhawthorn](https://github.com/jhawthorn))
- Fix action button hover style [#2167](https://github.com/solidusio/solidus/pull/2167) ([tvdeyen](https://github.com/tvdeyen))
- Show table borders on action columns [#2165](https://github.com/solidusio/solidus/pull/2165) ([jhawthorn](https://github.com/jhawthorn))
- Tweak font styles on admin shipments page [#2164](https://github.com/solidusio/solidus/pull/2164) ([jhawthorn](https://github.com/jhawthorn))
- Use payment.number instead of payment.identifier in admin view [#2222](https://github.com/solidusio/solidus/pull/2222) ([jordan-brough](https://github.com/jordan-brough))
- Exclude Bootstrap buttons from our button styling [#2158](https://github.com/solidusio/solidus/pull/2158) ([graygilmore](https://github.com/graygilmore))
- Move users search form above table [#2094](https://github.com/solidusio/solidus/pull/2094) ([graygilmore](https://github.com/graygilmore))
- Preview Images in a Modal [#2101](https://github.com/solidusio/solidus/pull/2101) ([graygilmore](https://github.com/graygilmore))

### Frontend
- Change product's price color away from link color [#2174](https://github.com/solidusio/solidus/pull/2174) ([notapatch](https://github.com/notapatch))
- Move OrdersHelper from Core to Frontend [#2081](https://github.com/solidusio/solidus/pull/2081) ([dangerdogz](https://github.com/dangerdogz))
- Checkout email input field should use email_field [#2120](https://github.com/solidusio/solidus/pull/2120) ([notapatch](https://github.com/notapatch))

### Removals
- Remove unused Paperclip spec matchers [#2197](https://github.com/solidusio/solidus/pull/2197) ([swcraig](https://github.com/swcraig))
- Remove tax refunds [#2196](https://github.com/solidusio/solidus/pull/2196) ([mamhoff](https://github.com/mamhoff))
- Remove PriceMigrator [#2194](https://github.com/solidusio/solidus/pull/2194) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove task to copy shipped shipments to cartons [#2193](https://github.com/solidusio/solidus/pull/2193) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove upgrade task/spec [#2192](https://github.com/solidusio/solidus/pull/2192) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove unhelpful preload in Stock::Estimator [#2207](https://github.com/solidusio/solidus/pull/2207) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused register call in calculator [#2206](https://github.com/solidusio/solidus/pull/2206) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove autoload on product_filters [#2190](https://github.com/solidusio/solidus/pull/2190) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove identical inheritied methods in `Spree::StoreCredit` [#2200](https://github.com/solidusio/solidus/pull/2200) ([swcraig](https://github.com/swcraig))
- Remove custom responders. They are now available in the `solidus_responders` extension. [#1956](https://github.com/solidusio/solidus/pull/1956) ([omnistegan](https://github.com/omnistegan))
- Remove responders dependency from core [#2090](https://github.com/solidusio/solidus/pull/2090) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove unused update_params_payment_source method [#2227](https://github.com/solidusio/solidus/pull/2227) ([ccarruitero](https://github.com/ccarruitero))

### Deprecations

- Deprecate .calculators [#2216](https://github.com/solidusio/solidus/pull/2216) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate pagination in searcher [#2119](https://github.com/solidusio/solidus/pull/2119) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate tasks in core/lib/tasks [#2080](https://github.com/solidusio/solidus/pull/2080) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate Spree::OrderCapturing class [#2076](https://github.com/solidusio/solidus/pull/2076) ([tvdeyen](https://github.com/tvdeyen))
- Deprecated `Spree::PaymentMethod#cancel` [\#2111](https://github.com/solidusio/solidus/pull/2111) ([tvdeyen](https://github.com/tvdeyen))
  Please implement a `try_void` method on your payment method instead that returns a response object if void succeeds or false if not. Solidus will refund the payment then.
- Deprecates several preference fields helpers in favor of preference field partials. [\#2040](https://github.com/solidusio/solidus/pull/2040) ([tvdeyen](https://github.com/tvdeyen))
  Please render `spree/admin/shared/preference_fields/#{preference_type}` instead
- Check if deprecated method_type is overridden [#2093](https://github.com/solidusio/solidus/pull/2093) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate support for alternate Kaminari page_method_name [#2115](https://github.com/solidusio/solidus/pull/2115) ([cbrunsdon](https://github.com/cbrunsdon))



## Solidus 2.3.0 (2017-07-31)

- Rails 5.1 [\#1895](https://github.com/solidusio/solidus/pull/1895) ([jhawthorn](https://github.com/jhawthorn))

- The default behaviour for selecting the current store has changed. Stores are now only returned if their url matches the current domain exactly (falling back to the default store) [\#2041](https://github.com/solidusio/solidus/pull/2041) [\#1993](https://github.com/solidusio/solidus/pull/1993) ([jhawthorn](https://github.com/jhawthorn), [kennyadsl](https://github.com/kennyadsl))

- Remove dependency on premailer gem [\#2061](https://github.com/solidusio/solidus/pull/2061) ([cbrunsdon](https://github.com/cbrunsdon))

- Order#outstanding_balance now uses reimbursements instead of refunds to calculate the amount that should be paid on an order. [#2002](https://github.com/solidusio/solidus/pull/2002) (many contributors :heart:)

- Renamed bogus payment methods [\#2000](https://github.com/solidusio/solidus/pull/2000) ([tvdeyen](https://github.com/tvdeyen))
  `Spree::Gateway::BogusSimple` and `Spree::Gateway::Bogus` were renamed into `Spree::PaymentMethod::SimpleBogusCreditCard` and `Spree::PaymentMethod::BogusCreditCard`

- Allow refreshing shipping rates for unshipped shipments on completed orders [\#1906](https://github.com/solidusio/solidus/pull/1906) ([mamhoff](https://github.com/mamhoff))
- Remove line_item_options class attribute from Api::LineItemsController [\#1943](https://github.com/solidusio/solidus/pull/1943)
- Allow custom separator between a promotion's `base_code` and `suffix` [\#1951](https://github.com/solidusio/solidus/pull/1951) ([ericgross](https://github.com/ericgross))
- Ignore `adjustment.finalized` on tax adjustments. [\#1936](https://github.com/solidusio/solidus/pull/1936) ([jordan-brough](https://github.com/jordan-brough))
- Transform the relation between TaxRate and TaxCategory to a Many to Many [\#1851](https://github.com/solidusio/solidus/pull/1851) ([vladstoick](https://github.com/vladstoick))

  This fixes issue [\#1836](https://github.com/solidusio/solidus/issues/1836). By allowing a TaxRate to tax multiple categories, stores don't have to create multiple TaxRates with the same value if a zone doesn't have different tax rates for some tax categories.

- Adjustments without a source are now included in `line_item.adjustment_total` [\#1933](https://github.com/solidusio/solidus/pull/1933) ([alexstoick](https://github.com/alexstoick))
- Always update last\_ip\_address on order [\#1658](https://github.com/solidusio/solidus/pull/1658) ([bbuchalter](https://github.com/bbuchalter))
- Don't eager load adjustments in current\_order [\#2069](https://github.com/solidusio/solidus/pull/2069) ([jhawthorn](https://github.com/jhawthorn))
- Avoid running validations in current\_order [\#2068](https://github.com/solidusio/solidus/pull/2068) ([jhawthorn](https://github.com/jhawthorn))
- Fix Paperclip::Errors::NotIdentifiedByImageMagickError on invalid image [\#2064](https://github.com/solidusio/solidus/pull/2064) ([karlentwistle](https://github.com/karlentwistle))
- Fix error message on insufficient inventory. [\#2056](https://github.com/solidusio/solidus/pull/2056) ([husam212](https://github.com/husam212))
- Remove print statements from migrations [\#2048](https://github.com/solidusio/solidus/pull/2048) ([jhawthorn](https://github.com/jhawthorn))
- Make Address.find\_all\_by\_name\_or\_abbr case-insensitive [\#2043](https://github.com/solidusio/solidus/pull/2043) ([jordan-brough](https://github.com/jordan-brough))
- Remove redundant methods on Spree::PaymentMethod::StoreCredit [\#2038](https://github.com/solidusio/solidus/pull/2038) ([skukx](https://github.com/skukx))
- Fix ShippingMethod select for MySQL 5.7 strict [\#2024](https://github.com/solidusio/solidus/pull/2024) ([jhawthorn](https://github.com/jhawthorn))
- Use a subquery to avoid returning duplicate products from Product.available [\#2021](https://github.com/solidusio/solidus/pull/2021) ([jhawthorn](https://github.com/jhawthorn))
- Validate presence of product on a Variant [\#2020](https://github.com/solidusio/solidus/pull/2020) ([jhawthorn](https://github.com/jhawthorn))
- Add some missing data to seeds which was added by migrations [\#1962](https://github.com/solidusio/solidus/pull/1962) ([BravoSimone](https://github.com/BravoSimone))
- Add validity period for Spree::TaxRate [\#1953](https://github.com/solidusio/solidus/pull/1953) ([mtylty](https://github.com/mtylty))
- Remove unnecessary shipping rates callback [\#1905](https://github.com/solidusio/solidus/pull/1905) ([mamhoff](https://github.com/mamhoff))
- Remove fallback first shipping method on shipments [\#1843](https://github.com/solidusio/solidus/pull/1843) ([mamhoff](https://github.com/mamhoff))
- Add a configurable order number generator [\#1820](https://github.com/solidusio/solidus/pull/1820) ([tvdeyen](https://github.com/tvdeyen))
- Assign default user addresses in checkout controller [\#1967](https://github.com/solidusio/solidus/pull/1967) ([kennyadsl](https://github.com/kennyadsl))
- Use user.default_address as a default if bill_address or ship_address is unset [\#1424](https://github.com/solidusio/solidus/pull/1424) ([yeonhoyoon](https://github.com/yeonhoyoon), [peterberkenbosch](https://github.com/peterberkenbosch))
- Add html templates for shipped_email and inventory_cancellation emails [\#1377](https://github.com/solidusio/solidus/pull/1377) ([DanielePalombo](https://github.com/DanielePalombo))
- Don't `@extend` compound selectors in sass. Avoids deprecation warnings in sass 3.4.25 [\#2073](https://github.com/solidusio/solidus/pull/2073) ([jhawthorn](https://github.com/jhawthorn))

### Admin

- Configure admin turbolinks [\#1882](https://github.com/solidusio/solidus/pull/1882) ([mtomov](https://github.com/mtomov))
- Allow users to inline update the variant of an image in admin [\#1580](https://github.com/solidusio/solidus/pull/1580) ([mtomov](https://github.com/mtomov))
- Fix typo on fieldset tags [\#2005](https://github.com/solidusio/solidus/pull/2005) ([oeN](https://github.com/oeN))
- Use more specific selector for select2 [\#1997](https://github.com/solidusio/solidus/pull/1997) ([oeN](https://github.com/oeN))
- Replace select2 with \<select class="custom-select"\> [\#2034](https://github.com/solidusio/solidus/pull/2034) [\#2030](https://github.com/solidusio/solidus/pull/2030) ([jhawthorn](https://github.com/jhawthorn))
- Fix admin SQL issues with DISTINCT products [\#2025](https://github.com/solidusio/solidus/pull/2025) ([jhawthorn](https://github.com/jhawthorn))
- Use `@collection` instead of `@collection.present?` in some admin controllers [\#2046](https://github.com/solidusio/solidus/pull/2046) ([jordan-brough](https://github.com/jordan-brough))
- Admin::ReportsController reusable search params [\#2012](https://github.com/solidusio/solidus/pull/2012) ([oeN](https://github.com/oeN))
- Do not show broken links in admin product view when product is deleted [\#1988](https://github.com/solidusio/solidus/pull/1988) ([laurawadden](https://github.com/laurawadden))
- Allow admin to edit variant option values [\#1944](https://github.com/solidusio/solidus/pull/1944) ([dividedharmony](https://github.com/dividedharmony))
- Do not refresh shipping rates everytime the order is viewed in the admin [\#1798](https://github.com/solidusio/solidus/pull/1798) ([mamhoff](https://github.com/mamhoff))
- Add form guidelines to the style guide [\#1582](https://github.com/solidusio/solidus/pull/1582) ([Mandily](https://github.com/Mandily))
- Improve style guide flash messages UX [\#1964](https://github.com/solidusio/solidus/pull/1964) ([mtylty](https://github.com/mtylty))
- Document tooltips in the style guide [\#1955](https://github.com/solidusio/solidus/pull/1955) ([gus4no](https://github.com/gus4no))
- Fix path for distributed amount fields partial [\#2023](https://github.com/solidusio/solidus/pull/2023) ([graygilmore](https://github.com/graygilmore))
- Use `.all` instead of `.where\(nil\)` in Admin::ResourceController [\#2047](https://github.com/solidusio/solidus/pull/2047) ([jordan-brough](https://github.com/jordan-brough))
- Fix typo on the new promotions form [\#2035](https://github.com/solidusio/solidus/pull/2035) ([swcraig](https://github.com/swcraig))
- Use translated model name in admin payment methods form [\#1975](https://github/com/solidusio/solidus/pull/1975) ([tvdeyen](https://github.com/tvdeyen))


### Deprecations
- Renamed `Spree::Gateway` payment method into `Spree::PaymentMethod::CreditCard` [\#2001](https://github.com/solidusio/solidus/pull/2001) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate `#simple_current_order` [\#1915](https://github.com/solidusio/solidus/pull/1915) ([ericsaupe](https://github.com/ericsaupe))
- Deprecate `PaymentMethod.providers` in favour of `Rails.application.config.spree.payment_methods` [\#1974](https://github.com/solidusio/solidus/pull/1974) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate `Spree::Admin::PaymentMethodsController#load_providers` in favour of `load_payment_methods` [\#1974](https://github.com/solidusio/solidus/pull/1974) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate Shipment\#add\_shipping\_method [\#2018](https://github.com/solidusio/solidus/pull/2018) ([jhawthorn](https://github.com/jhawthorn))
- Re-add deprecated TaxRate\#tax\_category [\#2013](https://github.com/solidusio/solidus/pull/2013) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `Spree::Core::CurrentStore` in favor of `Spree::CurrentStoreSelector`. [\#1993](https://github.com/solidusio/solidus/pull/1993)
- Deprecate `Spree::Order#assign_default_addresses!` in favor of `Order.new.assign_default_user_addresses`. [\#1954](https://github.com/solidusio/solidus/pull/1954) ([kennyadsl](https://github.com/kennyadsl))
- Rename `PaymentMethod#method_type` into `partial_name` [\#1978](https://github.com/solidusio/solidus/pull/1978) ([tvdeyen](https://github.com/tvdeyen))
- Remove ! from assign\_default\_user\_addresses!, deprecating the old method [\#2019](https://github.com/solidusio/solidus/pull/2019) ([jhawthorn](https://github.com/jhawthorn))
- Emit Spree.url JS deprecation warning in all environments [\#2017](https://github.com/solidusio/solidus/pull/2017) ([jhawthorn](https://github.com/jhawthorn))


## Solidus 2.2.1 (2017-05-09)

- Fix migrating CreditCards to WalletPaymentSource [\#1898](https://github.com/solidusio/solidus/pull/1898) ([jhawthorn](https://github.com/jhawthorn))
- Fix setting the wallet's default payment source to the same value [\#1888](https://github.com/solidusio/solidus/pull/1888) ([ahoernecke](https://github.com/ahoernecke))
- Fix assigning nil to `default_wallet_payment_source=` [\#1896](https://github.com/solidusio/solidus/pull/1896) ([jhawthorn](https://github.com/jhawthorn))

## Solidus 2.2.0 (2017-05-01)

### Major Changes

- Spree::Wallet and Non credit card payment sources [\#1707](https://github.com/solidusio/solidus/pull/1707) [\#1773](https://github.com/solidusio/solidus/pull/1773) [\#1765](https://github.com/solidusio/solidus/pull/1765) ([chrisradford](https://github.com/chrisradford), [jordan-brough](https://github.com/jordan-brough), [peterberkenbosch](https://github.com/peterberkenbosch))

  This adds support for payment sources other than `CreditCard`, which can be used to better represent other (potentially reusable) payment sources, like PayPal or Bank accounts. Previously sources like this had to implement all behaviour themselves, or try their best to quack like a credit card.

  This adds a `PaymentSource` base class, which `CreditCard` now inherits, and a `Wallet` service class to help manage users' payment sources. A `WalletPaymentSource` join table is used to tie reusable payment sources to users, replacing the existing behaviour of allowing all credit cards with a stored payment profile.

- Add promotion code batch [\#1524](https://github.com/solidusio/solidus/pull/1524) ([vladstoick](https://github.com/vladstoick))

  Prior to Solidus 1.0, each promotion had at most one code. Though we added the functionality to have many codes on one promotion, the UI for creation and management was lacking.

  In Solidus 2.2 we've added `PromotionCodeBatch`, a model to group a batch of promotion codes. This allows additional promotion codes to be generated after the Promotion's initial creation. Promotion codes are also now generated in a background job.

- Admin UI Changes

  The admin UI was once again a focus in this release. We've made many incremental changes we think all users will appreciate. This includes an upgrade to Bootstrap 4.0.0.alpha6, changes to table styles, and a better select style.

  See the "Admin UI" section below for a full list of changes.


### Core
- `Spree::Order#available_payment_methods` returns an `ActiveRecord::Relation` instead of an array [\#1802](https://github.com/solidusio/solidus/pull/1802) ([luukveenis](https://github.com/luukveenis))
- Product slugs no longer have a minimum length requirement [#1616](https://github.com/solidusio/solidus/pull/1616) ([fschwahn](https://github.com/fschwahn))
- `Spree::Money` now includes `Comparable` and the `<=>` operator for comparisons. [#1682](https://github.com/solidusio/solidus/pull/1682) ([graygilmore ](https://github.com/graygilmore))
- Allow destruction of shipments in the "ready" state. [#1784](https://github.com/solidusio/solidus/pull/1784) ([mamhoff](https://github.com/mamhoff))
- Do not consider pending inventory units cancelable [\#1800](https://github.com/solidusio/solidus/pull/1800) ([mamhoff](https://github.com/mamhoff))
- Rewrite spree.js in plain JS [\#1754](https://github.com/solidusio/solidus/pull/1754) ([jhawthorn](https://github.com/jhawthorn))
- Make sensitive params filtering less eager [\#1755](https://github.com/solidusio/solidus/pull/1755) ([kennyadsl](https://github.com/kennyadsl))
- Use manifest.js to support Sprockets 4 [\#1759](https://github.com/solidusio/solidus/pull/1759) ([jhawthorn](https://github.com/jhawthorn))
- Update paperclip dependency [\#1749](https://github.com/solidusio/solidus/pull/1749) ([brchristian](https://github.com/brchristian))
- Update kaminari dependency to 1.x [\#1734](https://github.com/solidusio/solidus/pull/1734) ([jrochkind](https://github.com/jrochkind))
- Allow twitter\_cldr 4.x [\#1732](https://github.com/solidusio/solidus/pull/1732) ([jrochkind](https://github.com/jrochkind))
- Added LineItem name to unavailable flash [\#1697](https://github.com/solidusio/solidus/pull/1697) ([ericsaupe](https://github.com/ericsaupe))
- Don't treat "unreturned exchanges" specially in checkout state machine flow [\#1690](https://github.com/solidusio/solidus/pull/1690) ([jhawthorn](https://github.com/jhawthorn))
- `set_shipments_cost` is now part of OrderUpdater [\#1689](https://github.com/solidusio/solidus/pull/1689) ([jhawthorn](https://github.com/jhawthorn))
- Methods other than `update!`, `update_shipment_state`, `update_payment_state` are now private on OrderUpdater [\#1689](https://github.com/solidusio/solidus/pull/1689) ([jhawthorn](https://github.com/jhawthorn))

### Bug Fixes

- `AvailabilityValidator` correctly detects out of stock with multiple shipments from the same stock location. [\#1693](https://github.com/solidusio/solidus/pull/1693) ([jhawthorn](https://github.com/jhawthorn))
- Fix missing close paren in variantAutocomplete [\#1832](https://github.com/solidusio/solidus/pull/1832) ([jhawthorn](https://github.com/jhawthorn))
- Set belongs\_to\_required\_by\_default = false [\#1807](https://github.com/solidusio/solidus/pull/1807) ([jhawthorn](https://github.com/jhawthorn))
- Fix loading transfer shipments [\#1781](https://github.com/solidusio/solidus/pull/1781) ([mamhoff](https://github.com/mamhoff))
- Fix complete order factory to have non-pending inventory units [\#1787](https://github.com/solidusio/solidus/pull/1787) ([mamhoff](https://github.com/mamhoff))
- Fix to cart URL for stores not mounted at root [\#1775](https://github.com/solidusio/solidus/pull/1775) ([funwhilelost](https://github.com/funwhilelost))
- Remove duplicated require in shipment factory [\#1769](https://github.com/solidusio/solidus/pull/1769) ([upinetree](https://github.com/upinetree))
- Fix an issue where updating a user in the admin without specifying roles in would clear the existing roles.[\#1747](https://github.com/solidusio/solidus/pull/1747) ([tvdeyen](https://github.com/tvdeyen))
- Fix the 'Send Mailer' checkbox selection [\#1716](https://github.com/solidusio/solidus/pull/1716) ([jhawthorn](https://github.com/jhawthorn))
- Rearrange AR relation declarations in order.rb in preparation for Rails 5.1 [\#1740](https://github.com/solidusio/solidus/pull/1740) ([jhawthorn](https://github.com/jhawthorn))
- Fix issue where OrderInventory creates superfluous InventoryUnits [\#1751](https://github.com/solidusio/solidus/pull/1751) ([jhawthorn](https://github.com/jhawthorn))
- Fix check for `order.guest\_token` presence [\#1705](https://github.com/solidusio/solidus/pull/1705) ([vfonic](https://github.com/vfonic))
- Fix shipped\_order factory [\#1772](https://github.com/solidusio/solidus/pull/1772) ([tvdeyen](https://github.com/tvdeyen))
- Don't display inactive payment methods on frontend or backend [\#1801](https://github.com/solidusio/solidus/pull/1801) ([luukveenis](https://github.com/luukveenis))
- Don't send email if PromotionCodeBatch email is unset [\#1699](https://github.com/solidusio/solidus/pull/1699) ([jhawthorn](https://github.com/jhawthorn))

### Frontend
- Use `cart_link_path` instead of `cart_link_url` [\#1757](https://github.com/solidusio/solidus/pull/1757) ([bofrede](https://github.com/bofrede))
- Replace cache\_key\_for\_taxons with cache [\#1688](https://github.com/solidusio/solidus/pull/1688) ([jhawthorn](https://github.com/jhawthorn))
- Update code styles for /cart [\#1727](https://github.com/solidusio/solidus/pull/1727) ([vfonic](https://github.com/vfonic))
- Add a frontend views override generator [\#1681](https://github.com/solidusio/solidus/pull/1681) ([tvdeyen](https://github.com/tvdeyen))

### Admin

- Create JS namespaces in centralized file [\#1753](https://github.com/solidusio/solidus/pull/1753) ([jhawthorn](https://github.com/jhawthorn))
- Replace select2-rails with vendored select2 [\#1774](https://github.com/solidusio/solidus/pull/1774) ([jhawthorn](https://github.com/jhawthorn))
- Add JS `Spree.formatMoney` helper for currency formatting [\#1745](https://github.com/solidusio/solidus/pull/1745) ([jhawthorn](https://github.com/jhawthorn))
- Rewrite zones.js.coffee using Backbone.js [\#1766](https://github.com/solidusio/solidus/pull/1766) ([jhawthorn](https://github.com/jhawthorn))
- Add JS `Spree.t` and `Spree.human_attribute_name` for i18n [\#1730](https://github.com/solidusio/solidus/pull/1730) ([jhawthorn](https://github.com/jhawthorn))
- Allow editing multiple Stores [\#1282](https://github.com/solidusio/solidus/pull/1282) ([jhawthorn](https://github.com/jhawthorn))
- Add promotion codes index view [\#1545](https://github.com/solidusio/solidus/pull/1545) ([jhawthorn](https://github.com/jhawthorn))
- Replace deprecated bourbon mixins with unprefixed CSS [\#1706](https://github.com/solidusio/solidus/pull/1706) ([jhawthorn](https://github.com/jhawthorn))
- Ensure helper is specified in CustomerReturnsController [\#1771](https://github.com/solidusio/solidus/pull/1771) ([eric1234](https://github.com/eric1234))
- Ensure helper is specified in VariantsController [\#1714](https://github.com/solidusio/solidus/pull/1714) ([eric1234](https://github.com/eric1234))
- Remove nonexistant form hint from view [\#1698](https://github.com/solidusio/solidus/pull/1698) ([jhawthorn](https://github.com/jhawthorn))
- Promotion search now finds orders which used the specific promotion code, of any code on the promotion. [#1662](https://github.com/solidusio/solidus/pull/1662) ([stewart](https://github.com/stewart))

### Admin UI

- Upgrade to Bootstrap 4.0.0.alpha6 [\#1816](https://github.com/solidusio/solidus/pull/1816) ([jhawthorn](https://github.com/jhawthorn))
- New admin table layout [\#1786](https://github.com/solidusio/solidus/pull/1786) [\#1828](https://github.com/solidusio/solidus/pull/1828) [\#1829](https://github.com/solidusio/solidus/pull/1829) ([tvdeyen](https://github.com/tvdeyen))
- Add number with currency selector widget [\#1793](https://github.com/solidusio/solidus/pull/1793) [\#1813](https://github.com/solidusio/solidus/pull/1813) ([jhawthorn](https://github.com/jhawthorn))
- Replace select2 styling [\#1797](https://github.com/solidusio/solidus/pull/1797) ([jhawthorn](https://github.com/jhawthorn))
- Change admin logo height to match breadcrumbs height [\#1822](https://github.com/solidusio/solidus/pull/1822) ([mtomov](https://github.com/mtomov))
- Fit admin logo to available space [\#1758](https://github.com/solidusio/solidus/pull/1758) ([brchristian](https://github.com/brchristian))
- Make form/button styles match bootstrap's [\#1809](https://github.com/solidusio/solidus/pull/1809) ([jhawthorn](https://github.com/jhawthorn))
- Fix datepicker style [\#1827](https://github.com/solidusio/solidus/pull/1827) ([kennyadsl](https://github.com/kennyadsl))
- Use bootstrap input-group for date range [\#1817](https://github.com/solidusio/solidus/pull/1817) ([jhawthorn](https://github.com/jhawthorn))
- Improve page titles in admin [\#1795](https://github.com/solidusio/solidus/pull/1795) ([jhawthorn](https://github.com/jhawthorn))
- Use an icon as missing image placeholder [\#1760](https://github.com/solidusio/solidus/pull/1760) ([jhawthorn](https://github.com/jhawthorn)) [\#1764](https://github.com/solidusio/solidus/pull/1764) ([jhawthorn](https://github.com/jhawthorn))
- Convert admin orders table into full width layout [\#1782](https://github.com/solidusio/solidus/pull/1782) ([tvdeyen](https://github.com/tvdeyen))
- Raise `font-size` [\#1777](https://github.com/solidusio/solidus/pull/1777) ([tvdeyen](https://github.com/tvdeyen))
- Improve promotions creation form [\#1509](https://github.com/solidusio/solidus/pull/1509) ([jhawthorn](https://github.com/jhawthorn))
- Remove stock location configuration from admin "cart" page [\#1709](https://github.com/solidusio/solidus/pull/1709) [\#1710](https://github.com/solidusio/solidus/pull/1710) ([jhawthorn](https://github.com/jhawthorn))
- Update admin cart page dynamically [\#1715](https://github.com/solidusio/solidus/pull/1715) ([jhawthorn](https://github.com/jhawthorn))
- Fix duplicated Shipments breadcrumb [\#1717](https://github.com/solidusio/solidus/pull/1717) [\#1746](https://github.com/solidusio/solidus/pull/1746) ([jhawthorn](https://github.com/jhawthorn))
- Don’t set default text highlight colors [\#1738](https://github.com/solidusio/solidus/pull/1738) ([brchristian](https://github.com/brchristian))
- Convert customer details page to backbone [\#1762](https://github.com/solidusio/solidus/pull/1762) ([jhawthorn](https://github.com/jhawthorn))
- Remove inline edit from payments dipslay amount [\#1815](https://github.com/solidusio/solidus/pull/1815) ([tvdeyen](https://github.com/tvdeyen))
- Fix styling of tiered promotions delete icon [\#1810](https://github.com/solidusio/solidus/pull/1810) ([jhawthorn](https://github.com/jhawthorn))
- Remove `webkit-tap-highlight-color` [\#1792](https://github.com/solidusio/solidus/pull/1792) ([brchristian](https://github.com/brchristian))
- Promotion and Shipping calculators can be created or changed without reloading the page. [#1618](https://github.com/solidusio/solidus/pull/1618) ([jhawthorn](https://github.com/jhawthorn))


### Removals

- Extract expedited exchanges to an extension [\#1691](https://github.com/solidusio/solidus/pull/1691) ([jhawthorn](https://github.com/jhawthorn))
- Remove spree\_store\_credits column [\#1741](https://github.com/solidusio/solidus/pull/1741) ([jhawthorn](https://github.com/jhawthorn))
- Remove StockMovements\#new action and view [\#1767](https://github.com/solidusio/solidus/pull/1767) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused variant\_management.js.coffee [\#1768](https://github.com/solidusio/solidus/pull/1768) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused payment Javascript [\#1735](https://github.com/solidusio/solidus/pull/1735) ([jhawthorn](https://github.com/jhawthorn))
- Moved `spree/admin/shared/_translations` partial to `spree/admin/shared/_js_locale_data`.


### Deprecations

- Deprecate `Order#has_step?` in favour of `has_checkout_step?` [#1667](https://github.com/solidusio/solidus/pull/1667) ([mamhoff](https://github.com/mamhoff))
- Deprecate `Order#set_shipments_cost`, which is now done in `Order#update!` [\#1689](https://github.com/solidusio/solidus/pull/1689) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `user.default_credit_card`, `user.payment_sources` for `user.wallet.default_wallet_payment_source` and `user.wallet.wallet_payment_sources`
- Deprecate `CreditCard#default` in favour of `user.wallet.default_wallet_payment_source`
- Deprecate `cache_key_for_taxons` helper favour of `cache [I18n.locale, @taxons]`
- Deprecate admin sass variables in favour of bootstrap alternatives [\#1780](https://github.com/solidusio/solidus/pull/1780) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate Address\#empty? [\#1686](https://github.com/solidusio/solidus/pull/1686) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `fill_in_quantity` capybara helper [#1710](https://github.com/solidusio/solidus/pull/1710) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `wait_for_ajax` capybara helper [#1668](https://github.com/solidusio/solidus/pull/1668) ([cbrunsdon](https://github.com/cbrunsdon))


## Solidus 2.1.0 (2017-01-17)

*   The OrderUpdater (as used by `order.update!`) now fully updates taxes.

    Previously there were two different ways taxes were calculated: a "full"
    and a "quick" calculation. The full calculation was performed with
    `order.create_tax_charge!` and would determine which tax rates applied and
    add taxes to items. The "quick" calculation was performed as part of an
    order update, and would only update the tax amounts on existing line items
    with taxes.

    Now `order.update!` will perform the full calculation every time.
    `order.create_tax_charge!` is now deprecated and has been made equivalent
    to `order.update!`.

    [#1479](https://github.com/solidusio/solidus/pull/1479)

*   `ItemAdjustments` has been merged into the `OrderUpdater`

    The previous behaviour between these two classes was to iterate over each
    item calculating promotions, taxes, and totals for each before moving on to
    the next item. To better support external tax services, we now calculate
    promotions for all items, followed by taxes for all items, etc.

    [#1466](https://github.com/solidusio/solidus/pull/1466)

*   Make frontend prices depend on `store.cart_tax_country_iso`

    Prices in the frontend now depend on `store.cart_tax_country_iso` instead of `Spree::Config.admin_vat_country_iso`.

    [#1605](https://github.com/solidusio/solidus/pull/1605)

*   Deprecate methods related to Spree::Order#tax_zone

    We're not using `Spree::Order#tax_zone`, `Spree::Zone.default_tax`,
    `Spree::Zone.match`, or `Spree::Zone#contains?` in our code base anymore.
    They will be removed soon. Please use `Spree::Order#tax_address`,
    `Spree::Zone.for_address`, and `Spree::Zone.include?`, respectively,
    instead.

    [#1543](https://github.com/solidusio/solidus/pull/1543)

*   Product Prototypes have been removed from Solidus itself.

    The new `solidus_prototype` extension provides the existing functionality. [#1517](https://github.com/solidusio/solidus/pull/1517)

*   Analytics trackers have been removed from Solidus itself.

    The new `solidus_trackers` extension provides the existing functionality. [#1438](https://github.com/solidusio/solidus/pull/1438)

*   Bootstrap row and column classes have replaced the legacy skeleton classes throughout the admin. [#1484](https://github.com/solidusio/solidus/pull/1484)

*   Remove `currency` from line items.

    It's no longer allowed to have line items with different currencies on the
    same order. This makes storing the currency on line items redundant, since
    it will always be considered the same as the order currency.

    It will raise an exception if a line item with the wrong currency is added.

    This change also deletes the `currency` database field (String)
    from the `line_items` table, since it will not be used anymore.

    [#1507](https://github.com/solidusio/solidus/pull/1507)

*   Add `Spree::Promotion#remove_from` and `Spree::PromotionAction#remove_from`

    This will allow promotions to be removed from orders and allows promotion
    actions to define how to reverse their side effects on an order.

    For now `PromotionAction` provides a default remove_from method, with a
    deprecation warning that subclasses should define their own remove_from
    method.

    [#1451](https://github.com/solidusio/solidus/pull/1451)

*   Remove `is_default` boolean from `Spree::Price` model

    This boolean used to mean "the price to be used". With the new
    pricing architecture introduced in 1.3, it is now redundant and can be
    reduced to an order clause in the currently valid prices scope.

    [#1469](https://github.com/solidusio/solidus/pull/1469)

*   Remove callback `Spree::LineItem.after_create :update_tax_charge`

    Any code that creates `LineItem`s outside the context of OrderContents
    should ensure that it calls `order.update!` after doing so.

    [#1463](https://github.com/solidusio/solidus/pull/1463)

*   Mark `Spree::Tax::ItemAdjuster` as api-private [#1463](https://github.com/solidusio/solidus/pull/1463)

*   Updated Credit Card brand server-side detection regex to support more
    brands and MasterCard's new BIN range. [#1477](https://github.com/solidusio/solidus/pull/1477)

    Note: Most stores will be using client-side detection which was updated in
    Solidus 1.2

*   `CreditCard`'s `verification_value` field is now converted to a string and
    has whitespace removed on assignment instead of before validations.

*   The `lastname` field on `Address` is now optional. [#1369](https://github.com/solidusio/solidus/pull/1369)

*   The admin prices listings page now shows master and variant prices
    seperately. This changes `@prices` to `@master_prices` and `@variant_prices` in prices_controller

    [#1510](https://github.com/solidusio/solidus/pull/1510)

*   Admin javascript assets are now individually `require`d using sprockets
    directives instead of using `require_tree`. This should fix issues where
    JS assets could not be overridden in applications. [#1613](https://github.com/solidusio/solidus/pull/1613)

*   The admin has an improved image upload interface with drag and drop. [#1553](https://github.com/solidusio/solidus/pull/1553)

*   PaymentMethod's `display_on` column has been replaced with `available_to_users` and `available_to_admin`.
    The existing attributes and scopes have been deprecated.

    [#1540](https://github.com/solidusio/solidus/pull/1540)

*   ShippingMethod's `display_on` column has been replaced with `available_to_users`.
    The existing attributes and scopes have been deprecated.

    [#1611](https://github.com/solidusio/solidus/pull/1611)

*   Added experimental Spree::Config.tax_adjuster_class

    To allow easier customization of tax calculation in extensions or
    applications.

    This API is *experimental* and is likely to change in a future version.

    [#1479](https://github.com/solidusio/solidus/pull/1479)

*   Removals

    * Removed deprecated `STYLE_image` helpers from BaseHelper [#1623](https://github.com/solidusio/solidus/pull/1623)

    * Removed deprecated method `Spree::TaxRate.adjust` (not to be confused with
      Spree::TaxRate#adjust) in favor of `Spree::Config.tax_adjuster_class`.

      [#1462](https://github.com/solidusio/solidus/pull/1462)

    * Removed deprecated method `Promotion#expired?` in favor of
      `Promotion#inactive?`

      [#1461](https://github.com/solidusio/solidus/pull/1461)

    * Removed nested attribute helpers `generate_template`, `generate_html`,
      and `remove_nested`. Also removes some javascript bound to selectors
      `.remove`, `a[id*=nested]`.

    * Removed `accept_alert` and `dismiss_alert` from CapybaraExt.
      `accept_alert` is now a capybara builtin (that we were overriding) and
      `dismiss_alert` can be replaced with `dismiss_prompt`.

    * Removed deprecated delegate_belongs_to

## Solidus 2.0.0 (2016-09-26)

*   Upgrade to rails 5.0

## Solidus 1.4.0 (2016-09-26)

*   Use in-memory objects in OrderUpdater and related areas.

    Solidus now uses in-memory data for updating orders in and around
    OrderUpdater.  E.g. if an order already has `order.line_items` loaded into
    memory when OrderUpdater is run then it will use that information rather
    than requerying the database for it. This should help performance and makes
    some upcoming refactoring easier.

    Warning:  If you bypass ActiveRecord while making updates to your orders you
    run the risk of generating invalid data.  Example:

        order.line_items.to_a
        order.line_items.update_all(price: ...)
        order.update!

    Will now result in incorrect calculations in OrderUpdater because the line
    items will not be refetched.

    In particular, when creating adjustments, you should always create the
    adjustment using the adjustable relationship.

    Good example:

        line_item.adjustments.create!(source: tax_rate, ...)

    Bad examples:

        tax_rate.adjustments.create!(adjustable: line_item, ...)
        Spree::Adjustment.create!(adjustable: line_item, source: tax_rate, ...)

    We try to detect the latter examples and repair the in-memory objects (with
    a deprecation warning) but you should ensure that your code is keeping the
    adjustable's in-memory associations up to date. Custom promotion actions are
    an area likely to have this issue.

    https://github.com/solidusio/solidus/pull/1356
    https://github.com/solidusio/solidus/pull/1389
    https://github.com/solidusio/solidus/pull/1400
    https://github.com/solidusio/solidus/pull/1401

*   Make some 'wallet' behavior configurable

    NOTE: `Order#persist_user_credit_card` has been renamed to
    `Order#add_payment_sources_to_wallet`. If you are overriding
    `persist_user_credit_card` you need to update your code.

    The following extension points have been added for customizing 'wallet'
    behavior.

    * Spree::Config.add_payment_sources_to_wallet_class
    * Spree::Config.default_payment_builder_class

    https://github.com/solidusio/solidus/pull/1086

*   Backend: UI, Remove icons from buttons and tabs

*   Backend: Deprecate args/options that add icons to buttons

*   Update Rules::Taxon/Product handling of invalid match policies

    Rules::Taxon and Rules::Product now require valid match_policy values.
    Please ensure that all your Taxon and Product Rules have valid match_policy
    values.

*   Fix default value for Spree::Promotion::Rules::Taxon preferred_match_policy.

    Previously this was defaulting to nil, which was sometimes interpreted as
    'none'.

*   Deprecate `Spree::Shipment#address` (column renamed)

    `Spree::Shipment#address` was not actually being used for anything in
    particular, so the association has been deprecated and delegated to
    `Spree::Order#ship_address` instead. The database column has been renamed
    `spree_shipments.deprecated_address_id`.

    https://github.com/solidusio/solidus/pull/1138

*   Coupon code application has been separated from the Continue button on the Payment checkout page

    * JavaScript for it has been moved from address.js into its own `spree/frontend/checkout/coupon-code`
    * Numerous small nuisances have been fixed [#1090](https://github.com/solidusio/solidus/pull/1090)

*   Allow filtering orders by store when multiple stores are present. [#1149](https://github.com/solidusio/solidus/pull/1140)

*   Remove unused `user_id` column from PromotionRule. [#1259](https://github.com/solidusio/solidus/pull/1259)

*   Removed "Clear cache" button from the admin [#1275](https://github.com/solidusio/solidus/pull/1275)

*   Adjustments and totals are no longer updated when saving a Shipment or LineItem.

    Previously adjustments and total columns were updated after saving a Shipment or LineItem.
    This was unnecessary since it didn't update the order totals, and running
    order.update! would recalculate the adjustments and totals again.

## Solidus 1.3.0 (2016-06-22)

*   Order now requires a `store_id` in validations

    All orders created since Spree v2.4 should have a store assigned. A
    migration exists to assign all orders without a store to the default store.

    If you are seeing spec failures related to this, you may have to add
    `let!(:store) { create(:store) }` to some test cases.

*   Deprecate `Spree::TaxRate.adjust`, remove `Spree::TaxRate.match`

    The functionality of `Spree::TaxRate.adjust` is now contained in the new
    `Spree::Tax::OrderAdjuster` class.

    Wherever you called `Spree::TaxRate.adjust(items, order_tax_zone)`, instead call
    `Spree::Tax::OrderAdjuster.new(order).adjust!`.

    `Spree::TaxRate.match` was an implementation detail of `Spree::TaxRate.adjust`. It has been
    removed, and its functionality is now contained in the private method
    `Spree::Tax::TaxHelpers#applicable_rates(order)`.

*   Allow more options than `current_currency` to select prices

    Previously, availability of products/variants, caching and pricing was dependent
    only on a `current_currency` string. This has been changed to a `current_pricing_options`
    object. For now, this object (`Spree::Variant::PricingOptions`) only holds the
    currency. It is used for caching instead of the deprecated `current_currency` helper.

    Additionally, your pricing can be customized using a `VariantPriceSelector` object, a default
    implementation of which can be found in `Spree::Variant::PriceSelector`. It is responsible for
    finding the right price for variant, be it for front-end display or for adding it to the
    cart. You can set it through the new `Spree::Config.variant_price_selector_class` setting. This
    class also knows which `PricingOptions` class it cooperates with.

    #### Deprecated methods:

    * `current_currency` helper
    * `Spree::Variant#categorise_variants_from_option`
    * `Spree::Variant#variants_and_option_values` (Use `Spree::Variant#variants_and_option_values#for` instead)
    * `Spree::Core::Search::Base#current_currency`
    * `Spree::Core::Search::Base#current_currency=`

    #### Extracted Functionality:

    There was a strange way of setting prices for line items depending on additional attributes
    being present on the line item (`gift_wrap: true`, for example). It also needed
    `Spree::Variant` to be patched with methods like `Spree::Variant#gift_wrap_price_modifier_in`
    and is generally deemed a non-preferred way of modifying pricing.
    This functionality has now been moved into a [Gem of its own](https://github.com/solidusio-contrib/solidus_price_modifier)
    to ease the transition to the new `Variant::PriceSelector` system.

*   Respect `Spree::Store#default_currency`

    Previously, the `current_currency` helper in both the `core` and `api` gems
    would always return the globally configured default currency rather than the
    current store's one. With Solidus 1.3, we respect that setting without having
    to install the `spree_multi_domain` extension.

*   Persist tax estimations on shipping rates

    Previously, shipping rate taxes were calculated on the fly every time
    a shipping rate would be displayed. Now, shipping rate taxes are stored
    on a dedicated table to look up.

    There is a new model Spree::ShippingRateTax where the taxes are stored,
    and a new Spree::Tax::ShippingRateTaxer that builds those taxes from within
    Spree::Stock::Estimator.

    The shipping rate taxer class can be exchanged for a custom estimator class
    using the new Spree::Appconfiguration.shipping_rate_taxer_class preference.

    https://github.com/solidusio/solidus/pull/904

    In order to convert your historical shipping rate taxation data, please run
    `rake solidus:upgrade:one_point_three` - this will create persisted taxation notes
    for historical shipping rates. Be aware though that these taxation notes are
    estimations and should not be used for accounting purposes.

    https://github.com/solidusio/solidus/pull/1068

*   Deprecate setting a line item's currency by hand

    Previously, a line item's currency could be set directly, and differently from the line item's
    order's currency. This would result in an error. It still does, but is also now explicitly
    deprecated. In the future, we might delete the line item's `currency` column and just delegate
    to the line item's order.

*   Taxes for carts now configurable via the `Spree::Store` object

    In VAT countries, carts (orders without addresses) have to be shown with
    adjustments for the country whose taxes the cart's prices supposedly include.
    This might differ from `Spree::Store` to `Spree::Store`. We're introducting
    the `cart_tax_country_iso` setting on Spree::Store for this purpose.

    Previously the setting for what country any prices include
    Spree::Zone.default_tax. That, however, would *also* implicitly tag all
    prices in Spree as including the taxes from that zone. Introducing the cart
    tax setting on Spree::Store relieves that boolean of some of its
    responsibilities.

    https://github.com/solidusio/solidus/pull/933

*   Make Spree::Product#prices association return all prices

    Previously, only non-master variant prices would have been returned here.
    Now, we get all the prices, including those from the master variant.

    https://github.com/solidusio/solidus/pull/969

*   Changes to Spree::Stock::Estimator

    * The package passed to Spree::Stock::Estimator#shipping_rates must have its
      shipment assigned and that shipment must have its order assigned. This
      is needed for some upcoming tax work in to calculate taxes correctly.
    * Spree::Stock::Estimator.new no longer accepts an order argument. The order
      will be fetched from the shipment.

    https://github.com/solidusio/solidus/pull/965

*   Removed Spree::Stock::Coordinator#packages from the public interface.

    This will allow us to refactor more easily.
    https://github.com/solidusio/solidus/pull/950

*   Removed `pre_tax_amount` column from line item and shipment tables

    This column was previously used as a caching column in the process of
    calculating VATs. Its value should have been (but wasn't) always the same as
    `discounted_amount - included_tax_total`. It's been replaced with a method
    that does just that. [#941](https://github.com/solidusio/solidus/pull/941)

*   Renamed return item `pre_tax_amount` column to `amount`

    The naming and functioning of this column was inconsistent with how
    shipments and line items work: In those models, the base from which we
    calculate everything is the `amount`. The ReturnItem now works just like
    a line item.

    Usability-wise, this change entails that for VAT countries, when creating
    a refund for an order including VAT, you now have to enter the amount
    you want to refund including VAT. This is what a backend user working
    with prices including tax would expect.

    For a non-VAT store, nothing changes except for the form field name, which
    now says `Amount` instead of `Pre-tax-amount`. You might want to adjust the
    i18n translation here, depending on your circumstances.
    [#706](https://github.com/solidusio/solidus/pull/706)

*   Removed Spree::BaseHelper#gem_available? and Spree::BaseHelper#current_spree_page?

    Both these methods were untested and not appropriate code to be in core. If you need these
    methods please pull them into your app. [#710](https://github.com/solidusio/solidus/pull/710).

*   Fixed a bug where toggling 'show only complete order' on/off was not showing
    all orders. [#749](https://github.com/solidusio/solidus/pull/749)

*   ffaker has been updated to version 2.x

    This version changes the namespace from Faker:: to FFaker::

*   versioncake has been updated to version 3.x

    This version uses a rack middleware to determine the version, uses a
    different header name, and has some configuration changes.

    You probably need to add [this](https://github.com/solidusio/solidus/commit/076f56f#diff-fd13b465e9d1fded7e03629bde800c9eR64)
    to your controller specs.

    More information is available in the [VersionCake README](https://github.com/bwillis/versioncake)

*   Bootstrap 4.0.0-alpha.2 is included into the admin.

*   Pagination now uses an admin-specific kaminari theme, which uses the
    bootstrap4 styles. If you have a custom admin page with pagination you can
    use this style with the following.

        <%= paginate @collection, theme: "solidus_admin" %>

*   Settings configuration menu has been replaced with groups of tabs at the top

    * Settings pages were grouped into related partials as outlined in [#634](https://github.com/solidusio/solidus/issues/634)
    * Partials are rendered on pages owned by the partials as tabs as a top bar
    * Admin-nav has a sub-menu for the settings now

*   Lists of classes in configuration (`config.spree.calculators`, `spree.spree.calculators`, etc.) are
    now stored internally as strings and constantized when accessed. This allows these classes to be
    reloaded in development mode and loaded later in the boot process.
    [#1203](https://github.com/solidusio/solidus/pull/1203)

## Solidus 1.2.0 (2016-01-26)

*   Admin menu has been moved from top of the page to the left side.

    * Submenu items are accessible from any page. See [the wiki](https://github.com/solidusio/solidus/wiki/Upgrading-Admin-Navigation-to-1.2)
       for more information and instructions on upgrading.
    * [Solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise)
      should be updated to '~> 1.3' to support the new menu.
    * Added optional styles to the admin area to advance [admin rebrand](https://github.com/solidusio/solidus/issues/520).
      To use the new colors, add `@import 'spree/backend/themes/blue_steel/globals/_variables_override';`
      to your `spree/backend/globals/variables_override`.

*   Removed deface requirement from core

    Projects and extensions which rely on deface will need to add it explicitly
    to their dependencies.

*   `testing_support/capybara_ext.rb` no longer changes capybara's matching
    mode to `:prefer_exact`, and instead uses capybara's default, `:smart`.

    You can restore the old behaviour (not recommended) by adding
    `Capybara.match = :prefer_exact` to your `spec_helper.rb`.

    More information can be found in [capybara's README](https://github.com/jnicklas/capybara#matching)

*   Fixed a bug where sorting in the admin would not save positions correctly.
    [#632](https://github.com/solidusio/solidus/pull/632)

*   Included (VAT-style) taxes, will be considered applicable if they are
    inside the default tax zone, rather than just when they are the defaut tax
    zone. [#657](https://github.com/solidusio/solidus/pull/657)

*   Update jQuery.payment to v1.3.2 (from 1.0) [#608](https://github.com/solidusio/solidus/pull/608)

*   Removed Order::CurrencyUpdater. [#635](https://github.com/solidusio/solidus/pull/635)

*   Removed `Product#set_master_variant_defaults`, which was unnecessary since master is build with `is_master` already `true`.

*   Improved performance of stock packaging [#550](https://github.com/solidusio/solidus/pull/550) [#565](https://github.com/solidusio/solidus/pull/565) [#574](https://github.com/solidusio/solidus/pull/574)

*   Replaced admin taxon management interface [#569](https://github.com/solidusio/solidus/pull/569)

*   Fix logic around raising InsufficientStock when creating shipments. [#566](https://github.com/solidusio/solidus/pull/566)

    Previously, `InsufficientStock` was raised if any StockLocations were fully
    out of inventory. This was incorrect because it was possible other stock
    locations could have fulfilled the inventory. This was also incorrect because
    the stock location could have some, but insufficient inventory, and not raise
    the exception (an incomplete package would be returned). Now the coordinator
    checks that the package is complete and raises `InsufficientStock` if it is
    incomplete for any reason.

*   Removed `Spree::Zone.global` [#627](https://github.com/solidusio/solidus/pull/627)
    Use the "GlobalZone" factory instead: `FactoryGirl.create(:global_zone)`

## Solidus 1.1.0 (2015-11-25)

*   Address is immutable (Address#readonly? is always true)

    This allows us to minimize cloning addresses, while still ensuring historical
    data is preserved.

*   UserAddressBook module added to manage a user's multiple addresses

*   GET /admin/search/users searches all of a user's addresses, not
    just current bill and ship addresss

*   Adjustment state column has been replaced with a finalized boolean column.
    This includes a migration replacing the column, which may cause some
    downtime for large stores.

*   Handlebars templates in the admin are now stored in assets and precompiled
    with the rest of the admin js.

*   Removed `map_nested_attributes_keys` from the Api::BaseController. This
    method was only used in one place and was oblivious of strong_params.

*   Change all mails deliveries to `#deliver_later`. Emails will now be sent in
    the background if you configure active\_job to do so. See [the rails guides](http://guides.rubyonrails.org/active_job_basics.html#job-execution)
    for more information.

*   Cartons deliveries now send one email per-order, instead of one per-carton.
    This allows setting `@order` and `@store` correctly for the template. For
    most stores, which don't combine multiple orders into a carton, this will
    behave the same.

*   Some HABTM associations have been converted to HMT associations.
    Referential integrity has also been added as well.
    Specifically:

    * Prototype <=> Taxon
    * ShippingMethod <=> Zone
    * Product <=> PromotionRule

## Solidus 1.0.1 (2015-08-19)

See https://github.com/solidusio/solidus/releases/tag/v1.0.1

## Solidus 1.0.0 (2015-08-11)

See https://github.com/solidusio/solidus/releases/tag/v1.0.0
