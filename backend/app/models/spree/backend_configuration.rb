module Spree
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: Rails.application.config.i18n.default_locale

    ORDER_TABS         ||= [:orders, :payments, :creditcard_payments,
                            :shipments, :credit_cards, :return_authorizations,
                            :customer_returns, :adjustments, :customer_details]
    PRODUCT_TABS       ||= [:products, :option_types, :properties, :prototypes,
                            :variants, :product_properties, :taxonomies,
                            :taxons]
    REPORT_TABS        ||= [:reports]
    CONFIGURATION_TABS ||= [:configurations, :general_settings, :tax_categories,
                            :tax_rates, :zones, :countries, :states,
                            :payment_methods, :shipping_methods,
                            :shipping_categories, :stock_locations, :trackers,
                            :refund_reasons, :reimbursement_types, :return_authorization_reasons]
    PROMOTION_TABS     ||= [:promotions, :promotion_categories]
    STOCK_TABS         ||= [:stock_items, :stock_transfers]
    USER_TABS          ||= [:users, :store_credits]

    # An item which should be drawn in the admin menu
    class MenuItem
      attr_reader :icon, :label, :partial, :condition, :sections, :url

      # @param sections [Array<Symbol>] The sections which are contained within
      #   this admin menu section.
      # @param icon [String] The icon to draw for this menu item
      # @param condition [Proc] A proc which returns true if this menu item
      #   should be drawn. If nil, it will be replaced with a proc which always
      #   returns true.
      # @param label [Symbol] The translation key for a label to use for this
      #   menu item.
      # @param partial [String] A partial to draw within this menu item for use
      #   in declaring a submenu
      # @param url [String] A url where this link should send the user to
      def initialize(
        sections,
        icon,
        condition: nil,
        label: nil,
        partial: nil,
        url: nil
      )

        @condition = condition || -> { true }
        @sections = sections
        @icon = icon
        @label = label || sections.first
        @partial = partial
        @url = url
      end
    end

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
    #   @return [Array<Spree::BackendConfiguration::MenuItem>]
    attr_writer :menu_items

    # Return the menu items which should be drawn in the menu
    #
    # @api public
    # @return [Array<Spree::BackendConfiguration::MenuItem>]
    def menu_items
      @menu_items ||= [
        MenuItem.new(
          ORDER_TABS,
          'shopping-cart',
          condition: -> { can?(:admin, Spree::Order) },
        ),
        MenuItem.new(
          PRODUCT_TABS,
          'th-large',
          condition: -> { can?(:admin, Spree::Product) },
          partial: 'spree/admin/shared/product_sub_menu'
        ),
        MenuItem.new(
          REPORT_TABS,
          'file',
          condition: -> { can?(:admin, :reports) },
        ),
        MenuItem.new(
          CONFIGURATION_TABS,
          'wrench',
          condition: -> { can?(:admin, :general_settings) },
          label: :settings,
          partial: 'spree/admin/shared/settings_sub_menu',
          url: :edit_admin_general_settings_path
        ),
        MenuItem.new(
          PROMOTION_TABS,
          'bullhorn',
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path
        ),
        MenuItem.new(
          STOCK_TABS,
          'cubes',
          condition: -> { can?(:admin, Spree::StockItem) },
          label: :stock,
          partial: 'spree/admin/shared/stock_sub_menu',
          url: :admin_stock_items_path
        ),
        MenuItem.new(
          USER_TABS,
          'user',
          condition: -> { Spree.user_class && can?(:admin, Spree.user_class) },
          url: :admin_users_path
        )
      ]
    end
  end
end
