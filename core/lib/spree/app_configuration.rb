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

module Spree
  class AppConfiguration < Preferences::Configuration
    # Alphabetized to more easily lookup particular preferences

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

    # @!attribute [rw] allow_checkout_on_gateway_error
    #   @return [Boolean] Allow checkout to complete after a failed payment (default: +false+)
    preference :allow_checkout_on_gateway_error, :boolean, default: false

    # @!attribute [rw] allow_guest_checkout
    #   @return [Boolean] When false, customers must create an account to complete an order (default: +true+)
    preference :allow_guest_checkout, :boolean, default: true

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

    # @!attribute [rw] binary_inventory_cache
    #   Only invalidate product caches when they change from in stock to out of
    #   stock. By default, caches are invalidated on any change of inventory
    #   quantity. Setting this to true should make operations on inventory
    #   faster.
    #   (default: +false+)
    #   @deprecated - use inventory_cache_threshold instead
    #   @return [Boolean]
    preference :binary_inventory_cache, :boolean, default: false

    # @!attribute [rw] completable_order_created_cutoff
    #   @return [Integer] the number of days to look back for created orders which get returned to the user as last completed
    preference :completable_order_created_cutoff_days, :integer, default: nil

    # @!attribute [rw] completable_order_created_cutoff
    #   @return [Integer] the number of days to look back for updated orders which get returned to the user as last completed
    preference :completable_order_updated_cutoff_days, :integer, default: nil

    # @!attribute [rw] inventory_cache_threshold
    #   Only invalidate product caches when the count on hand for a stock item
    #   falls below or rises about the inventory_cache_threshold.  When undefined, the
    #   product caches will be invalidated anytime the count on hand is changed.
    #   @return [Integer]
    preference :inventory_cache_threshold, :integer

    # @!attribute [rw] checkout_zone
    #   @return [String] Name of a {Spree::Zone}, which limits available countries to those included in that zone. (default: +nil+)
    preference :checkout_zone, :string, default: nil

    # @!attribute [rw] company
    #   @return [Boolean] Request company field for billing and shipping addresses. (default: +false+)
    preference :company, :boolean, default: false

    # @!attribute [rw] currency
    #   Currency to use by default when not defined on the site (default: +"USD"+)
    #   @return [String] ISO 4217 Three letter currency code
    preference :currency, :string, default: "USD"

    # @!attribute [rw] default_country_id
    #   @deprecated Use the default country ISO preference instead
    #   @return [Integer,nil] id of {Spree::Country} to be selected by default in dropdowns (default: nil)
    preference :default_country_id, :integer

    # @!attribute [rw] default_country_iso
    #   Default customer country ISO code
    #   @return [String] Two-letter ISO code of a {Spree::Country} to assumed as the country of an unidentified customer (default: "US")
    preference :default_country_iso, :string, default: 'US'

    # @!attribute [rw] admin_vat_country_iso
    #   Set this if you want to enter prices in the backend including value added tax.
    #   @return [String, nil] Two-letter ISO code of that {Spree::Country} for which
    #      prices are entered in the backend (default: nil)
    preference :admin_vat_country_iso, :string, default: nil

    # @!attribute [rw] generate_api_key_for_all_roles
    #   @return [Boolean] Allow generating api key automatically for user
    #   at role_user creation for all roles. (default: +false+)
    preference :generate_api_key_for_all_roles, :boolean, default: false

    # @!attribute [rw] layout
    #   @return [String] template to use for layout on the frontend (default: +"spree/layouts/spree_application"+)
    preference :layout, :string, default: 'spree/layouts/spree_application'

    # @!attribute [rw] logo
    #   @return [String] URL of logo used on frontend (default: +'logo/solidus.svg'+)
    preference :logo, :string, default: 'logo/solidus.svg'

    # @!attribute [rw] order_bill_address_used
    #   @return [Boolean] Use the order's bill address, as opposed to storing
    #   bill addresses on payment sources. (default: +true+)
    preference :order_bill_address_used, :boolean, default: true

    # @!attribute [rw] order_capturing_time_window
    #   @return [Integer] the number of days to look back for fully-shipped/cancelled orders in order to charge for them
    preference :order_capturing_time_window, :integer, default: 14

    # @!attribute [rw] max_level_in_taxons_menu
    #   @return [Integer] maximum nesting level in taxons menu (default: +1+)
    preference :max_level_in_taxons_menu, :integer, default: 1

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

    # @!attribute [rw] promotions_per_page
    #   @return [Integer] Promotions to show per-page in the admin (default: +15+)
    preference :promotions_per_page, :integer, default: 15

    # @!attribute [rw] customer_returns_per_page
    #   @return [Integer] Customer returns to show per-page in the admin (default: +15+)
    preference :customer_returns_per_page, :integer, default: 15

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

    # Default mail headers settings

    # @!attribute [rw] send_core_emails
    #   @return [Boolean] Whether to send transactional emails (default: true)
    preference :send_core_emails, :boolean, default: true

    # @!attribute [rw] mails_from
    #   @return [String] Email address used as +From:+ field in transactional emails.
    preference :mails_from, :string, default: 'spree@example.com'

    # Store credits configurations

    # @!attribute [rw] credit_to_new_allocation
    #   @return [Boolean] Creates a new allocation anytime {Spree::StoreCredit#credit} is called
    preference :credit_to_new_allocation, :boolean, default: false

    # @!attribute [rw] automatic_default_address
    #   The default value of true preserves existing backwards compatible feature of
    #   treating the most recently used address in checkout as the user's default address.
    #   Setting to false means that the user should manage their own default via some
    #   custom UI that uses AddressBookController.
    #   @return [Boolean] Whether use of an address in checkout marks it as user's default
    preference :automatic_default_address, :boolean, default: true

    # @!attribute [rw] can_restrict_stock_management
    #   @return [Boolean] Indicates if stock management can be restricted by location
    preference :can_restrict_stock_management, :boolean, default: false

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

    # promotion_chooser_class allows extensions to provide their own PromotionChooser
    class_name_attribute :promotion_chooser_class, default: 'Spree::PromotionChooser'

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

    # Allows providing your own Mailer for promotion code batch mailer.
    #
    # @!attribute [rw] promotion_code_batch_mailer_class
    # @return [ActionMailer::Base] an object that responds to "promotion_code_batch_finished",
    #   and "promotion_code_batch_errored"
    #   (e.g. an ActionMailer with a "promotion_code_batch_finished" method) with the same
    #   signature as Spree::PromotionCodeBatchMailer.promotion_code_batch_finished.
    class_name_attribute :promotion_code_batch_mailer_class, default: 'Spree::PromotionCodeBatchMailer'

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
    # `Spree::Image::PaperclipAttachment`
    # is the default and provides the classic Paperclip implementation.
    #
    # @!attribute [rw] image_attachment_module
    # @return [Module] a module that can be included into Spree::Image to allow attachments
    # Enumerable of images adhering to the present_image_class interface
    class_name_attribute :image_attachment_module, default: 'Spree::Image::PaperclipAttachment'

    # Allows switching attachment library for Taxon
    #
    # `Spree::Taxon::PaperclipAttachment`
    # is the default and provides the classic Paperclip implementation.
    #
    # @!attribute [rw] taxon_attachment_module
    # @return [Module] a module that can be included into Spree::Taxon to allow attachments
    # Enumerable of taxons adhering to the present_taxon_class interface
    class_name_attribute :taxon_attachment_module, default: 'Spree::Taxon::PaperclipAttachment'

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

    def roles
      @roles ||= Spree::RoleConfiguration.new.tap do |roles|
        roles.assign_permissions :default, ['Spree::PermissionSets::DefaultCustomer']
        roles.assign_permissions :admin, ['Spree::PermissionSets::SuperUser']
      end
    end

    def events
      @events_configuration ||= Spree::Event::Configuration.new
    end

    def user_last_url_storer_rules
      @user_last_url_storer_rules ||= ::Spree::Core::ClassConstantizer::Set.new.tap do |set|
        set << 'Spree::UserLastUrlStorer::Rules::AuthenticationRule'
      end
    end

    def environment
      @environment ||= Spree::Core::Environment.new(self).tap do |env|
        env.calculators.promotion_actions_create_adjustments = %w[
          Spree::Calculator::FlatPercentItemTotal
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::TieredPercent
          Spree::Calculator::TieredFlatRate
        ]

        env.calculators.promotion_actions_create_item_adjustments = %w[
          Spree::Calculator::DistributedAmount
          Spree::Calculator::FlatRate
          Spree::Calculator::FlexiRate
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::TieredPercent
        ]

        env.calculators.promotion_actions_create_quantity_adjustments = %w[
          Spree::Calculator::PercentOnLineItem
          Spree::Calculator::FlatRate
        ]

        env.calculators.shipping_methods = %w[
          Spree::Calculator::Shipping::FlatPercentItemTotal
          Spree::Calculator::Shipping::FlatRate
          Spree::Calculator::Shipping::FlexiRate
          Spree::Calculator::Shipping::PerItem
          Spree::Calculator::Shipping::PriceSack
        ]

        env.calculators.tax_rates = %w[
          Spree::Calculator::DefaultTax
        ]

        env.payment_methods = %w[
          Spree::PaymentMethod::BogusCreditCard
          Spree::PaymentMethod::SimpleBogusCreditCard
          Spree::PaymentMethod::StoreCredit
          Spree::PaymentMethod::Check
        ]

        env.promotions.rules = %w[
          Spree::Promotion::Rules::ItemTotal
          Spree::Promotion::Rules::Product
          Spree::Promotion::Rules::User
          Spree::Promotion::Rules::FirstOrder
          Spree::Promotion::Rules::UserLoggedIn
          Spree::Promotion::Rules::OneUsePerUser
          Spree::Promotion::Rules::Taxon
          Spree::Promotion::Rules::NthOrder
          Spree::Promotion::Rules::OptionValue
          Spree::Promotion::Rules::FirstRepeatPurchaseSince
          Spree::Promotion::Rules::UserRole
          Spree::Promotion::Rules::Store
        ]

        env.promotions.actions = %w[
          Spree::Promotion::Actions::CreateAdjustment
          Spree::Promotion::Actions::CreateItemAdjustments
          Spree::Promotion::Actions::CreateQuantityAdjustments
          Spree::Promotion::Actions::FreeShipping
        ]

        env.promotions.shipping_actions = %w[
          Spree::Promotion::Actions::FreeShipping
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
