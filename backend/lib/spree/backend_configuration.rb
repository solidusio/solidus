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
    versioned_preference :theme, :string, initial_value: 'classic', boundaries: { "4.1.0.a" => "solidus_admin" }

    def theme_path(user_theme = nil)
      user_theme ? themes.fetch(user_theme.to_sym) : themes.fetch(theme.to_sym)
    end

    preference :frontend_product_path,
      :proc,
      default: proc {
        ->(template_context, product) {
          return unless template_context.spree.respond_to?(:product_path)

          template_context.spree.product_path(product)
        }
      }

    ORDER_TABS         ||= [:orders, :payments, :creditcard_payments,
                            :shipments, :credit_cards, :return_authorizations,
                            :customer_returns, :adjustments, :customer_details]
    PRODUCT_TABS       ||= [:products, :option_types, :properties,
                            :variants, :product_properties, :taxonomies,
                            :taxons]
    CONFIGURATION_TABS ||= [:stores, :tax_categories,
                            :tax_rates, :zones,
                            :payment_methods, :shipping_methods,
                            :shipping_categories, :stock_locations,
                            :refund_reasons, :reimbursement_types,
                            :return_reasons, :adjustment_reasons,
                            :store_credit_reasons]
    PROMOTION_TABS     ||= [:promotions, :promotion_categories]
    STOCK_TABS         ||= [:stock_items]
    USER_TABS          ||= [:users, :store_credits]

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
    #
    # Positioning can be determined by setting the position attribute to
    # an Integer or nil. Menu Items will be rendered with smaller lower values
    # first and higher values last. A position value of nil will cause the menu
    # item to be rendered at the end of the list.
    attr_writer :menu_items

    # Return the menu items which should be drawn in the menu
    #
    # @api public
    # @return [Array<Spree::BackendConfiguration::MenuItem>]
    def menu_items
      @menu_items ||= [
        MenuItem.new(
          label: :orders,
          icon: 'shopping-cart',
          condition: -> { can?(:admin, Spree::Order) },
          match_path: %r{/(#{ORDER_TABS.join('|')})},
          position: 0
        ),
        MenuItem.new(
          label: :products,
          icon: 'th-large',
          condition: -> { can?(:admin, Spree::Product) },
          match_path: %r{/(#{PRODUCT_TABS.join('|')})},
          partial: 'spree/admin/shared/product_sub_menu',
          position: 1
        ),
        MenuItem.new(
          label: :promotions,
          icon: 'bullhorn',
          match_path: %r{/(#{PROMOTION_TABS.join('|')})},
          partial: 'spree/admin/shared/promotion_sub_menu',
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path,
          position: 2
        ),
        MenuItem.new(
          label: :stock,
          icon: 'cubes',
          match_path: %r{/(#{STOCK_TABS.join('|')})},
          condition: -> { can?(:admin, Spree::StockItem) },
          url: :admin_stock_items_path,
          position: 3
        ),
        MenuItem.new(
          label: :users,
          icon: 'user',
          match_path: %r{/(#{USER_TABS.join('|')})},
          condition: -> { Spree.user_class && can?(:admin, Spree.user_class) },
          url: :admin_users_path,
          position: 4
        ),
        MenuItem.new(
          label: :settings,
          icon: 'wrench',
          match_path: %r{/(#{CONFIGURATION_TABS.join('|')})},
          condition: -> {
            can?(:admin, Spree::Store) ||
            can?(:admin, Spree::AdjustmentReason) ||
            can?(:admin, Spree::PaymentMethod) ||
            can?(:admin, Spree::RefundReason) ||
            can?(:admin, Spree::ReimbursementType) ||
            can?(:admin, Spree::ShippingCategory) ||
            can?(:admin, Spree::ShippingMethod) ||
            can?(:admin, Spree::StockLocation) ||
            can?(:admin, Spree::TaxCategory) ||
            can?(:admin, Spree::TaxRate) ||
            can?(:admin, Spree::ReturnReason) ||
            can?(:admin, Spree::Zone)
          },
          partial: 'spree/admin/shared/settings_sub_menu',
          url: :admin_stores_path,
          position: 5
        )
      ]
    end
  end
end
