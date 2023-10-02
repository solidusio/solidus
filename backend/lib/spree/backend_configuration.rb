# frozen_string_literal: true

require 'spree/preferences/configuration'
require 'spree/backend_configuration/menu_item'

module Spree
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: I18n.default_locale

    # @!attribute [rw] themes
    #   @return [Hash] A hash containing the themes that are available for the admin panel
    preference :themes, :hash, default: {
      classic: 'spree/backend/all',
      solidus_admin: 'spree/backend/themes/solidus_admin'
    }

    # @!attribute [rw] theme
    #   @return [String] Default admin theme name
    versioned_preference :theme, :string, initial_value: 'classic', boundaries: { "4.2.0" => "solidus_admin" }

    def theme_path(user_theme = nil)
      user_theme ? themes.fetch(user_theme.to_sym) : themes.fetch(theme.to_sym)
    end

    # @!attribute [rw] admin_updated_navbar
    #   @return [Boolean] Should the updated navbar be used in admin (default: +false+)
    #
    versioned_preference :admin_updated_navbar, :boolean, initial_value: false, boundaries: { "4.2.0" => true }

    preference :frontend_product_path,
      :proc,
      default: proc {
        ->(template_context, product) {
          return unless template_context.spree.respond_to?(:product_path)

          template_context.spree.product_path(product)
        }
      }

    # @!attribute [rw] prefer_menu_item_partials
    #   @return [Boolean] Whether or not to prefer menu item partials when both a partial and children are present.
    versioned_preference :prefer_menu_item_partials, :boolean, initial_value: true, boundaries: { "4.2.0" => false }

    autoload :ORDER_TABS, 'spree/backend_configuration/deprecated_tab_constants'
    autoload :PRODUCT_TABS, 'spree/backend_configuration/deprecated_tab_constants'
    autoload :CONFIGURATION_TABS, 'spree/backend_configuration/deprecated_tab_constants'
    autoload :PROMOTION_TABS, 'spree/backend_configuration/deprecated_tab_constants'
    autoload :STOCK_TABS, 'spree/backend_configuration/deprecated_tab_constants'
    autoload :USER_TABS, 'spree/backend_configuration/deprecated_tab_constants'

    # Items can be added to the menu by using code like the following:
    #
    # Spree::Backend::Config.configure do |config|
    #   config.menu_items << config.class::MenuItem.new(
    #     label: :my_reports,
    #     icon: 'file-text-o', # see https://fontawesome.com/v4/icons/
    #     url: :my_admin_reports_path,
    #     condition: -> { can?(:admin, MyReports) },
    #     partial: 'spree/admin/shared/my_reports_sub_menu',
    #     match_path: '/reports',
    #   )
    # end
    #
    # @!attribute menu_items
    #   @return [Array<Spree::BackendConfiguration::MenuItem>]
    attr_writer :menu_items

    # Return the menu items which should be drawn in the menu
    #
    # @api public
    # @return [Array<Spree::BackendConfiguration::MenuItem>]
    def menu_items
      @menu_items ||= [
        MenuItem.new(
          label: :orders,
          icon: admin_updated_navbar ? 'ri-inbox-line' : 'shopping-cart',
          condition: -> { can?(:admin, Spree::Order) },
          match_path: %r{/(
            adjustments|
            credit_cards|
            creditcard_payments|
            customer_details|
            customer_returns|
            orders|
            payments|
            return_authorizations|
            shipments
          )}x,
        ),
        MenuItem.new(
          label: :products,
          icon: admin_updated_navbar ? 'ri-price-tag-3-line' : 'th-large',
          condition: -> { can?(:admin, Spree::Product) },
          partial: 'spree/admin/shared/product_sub_menu',
          data_hook: :admin_product_sub_tabs,
          children: [
            MenuItem.new(
              label: :products,
              condition: -> { can? :admin, Spree::Product },
              match_path: '/products',
            ),
            MenuItem.new(
              label: :option_types,
              condition: -> { can? :admin, Spree::OptionType },
              match_path: '/option_types',
            ),
            MenuItem.new(
              label: :properties,
              condition: -> { can? :admin, Spree::Property },
            ),
            MenuItem.new(
              label: :taxonomies,
              condition: -> { can? :admin, Spree::Taxonomy },
            ),
            MenuItem.new(
              url: :admin_taxons_path,
              condition: -> { can? :admin, Spree::Taxon },
              label: :display_order,
              match_path: '/taxons',
            ),
          ],
        ),
        MenuItem.new(
          label: :promotions,
          icon: admin_updated_navbar ? 'ri-megaphone-line' : 'bullhorn',
          partial: 'spree/admin/shared/promotion_sub_menu',
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path,
          data_hook: :admin_promotion_sub_tabs,
          children: [
            MenuItem.new(
              label: :promotions,
              condition: -> { can?(:admin, Spree::Promotion) },
            ),
            MenuItem.new(
              label: :promotion_categories,
              condition: -> { can?(:admin, Spree::PromotionCategory) },
            ),
          ],
        ),
        MenuItem.new(
          label: :stock,
          icon: admin_updated_navbar ? 'ri-stack-line' : 'cubes',
          match_path: %r{/(stock_items)},
          condition: -> { can?(:admin, Spree::StockItem) },
          url: :admin_stock_items_path,
        ),
        MenuItem.new(
          label: :users,
          icon: admin_updated_navbar ? 'ri-user-line' : 'user',
          match_path: %r{/(users|store_credits)},
          condition: -> { Spree.user_class && can?(:admin, Spree.user_class) },
          url: :admin_users_path,
        ),
        MenuItem.new(
          label: :settings,
          icon: admin_updated_navbar ? 'ri-settings-line' : 'wrench',
          data_hook: :admin_settings_sub_tabs,
          partial: 'spree/admin/shared/settings_sub_menu',
          condition: -> { can? :admin, Spree::Store },
          url: :admin_stores_path,
          children: [
            MenuItem.new(
              label: :stores,
              condition: -> { can? :admin, Spree::Store },
              url: :admin_stores_path,
            ),
            MenuItem.new(
              label: :payments,
              condition: -> { can? :admin, Spree::PaymentMethod },
              url: :admin_payment_methods_path,
            ),

            MenuItem.new(
              label: :taxes,
              condition: -> { can?(:admin, Spree::TaxCategory) || can?(:admin, Spree::TaxRate) },
              url: :admin_tax_categories_path,
              match_path: %r(tax_categories|tax_rates),
            ),
            MenuItem.new(
              label: :checkout,
              condition: -> {
                can?(:admin, Spree::RefundReason) ||
                can?(:admin, Spree::ReimbursementType) ||
                can?(:show, Spree::ReturnReason) ||
                can?(:show, Spree::AdjustmentReason)
              },
              url: :admin_refund_reasons_path,
              match_path: %r(refund_reasons|reimbursement_types|return_reasons|adjustment_reasons|store_credit_reasons)
            ),
            MenuItem.new(
              label: :shipping,
              condition: -> {
                can?(:admin, Spree::ShippingMethod) ||
                  can?(:admin, Spree::ShippingCategory) ||
                  can?(:admin, Spree::StockLocation)
              },
              url: :admin_shipping_methods_path,
              match_path: %r(shipping_methods|shipping_categories|stock_locations),
            ),
            MenuItem.new(
              label: :zones,
              condition: -> { can?(:admin, Spree::Zone) },
              url: :admin_zones_path,
            ),
          ],
        )
      ]
    end
  end
end
