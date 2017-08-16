# frozen_string_literal: true

module Spree
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: Rails.application.config.i18n.default_locale

    ORDER_TABS         ||= [:orders, :payments, :creditcard_payments,
                            :shipments, :credit_cards, :return_authorizations,
                            :customer_returns, :adjustments, :customer_details]
    PRODUCT_TABS       ||= [:products, :option_types, :properties,
                            :variants, :product_properties, :taxonomies,
                            :taxons]
    REPORT_TABS        ||= [:reports]
    CONFIGURATION_TABS ||= [:stores, :tax_categories,
                            :tax_rates, :zones,
                            :payment_methods, :shipping_methods,
                            :shipping_categories, :stock_locations,
                            :refund_reasons, :reimbursement_types, :return_authorization_reasons]
    PROMOTION_TABS     ||= [:promotions, :promotion_categories]
    STOCK_TABS         ||= [:stock_items]
    USER_TABS          ||= [:users, :store_credits]

    # Items can be added to the menu by using code like the following:
    #
    # Spree::Backend::Config.configure do |config|
    #   config.menu_items << config.class::MenuItem.new(
    #     [:section],
    #     'icon-name',
    #     url: 'https://solidus.io/'
    #   )
    # end
    #
    # @!attribute menu_items
    #   @return [Array<Spree::MenuItem>]
    attr_writer :menu_items

    # Return the menu items which should be drawn in the menu
    #
    # @api public
    # @return [Array<Spree::MenuItem>]
    def menu_items
      @menu_items ||= [
        Spree::MenuItem.new(
          ORDER_TABS,
          'shopping-cart',
          condition: -> { can?(:admin, Spree::Order) },
        ),
        Spree::MenuItem.new(
          PRODUCT_TABS,
          'th-large',
          condition: -> { can?(:admin, Spree::Product) },
          partial: 'spree/admin/shared/product_sub_menu'
        ),
        Spree::MenuItem.new(
          REPORT_TABS,
          'file',
          condition: -> { can?(:admin, :reports) },
        ),
        Spree::MenuItem.new(
          CONFIGURATION_TABS,
          'wrench',
          condition: -> { can?(:admin, Spree::Store) },
          label: :settings,
          partial: 'spree/admin/shared/settings_sub_menu',
          url: :admin_stores_path
        ),
        Spree::MenuItem.new(
          PROMOTION_TABS,
          'bullhorn',
          partial: 'spree/admin/shared/promotion_sub_menu',
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path
        ),
        Spree::MenuItem.new(
          STOCK_TABS,
          'cubes',
          condition: -> { can?(:admin, Spree::StockItem) },
          label: :stock,
          url: :admin_stock_items_path
        ),
        Spree::MenuItem.new(
          USER_TABS,
          'user',
          condition: -> { Spree.user_class && can?(:admin, Spree.user_class) },
          url: :admin_users_path
        )
      ]
    end
  end
end
