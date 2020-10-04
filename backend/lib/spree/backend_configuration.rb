# frozen_string_literal: true

require 'spree/preferences/configuration'

module Spree
  class BackendConfiguration < Preferences::Configuration
    preference :locale, :string, default: I18n.default_locale

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

    # An item which should be drawn in the admin menu
    class MenuItem
      attr_reader :icon, :label, :partial, :condition, :sections, :url, :match_path

      attr_accessor :position

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
      # @param position [Integer] The position in which the menu item should render
      #   nil will cause the item to render last
      # @param match_path [String, Regexp] (nil) If the {url} to determine the active tab is ambigous
      #   you can pass a String or Regexp to identify this menu item
      def initialize(
        sections,
        icon,
        condition: nil,
        label: nil,
        partial: nil,
        url: nil,
        position: nil,
        match_path: nil
      )

        @condition = condition || -> { true }
        @sections = sections
        @icon = icon
        @label = label || sections.first
        @partial = partial
        @url = url
        @position = position
        @match_path = match_path
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
          ORDER_TABS,
          'shopping-cart',
          condition: -> { can?(:admin, Spree::Order) },
          position: 0
        ),
        MenuItem.new(
          PRODUCT_TABS,
          'th-large',
          condition: -> { can?(:admin, Spree::Product) },
          partial: 'spree/admin/shared/product_sub_menu',
          position: 1
        ),
        MenuItem.new(
          PROMOTION_TABS,
          'bullhorn',
          partial: 'spree/admin/shared/promotion_sub_menu',
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path,
          position: 2
        ),
        MenuItem.new(
          STOCK_TABS,
          'cubes',
          condition: -> { can?(:admin, Spree::StockItem) },
          label: :stock,
          url: :admin_stock_items_path,
          match_path: '/stock_items',
          position: 3
        ),
        MenuItem.new(
          USER_TABS,
          'user',
          condition: -> { Spree.user_class && can?(:admin, Spree.user_class) },
          url: :admin_users_path,
          position: 4
        ),
        MenuItem.new(
          CONFIGURATION_TABS,
          'wrench',
          condition: -> { can?(:admin, Spree::Store) },
          label: :settings,
          partial: 'spree/admin/shared/settings_sub_menu',
          url: :admin_stores_path,
          position: 5
        )
      ]
    end
  end
end
