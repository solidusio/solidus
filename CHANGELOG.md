## Solidus 2.2.0 (master, unreleased)

*   Promotion and Shipping calculators can be created or have their type
    changed without saving and reloading the page.
    [#1618](https://github.com/solidusio/solidus/pull/1618)

*   Product slugs no longer have a minimum length validation to match the
    Product name validation.
    [#1616](https://github.com/solidusio/solidus/pull/1616)

*   Changed the promotion field in the admin order search to only find orders
    which used the specified promotion code, instead of any code on an applied
    promotion. [#1662](https://github.com/solidusio/solidus/pull/1662)

*   `Spree::Money` now includes `Comparable` and the `<=>` operator for
    comparisons. A comparison will fail if the two objects do not use the same
    currency. [#1682](https://github.com/solidusio/solidus/pull/1682)

*   The "Stores" section of Settings in the admin now supports creating and
    editing multiple stores.

*   Deprecations

    * `cache_key_for_taxons` helper has been deprecated in favour of `cache [I18n.locale, @taxons]`

## Solidus 2.1.0 (unreleased)

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
