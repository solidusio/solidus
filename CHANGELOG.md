## Solidus 1.3.0 (unreleased)

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

*   Made Spree::Order validate :store_id

    All orders created since Spree v2.4 should have a store assigned. We want to build more
    functionality onto that relation, so we need to make sure that every order has a store.
    Please run `rake solidus:upgrade:one_point_three` to make sure your orders have a store id set.

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

    More information is available in the [VersionCake README](https://github.com/bwillis/versioncake)

*   Bootstrap 4.0.0-alpha.2 is included into the admin.

*   Pagination now uses an admin-specific kaminari theme, which uses the
    bootstrap4 styles. If you have a custom admin page with pagination you can
    use this style with the following.

        <%= paginate @collection, theme: "solidus_admin" %>

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
