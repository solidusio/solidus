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
      classic_dark: 'spree/backend/themes/classic_dark',
      classic_dark_dimmed: 'spree/backend/themes/classic_dimmed',
      solidus: 'spree/backend/themes/solidus_admin',
      solidus_dark: 'spree/backend/themes/solidus_admin_dark',
      solidus_dimmed: 'spree/backend/themes/solidus_admin_dimmed',
      solidus_admin: 'spree/backend/themes/solidus_admin'
    }

    preference :search_fields, :hash, default: {
      "spree/admin/orders" => [
        {
          partial: "spree/admin/shared/search_fields/date_range_picker",
          locals: {
            attribute: :created_at,
            label: -> { I18n.t(:date_range, scope: :spree) }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/select",
          locals: {
            ransack: :state_eq,
            label: -> { I18n.t(:status, scope: :spree) },
            options: -> {
              Spree::Order.state_machines[:state].states.collect { |s| [I18n.t(s.name, scope: 'spree.order_state'), s.value] }
            }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/select",
          locals: {
            ransack: :shipment_state_eq,
            label: -> { I18n.t(:shipment_state, scope: :spree) },
            options: -> {
              %i[backorder canceled partial pending ready shipped].map { |state| [I18n.t("spree.shipment_states.#{state}"), state] }
            }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/variant_autocomplete",
          locals: {
            ransack: :line_items_variant_id_in,
            label: -> { I18n.t(:variant, scope: :spree) }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/text_field",
          locals: {
            ransack: :number_start,
            label: -> { I18n.t(:order_number, scope: :spree, number: "") }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/text_field",
          locals: {
            ransack: :shipments_number_start,
            label: -> { I18n.t(:shipment_number, scope: :spree) }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/text_field",
          locals: {
            ransack: :bill_address_name_cont,
            label: -> { I18n.t(:name_contains, scope: :spree) }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/text_field",
          locals: {
            ransack: :email_start,
            label: -> { I18n.t(:email, scope: :spree) }
          }
        },
        {
          partial: "spree/admin/shared/search_fields/select",
          locals: {
            ransack: :store_id_eq,
            label: -> { I18n.t(:store, scope: :spree) },
            options: -> { Spree::Store.all.map { |store| [store.name, store.id] } },
          },
          if: -> { Spree::Store.many? }
        },
        {
          partial: "spree/admin/shared/search_fields/checkbox",
          locals: {
            ransack: :completed_at_not_null,
            label: -> { I18n.t(:show_only_complete_orders, scope: :spree) }
          }
        }
      ]
    }

    # @!attribute [rw] theme
    #   @return [String] Default admin theme name
    versioned_preference :theme, :string, initial_value: 'classic', boundaries: { "4.2.0" => "solidus_admin", "4.4.0" => "solidus" }

    # @!attribute [rw] dark_theme
    #   @return [String] Dark admin theme name
    versioned_preference :dark_theme, :string, initial_value: 'classic', boundaries: { "4.2.0" => "solidus_admin", "4.4.0" => 'solidus_dark' }

    def theme_path(user_theme)
      themes.fetch(user_theme&.to_sym, themes.fetch(theme.to_sym))
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

    # By default, this is set to +Spree::UnauthorizedRedirectHandler+. If you need your admin to behave
    # differently when a user is unauthorized, you can create your own class that respects the same interface.
    #
    # @!attribute [rw] unauthorized_redirect_handler_class
    #   @return [Class] The class that will handle unauthorized access errors.
    class_name_attribute :unauthorized_redirect_handler_class, default: "Spree::UnauthorizedRedirectHandler"

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
