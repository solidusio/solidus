## Solidus 1.4.0 (master, unreleased)

*   Coupon code application has been separated from the Continue button on the Payment checkout page

    * JavaScript for it has been moved from address.js into its own `spree/frontend/checkout/coupon-code`
    * Numerous small nuisances have been fixed [#1090](https://github.com/solidusio/solidus/pull/1090)


## Solidus 1.3.0 (unreleased)

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
