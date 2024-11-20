# frozen_string_literal: true

# This is the primary location for defining spree preferences
#
# The expectation is that this is created once and stored in
# the spree environment
#
# setters:
# a.color = :blue
# a[:color] = :blue
# a.set :color = :blue
# a.preferred_color = :blue
#
# getters:
# a.color
# a[:color]
# a.get :color
# a.preferred_color
#
require "spree/core/search/base"
require "spree/core/search/variant"
require 'spree/preferences/configuration'
require 'spree/core/environment'

require 'uri'

module Spree
  class AppConfiguration < Preferences::Configuration
    include Spree::Core::EnvironmentExtension
    # Preferences (alphabetized to more easily lookup particular preferences)

    # @!attribute [rw] address_requires_phone
    #   @return [Boolean] should phone number be required (default: +true+)
    preference :address_requires_phone, :boolean, default: true

    # @!attribute [rw] address_requires_state
    #   @return [Boolean] should state/state_name be required (default: +true+)
    preference :address_requires_state, :boolean, default: true

    # @!attribute [rw] admin_interface_logo
    #   @return [String] URL of logo used in admin (default: +'logo/solidus.svg'+)
    preference :admin_interface_logo, :string, default: 'logo/solidus.svg'

    # @!attribute [rw] admin_products_per_page
    #   @return [Integer] Number of products to display in admin (default: +10+)
    preference :admin_products_per_page, :integer, default: 10

    # @!attribute [rw] admin_variants_per_page
    #   @return [Integer] Number of variants to display in admin (default: +20+)
    preference :admin_variants_per_page, :integer, default: 20

    # @!attribute [rw] admin_vat_country_iso
    #   Set this if you want to enter prices in the backend including value added tax.
    #   @return [String, nil] Two-letter ISO code of that {Spree::Country} for which
    #      prices are entered in the backend (default: nil)
    preference :admin_vat_country_iso, :string, default: nil

    # @!attribute [rw] allow_checkout_on_gateway_error
    #   @return [Boolean] Allow checkout to complete after a failed payment (default: +false+)
    preference :allow_checkout_on_gateway_error, :boolean, default: false

    # @!attribute [rw] allow_guest_checkout
    #   @return [Boolean] When false, customers must create an account to complete an order (default: +true+)
    preference :allow_guest_checkout, :boolean, default: true

    # @!attribute [rw] guest_token_cookie_options
    #   @return [Hash] Add additional guest_token cookie options here (ie. domain or path)
    preference :guest_token_cookie_options, :hash, default: {}

    # @!attribute [rw] allow_return_item_amount_editing
    #   @return [Boolean] Determines whether an admin is allowed to change a return item's pre-calculated amount (default: +false+)
    preference :allow_return_item_amount_editing, :boolean, default: false

    # @!attribute [rw] alternative_billing_phone
    #   @return [Boolean] Request an extra phone number for bill address (default: +false+)
    preference :alternative_billing_phone, :boolean, default: false

    # @!attribute [rw] alternative_shipping_phone
    #   @return [Boolean] Request an extra phone number for shipping address (default: +false+)
    preference :alternative_shipping_phone, :boolean, default: false

    # @!attribute [rw] always_put_site_name_in_title
    #   @return [Boolean] When true, site name is always appended to titles on the frontend (default: +true+)
    preference :always_put_site_name_in_title, :boolean, default: true

    # @!attribute [rw] auto_capture
    #   @note Setting this to true is not recommended. Performing an authorize
    #     and later capture has far superior error handing. VISA and MasterCard
    #     also require that shipments are sent within a certain time of the card
    #     being charged.
    #   @return [Boolean] Automatically capture the credit card (as opposed to just authorize and capture later) (default: +false+)
    preference :auto_capture, :boolean, default: false

    # @!attribute [rw] auto_capture_exchanges
    #   @return [Boolean] Automatically capture the credit card (as opposed to just authorize and capture later) (default: +false+)
    preference :auto_capture_exchanges, :boolean, default: false

    # @!attribute [rw] automatic_default_address
    #   The default value of true preserves existing backwards compatible feature of
    #   treating the most recently used address in checkout as the user's default address.
    #   Setting to false means that the user should manage their own default via some
    #   custom UI that uses AddressBookController.
    #   @return [Boolean] Whether use of an address in checkout marks it as user's default
    preference :automatic_default_address, :boolean, default: true

    # @!attribute [rw] billing_address_required
    #   Controls whether billing address is required or not in the checkout process
    #   by default, can be overridden at order level.
    #   (default: +false+)
    #   @return [Boolean]
    preference :billing_address_required, :boolean, default: false

    # @!attribute [rw] can_restrict_stock_management
    #   @return [Boolean] Indicates if stock management can be restricted by location
    preference :can_restrict_stock_management, :boolean, default: false

    # @!attribute [rw] checkout_zone
    #   @return [String] Name of a {Spree::Zone}, which limits available countries to those included in that zone. (default: +nil+)
    preference :checkout_zone, :string, default: nil

    # @!attribute [rw] company
    #   @return [Boolean] Request company field for billing and shipping addresses. (default: +false+)
    preference :company, :boolean, default: false

    # @!attribute [rw] completable_order_created_cutoff
    #   @return [Integer] the number of days to look back for created orders which get returned to the user as last completed
    preference :completable_order_created_cutoff_days, :integer, default: nil

    # @!attribute [rw] completable_order_created_cutoff
    #   @return [Integer] the number of days to look back for updated orders which get returned to the user as last completed
    preference :completable_order_updated_cutoff_days, :integer, default: nil

    # @!attribute [rw] credit_to_new_allocation
    #   @return [Boolean] Creates a new allocation anytime {Spree::StoreCredit#credit} is called
    preference :credit_to_new_allocation, :boolean, default: false

    # @!attribute [rw] currency
    #   Currency to use by default when not defined on the site (default: +"USD"+)
    #   @return [String] ISO 4217 Three letter currency code
    preference :currency, :string, default: "USD"

    # @!attribute [rw] customer_returns_per_page
    #   @return [Integer] Customer returns to show per-page in the admin (default: +15+)
    preference :customer_returns_per_page, :integer, default: 15

    # @!attribute [rw] default_country_iso
    #   Default customer country ISO code
    #   @return [String] Two-letter ISO code of a {Spree::Country} to assumed as the country of an unidentified customer (default: "US")
    preference :default_country_iso, :string, default: 'US'

    # @!attribute [rw] default_email_regexp
    #   @return [Regexp] Regex to be used in email validations, for example in Spree::EmailValidator
    preference :default_email_regexp, :regexp, default: URI::MailTo::EMAIL_REGEXP

    # @!attribute [rw] generate_api_key_for_all_roles
    #   @return [Boolean] Allow generating api key automatically for user
    #   at role_user creation for all roles. (default: +false+)
    preference :generate_api_key_for_all_roles, :boolean, default: false

    # @!attribute [rw] inventory_cache_threshold
    #   Only invalidate product caches when the count on hand for a stock item
    #   falls below or rises about the inventory_cache_threshold.  When undefined, the
    #   product caches will be invalidated anytime the count on hand is changed.
    #   @return [Integer]
    preference :inventory_cache_threshold, :integer

    # @!attribute [rw] layout
    #   @return [String] template to use for layout on the frontend (default: +"spree/layouts/spree_application"+)
    preference :layout, :string, default: 'spree/layouts/spree_application'

    # @!attribute [rw] logo
    #   @return [String] URL of logo used on frontend (default: +'logo/solidus.svg'+)
    preference :logo, :string, default: 'logo/solidus.svg'

    # @!attribute [rw] log_entry_permitted_classes
    #   @return [Array<String>] An array of extra classes that are allowed to be
    #     loaded from a serialized YAML as details in {Spree::LogEntry}
    #     (defaults to a non-frozen empty array, so that extensions can add
    #     their own classes).
    #   @example
    #     config.log_entry_permitted_classes = ['Date']
    preference :log_entry_permitted_classes, :array, default: []

    # @!attribute [rw] log_entry_allow_aliases
    #   @return [Boolean] Whether YAML aliases are allowed when loading
    #     serialized data in {Spree::LogEntry}. It defaults to true. Depending
    #     on the source of your data, you may consider disabling it to prevent
    #     entity expansion attacks.
    preference :log_entry_allow_aliases, :boolean, default: true

    # @!attribute [rw] max_level_in_taxons_menu
    #   @return [Integer] maximum nesting level in taxons menu (default: +1+)
    preference :max_level_in_taxons_menu, :integer, default: 1

    # @!attribute [rw] order_bill_address_used
    #   @return [Boolean] Use the order's bill address, as opposed to storing
    #   bill addresses on payment sources. (default: +true+)
    preference :order_bill_address_used, :boolean, default: true

    # @!attribute [rw] order_capturing_time_window
    #   @return [Integer] the number of days to look back for fully-shipped/cancelled orders in order to charge for them
    preference :order_capturing_time_window, :integer, default: 14

    # @!attribute [rw] order_mutex_max_age
    #   @return [Integer] Max age of {Spree::OrderMutex} in seconds (default: 2 minutes)
    preference :order_mutex_max_age, :integer, default: 120

    # @!attribute [rw] orders_per_page
    #   @return [Integer] Orders to show per-page in the admin (default: +15+)
    preference :orders_per_page, :integer, default: 15

    # @!attribute [rw] properties_per_page
    #   @return [Integer] Properties to show per-page in the admin (default: +15+)
    preference :properties_per_page, :integer, default: 15

    # @!attribute [rw] products_per_page
    #   @return [Integer] Products to show per-page in the frontend (default: +12+)
    preference :products_per_page, :integer, default: 12

    # @!attribute [rw] require_master_price
    #   @return [Boolean] Require a price on the master variant of a product (default: +true+)
    preference :require_master_price, :boolean, default: true

    # @!attribute [rw] require_payment_to_ship
    #   @return [Boolean] Allows shipments to be ready to ship regardless of the order being paid if false (default: +true+)
    preference :require_payment_to_ship, :boolean, default: true # Allows shipments to be ready to ship regardless of the order being paid if false

    # @!attribute [rw] return_eligibility_number_of_days
    #   @return [Integer] default: 365
    preference :return_eligibility_number_of_days, :integer, default: 365

    # @!attribute [rw] roles_for_auto_api_key
    #   @return [Array] An array of roles where generating an api key for a user
    #   at role_user creation is desired when user has one of these roles.
    #   (default: +['admin']+)
    preference :roles_for_auto_api_key, :array, default: ['admin']

    # @!attribute [rw] countries_that_use_nested_subregions
    #   @return [Array] An array of countries that use nested subregions, instead
    #   of the default subregions that come with Carmen. Will be used on store creation
    #   to ensure the correct states are generated, and when running the states
    #   regenerate rake task.
    #   (default: +['IT']+)
    preference :countries_that_use_nested_subregions, :array, default: ['IT']

    # @!attribute [rw] send_core_emails
    #   @return [Boolean] Whether to send transactional emails (default: true)
    preference :send_core_emails, :boolean, default: true

    # @!attribute [rw] shipping_instructions
    #   @return [Boolean] Request instructions/info for shipping (default: +false+)
    preference :shipping_instructions, :boolean, default: false

    # @!attribute [rw] show_only_complete_orders_by_default
    #   @return [Boolean] Only show completed orders by default in the admin (default: +true+)
    preference :show_only_complete_orders_by_default, :boolean, default: true

    # @!attribute [rw] show_variant_full_price
    #   @return [Boolean] Displays variant full price or difference with product price. (default: +false+)
    preference :show_variant_full_price, :boolean, default: false

    # @!attribute [rw] show_products_without_price
    #   @return [Boolean] Whether products without a price are visible in the frontend (default: +false+)
    preference :show_products_without_price, :boolean, default: false

    # @!attribute [rw] show_raw_product_description
    #   @return [Boolean] Don't escape HTML of product descriptions. (default: +false+)
    preference :show_raw_product_description, :boolean, default: false

    # @!attribute [rw] tax_using_ship_address
    #   @return [Boolean] Use the shipping address rather than the billing address to determine tax (default: +true+)
    preference :tax_using_ship_address, :boolean, default: true

    # @!attribute [rw] track_inventory_levels
    #   Determines whether to track on_hand values for variants / products. If
    #   you do not track inventory, or have effectively unlimited inventory for
    #   all products you can turn this on.
    #   @return [] Track on_hand values for variants / products. (default: true)
    preference :track_inventory_levels, :boolean, default: true

    # Other configurations

    # Allows restricting what currencies will be available.
    #
    # @!attribute [r] available_currencies
    #   @return [Array] An array of available currencies from Money::Currency.all
    attr_writer :available_currencies
    def available_currencies
      @available_currencies ||= ::Money::Currency.all
    end

    # searcher_class allows spree extension writers to provide their own Search class
    class_name_attribute :searcher_class, default: 'Spree::Core::Search::Base'

    # Allows implementing custom pricing for variants
    # @!attribute [rw] variant_price_selector_class
    # @see Spree::Variant::PriceSelector
    # @return [Class] an object that conforms to the API of
    #   the standard variant price selector class Spree::Variant::PriceSelector.
    class_name_attribute :variant_price_selector_class, default: 'Spree::Variant::PriceSelector'

    # Shortcut for getting the variant price selector's pricing options class
    #
    # @return [Class] The pricing options class to be used
    delegate :pricing_options_class, to: :variant_price_selector_class

    # Shortcut for the default pricing options
    # @return [variant_price_selector_class] An instance of the pricing options class with default desired
    #   attributes
    def default_pricing_options
      pricing_options_class.new
    end

    class_name_attribute :variant_search_class, default: 'Spree::Core::Search::Variant'

    # Allows implementing custom vat prices generation
    # @!attribute [rw] variant_vat_prices_generator_class
    # @see Spree::Variant::VatPriceGenerator
    # @return [Class] an object that conforms to the API of
    #   the standard variant vat prices generator class
    #   Spree::Variant::VatPriceGenerator.
    class_name_attribute :variant_vat_prices_generator_class, default: 'Spree::Variant::VatPriceGenerator'

    class_name_attribute :allocator_class, default: 'Spree::Stock::Allocator::OnHandFirst'

    class_name_attribute :shipping_rate_sorter_class, default: 'Spree::Stock::ShippingRateSorter'

    class_name_attribute :shipping_rate_selector_class, default: 'Spree::Stock::ShippingRateSelector'

    # Allows providing your own class for calculating taxes on a shipping rate.
    #
    # @!attribute [rw] shipping_rate_tax_calculator_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::TaxCalculator::ShippingRate
    class_name_attribute :shipping_rate_tax_calculator_class, default: 'Spree::TaxCalculator::ShippingRate'

    # Allows providing your own Mailer for order mailer.
    #
    # @!attribute [rw] order_mailer_class
    # @return [ActionMailer::Base] an object that responds to "confirm_email",
    #   "cancel_email" and "inventory_cancellation_email"
    #   (e.g. an ActionMailer with a "confirm_email" method) with the same
    #   signature as Spree::OrderMailer.confirm_email.
    class_name_attribute :order_mailer_class, default: 'Spree::OrderMailer'

    # Allows providing your own order update attributes class for checkout.
    #
    # @!attribute [rw] order_update_attributes_class
    # @return [Class] a class that responds to "call"
    #   with the same signature as Spree::OrderUpdateAttributes.
    class_name_attribute :order_update_attributes_class, default: 'Spree::OrderUpdateAttributes'

    # Allows providing a different order recalculator.
    # @!attribute [rw] order_recalculator_class
    # @see Spree::OrderUpdater
    # @return [Class] an object that conforms to the API of
    #   the standard order recalculator class
    #   Spree::OrderUpdater.
    class_name_attribute :order_recalculator_class, default: 'Spree::OrderUpdater'

    # Allows providing your own Mailer for reimbursement mailer.
    #
    # @!attribute [rw] reimbursement_mailer_class
    # @return [ActionMailer::Base] an object that responds to "reimbursement_email"
    #   (e.g. an ActionMailer with a "reimbursement_email" method) with the same
    #   signature as Spree::ReimbursementMailer.reimbursement_email.
    class_name_attribute :reimbursement_mailer_class, default: 'Spree::ReimbursementMailer'

    # Allows providing your own Mailer for shipped cartons.
    #
    # @!attribute [rw] carton_shipped_email_class
    # @return [ActionMailer::Base] an object that responds to "shipped_email"
    #   (e.g. an ActionMailer with a "shipped_email" method) with the same
    #   signature as Spree::CartonMailer.shipped_email.
    class_name_attribute :carton_shipped_email_class, default: 'Spree::CartonMailer'

    # Allows providing your own class for merging two orders.
    #
    # @!attribute [rw] order_merger_class
    # @return [Class] a class with the same public interfaces
    #   as Spree::OrderMerger.
    class_name_attribute :order_merger_class, default: 'Spree::OrderMerger'

    # Allows providing your own class for adding default payments to a user's
    # order from their "wallet".
    #
    # @!attribute [rw] default_payment_builder_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::Wallet::DefaultPaymentBuilder.
    class_name_attribute :default_payment_builder_class, default: 'Spree::Wallet::DefaultPaymentBuilder'

    # Allows providing your own class for managing the contents of an order.
    #
    # @!attribute [rw] order_contents_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::OrderContents.
    class_name_attribute :order_contents_class, default: 'Spree::SimpleOrderContents'

    # Allows providing your own class for shipping an order.
    #
    # @!attribute [rw] order_shipping_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::OrderShipping.
    class_name_attribute :order_shipping_class, default: 'Spree::OrderShipping'

    # Allows providing your own class for managing the inventory units of a
    # completed order.
    #
    # @!attribute [rw] order_cancellations_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::OrderCancellations.
    class_name_attribute :order_cancellations_class, default: 'Spree::OrderCancellations'

    # Allows providing your own class for canceling payments.
    #
    # @!attribute [rw] payment_canceller
    # @return [Class] a class instance that responds to `cancel!(payment)`
    attr_writer :payment_canceller
    def payment_canceller
      @payment_canceller ||= Spree::Payment::Cancellation.new(
        reason: Spree::Payment::Cancellation::DEFAULT_REASON
      )
    end

    # Allows providing your own class for adding payment sources to a user's
    # "wallet" after an order moves to the complete state.
    #
    # @!attribute [rw] add_payment_sources_to_wallet_class
    # @return [Class] a class with the same public interfaces
    #   as Spree::Wallet::AddPaymentSourcesToWallet.
    class_name_attribute :add_payment_sources_to_wallet_class, default: 'Spree::Wallet::AddPaymentSourcesToWallet'

    # Allows providing your own class for calculating taxes on an order.
    #
    # This extension point is under development and may change in a future minor release.
    #
    # @!attribute [rw] tax_adjuster_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::Tax::OrderAdjuster
    class_name_attribute :tax_adjuster_class, default: 'Spree::Tax::OrderAdjuster'

    # Allows providing your own class for calculating taxes on an order.
    #
    # @!attribute [rw] tax_calculator_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::TaxCalculator::Default
    class_name_attribute :tax_calculator_class, default: 'Spree::TaxCalculator::Default'

    # Allows providing your own class for choosing which store to use.
    #
    # @!attribute [rw] current_store_selector_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::CurrentStoreSelector
    class_name_attribute :current_store_selector_class, default: 'Spree::StoreSelector::ByServerName'

    # Allows providing your own class for creating urls on taxons
    #
    # @!attribute [rw] taxon_url_parametizer_class
    # @return [Class] a class that provides a `#parameterize` method that
    # returns a String
    class_name_attribute :taxon_url_parametizer_class, default: 'ActiveSupport::Inflector'

    # Allows providing your own class for image galleries on Variants
    #
    # @!attribute [rw] variant_gallery_class
    # @return [Class] a class that implements an `images` method and returns an
    # Enumerable of images adhering to the present_image_class interface
    class_name_attribute :variant_gallery_class, default: 'Spree::Gallery::VariantGallery'

    # Allows providing your own class for image galleries on Products
    #
    # @!attribute [rw] product_gallery_class
    # @return [Class] a class that implements an `images` method and returns an
    # Enumerable of images adhering to the present_image_class interface
    class_name_attribute :product_gallery_class, default: 'Spree::Gallery::ProductGallery'

    # Allows switching attachment library for Image
    #
    # `Spree::Image::ActiveStorageAttachment`
    # is the default and provides the Active Storage implementation.
    #
    # @!attribute [rw] image_attachment_module
    # @return [Module] a module that can be included into Spree::Image to allow attachments
    # Enumerable of images adhering to the present_image_class interface
    class_name_attribute :image_attachment_module, default: "Spree::Image::ActiveStorageAttachment"

    # @!attribute [rw] allowed_image_mime_types
    #
    # Defines which MIME types are allowed for images
    # `%w(image/jpeg image/jpg image/png image/gif).freeze` is the default.
    #
    # @return [Array]
    class_name_attribute :allowed_image_mime_types, default: %w(image/jpeg image/jpg image/png image/gif).freeze

    # @!attribute [rw] product_image_style_default
    #
    # Defines which style to default to when style is not provided
    # :product is the default.
    #
    # @return [Symbol]
    class_name_attribute :product_image_style_default, default: :product

    # @!attribute [rw] product_image_styles
    #
    # Defines image styles/sizes hash for styles
    # `{ mini: '48x48>',
    #    small: '400x400>',
    #    product: '680x680>',
    #    large: '1200x1200>' } is the default.
    #
    # @return [Hash]
    class_name_attribute :product_image_styles, default: { mini: '48x48>',
                                                          small: '400x400>',
                                                          product: '680x680>',
                                                          large: '1200x1200>' }

    # Allows providing your own class for prioritizing store credit application
    # to an order.
    #
    # @!attribute [rw] store_credit_prioritizer_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::StoreCreditPrioritizer.
    class_name_attribute :store_credit_prioritizer_class, default: 'Spree::StoreCreditPrioritizer'

    # Allows finding brand for product.
    #
    # @!attribute [rw] brand_selector_class
    # @return [Class] a class with the same public interfaces as
    #   Spree::TaxonBrandSelector.
    class_name_attribute :brand_selector_class, default: 'Spree::TaxonBrandSelector'

    # @!attribute [rw] taxon_image_style_default
    #
    # Defines which style to default to when style is not provided
    # :mini is the default.
    #
    # @return [Symbol]
    class_name_attribute :taxon_image_style_default, default: :mini

    # @!attribute [rw] taxon_styles
    #
    # Defines taxon styles/sizes hash for styles
    # `{ mini: '48x48>',
    #    small: '400x400>',
    #    product: '680x680>',
    #    large: '1200x1200>' } is the default.
    #
    # @return [Hash]
    class_name_attribute :taxon_image_styles, default: { mini: '32x32>', normal: '128x128>' }

    # Allows switching attachment library for Taxon
    #
    # `Spree::Taxon::ActiveStorageAttachment`
    # is the default and provides the Active Storage implementation.
    #
    # @!attribute [rw] taxon_attachment_module
    # @return [Module] a module that can be included into Spree::Taxon to allow attachments
    # Enumerable of taxons adhering to the present_taxon_class interface
    class_name_attribute :taxon_attachment_module, default: "Spree::Taxon::ActiveStorageAttachment"

    # Set of classes that can be promotion adjustment sources
    add_class_set :adjustment_promotion_source_types, default: []

    # Configures the absolute path that contains the Solidus engine
    # migrations. This will be checked at app boot to confirm that all Solidus
    # migrations are installed.
    #
    # @!attribute [rw] migration_path
    # @return [Pathname] the configured path. (default: `Rails.root.join('db', 'migrate')`)
    attr_writer :migration_path
    def migration_path
      @migration_path ||= ::Rails.root.join('db', 'migrate')
    end

    # Allows providing your own class instance for generating order numbers.
    #
    # @!attribute [rw] order_number_generator
    # @return [Class] a class instance with the same public interfaces as
    #   Spree::Order::NumberGenerator
    # @api experimental
    attr_writer :order_number_generator
    def order_number_generator
      @order_number_generator ||= Spree::Order::NumberGenerator.new
    end

    def state_machines
      @state_machines ||= Spree::Core::StateMachines.new
    end

    def static_model_preferences
      @static_model_preferences ||= Spree::Preferences::StaticModelPreferences.new
    end

    def stock
      @stock_configuration ||= Spree::Core::StockConfiguration.new
    end

    # Allows providing your own promotion configuration instance
    # @!attribute [rw] promotions
    # @return [Spree::Core::NullPromotionConfiguration] an object that conforms to the API of
    #   the example promotion configuration class Spree::Core::NullPromotionConfiguration.
    attr_writer :promotions
    def promotions
      @promotions ||= Spree::Core::NullPromotionConfiguration.new
    end

    class << self
      private

      def promotions_deprecation_message(method, new_method_name = nil)
        "The `Spree::Config.#{method}` preference is deprecated and will be removed in Solidus 5.0. " \
        "Use `Spree::Config.promotions.#{new_method_name || method}` instead"
      end
    end

    def promotion_adjuster_class
      promotions.order_adjuster_class
    end

    def promotion_adjuster_class=(klass)
      promotions.order_adjuster_class = klass
    end
    deprecate promotion_adjuster_class: promotions_deprecation_message("promotion_adjuster_class", "order_adjuster_class"), deprecator: Spree.deprecator
    deprecate "promotion_adjuster_class=": promotions_deprecation_message("promotion_adjuster_class=", "order_adjuster_class="), deprecator: Spree.deprecator

    delegate :promotion_chooser_class, :promotion_chooser_class=, to: :promotions
    deprecate promotion_chooser_class: promotions_deprecation_message("promotion_chooser_class"), deprecator: Spree.deprecator
    deprecate "promotion_chooser_class=": promotions_deprecation_message("promotion_chooser_class="), deprecator: Spree.deprecator

    delegate :shipping_promotion_handler_class, :shipping_promotion_handler_class=, to: :promotions
    deprecate shipping_promotion_handler_class: promotions_deprecation_message("shipping_promotion_handler_class"), deprecator: Spree.deprecator
    deprecate "shipping_promotion_handler_class=": promotions_deprecation_message("shipping_promotion_handler_class="), deprecator: Spree.deprecator

    delegate :coupon_code_handler_class, :coupon_code_handler_class=, to: :promotions
    deprecate coupon_code_handler_class: promotions_deprecation_message("coupon_code_handler_class"), deprecator: Spree.deprecator
    deprecate "coupon_code_handler_class=": promotions_deprecation_message("coupon_code_handler_class"), deprecator: Spree.deprecator

    delegate :promotion_code_batch_mailer_class, :promotion_code_batch_mailer_class=, to: :promotions
    deprecate promotion_code_batch_mailer_class: promotions_deprecation_message("promotion_code_batch_mailer_class"), deprecator: Spree.deprecator
    deprecate "promotion_code_batch_mailer_class=": promotions_deprecation_message("promotion_code_batch_mailer_class="), deprecator: Spree.deprecator

    delegate :preferred_promotions_per_page, :preferred_promotions_per_page=, to: :promotions
    deprecate preferred_promotions_per_page: promotions_deprecation_message("preferred_promotions_per_page"), deprecator: Spree.deprecator
    deprecate "preferred_promotions_per_page=": promotions_deprecation_message("preferred_promotions_per_page="), deprecator: Spree.deprecator

    def roles
      @roles ||= Spree::RoleConfiguration.new.tap do |roles|
        roles.assign_permissions :default, ['Spree::PermissionSets::DefaultCustomer']
        roles.assign_permissions :admin, ['Spree::PermissionSets::SuperUser']
      end
    end

    def user_last_url_storer_rules
      @user_last_url_storer_rules ||= ::Spree::Core::ClassConstantizer::Set.new.tap do |set|
        set << 'Spree::UserLastUrlStorer::Rules::AuthenticationRule'
      end
    end

    def environment
      @environment ||= Spree::Core::Environment.new(self).tap do |env|
        env.calculators.shipping_methods = %w[
          Spree::Calculator::Shipping::FlatPercentItemTotal
          Spree::Calculator::Shipping::FlatRate
          Spree::Calculator::Shipping::FlexiRate
          Spree::Calculator::Shipping::PerItem
          Spree::Calculator::Shipping::PriceSack
        ]

        env.calculators.tax_rates = %w[
          Spree::Calculator::DefaultTax
          Spree::Calculator::FlatFee
        ]

        env.payment_methods = %w[
          Spree::PaymentMethod::BogusCreditCard
          Spree::PaymentMethod::SimpleBogusCreditCard
          Spree::PaymentMethod::StoreCredit
          Spree::PaymentMethod::Check
        ]

        env.stock_splitters = %w[
          Spree::Stock::Splitter::ShippingCategory
          Spree::Stock::Splitter::Backordered
        ]
      end
    end

    # Default admin VAT location
    #
    # An object that responds to :state_id and :country_id so it can double as a Spree::Address in
    # Spree::Zone.for_address. Takes the `admin_vat_country_iso` as input.
    #
    # @see admin_vat_country_iso The admin VAT country
    # @return [Spree::Tax::TaxLocation] default tax location
    def admin_vat_location
      @default_tax_location ||= Spree::Tax::TaxLocation.new(
        country: Spree::Country.find_by(iso: admin_vat_country_iso)
      )
    end
  end
end
