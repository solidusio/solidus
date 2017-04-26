module Spree
  module Backend
    class Engine < ::Rails::Engine
      config.middleware.use "Spree::Backend::Middleware::SeoAssist"

      initializer "spree.backend.environment", before: :load_config_initializers do |_app|
        Spree::Backend::Config = Spree::BackendConfiguration.new
      end

      initializer "spree.backend.menu", before: :load_config_initializers do |_app|
        menu = Spree::Backend::Config.menu

        menu.add_section(
          'orders',
          icon: 'shopping-cart',
        )
        menu.add_item(
          'orders/orders',
          url: :admin_orders_path,
          condition: -> { can?(:admin, Spree::Order) },
        )

        menu.add_section(
          'products',
          icon: 'th-large',
        )
        menu.add_item(
          'products/products',
          url: :admin_products_path,
          condition: -> { can?(:admin, Spree::Product) }
        )
        menu.add_item(
          'products/option_types',
          url: :admin_option_types_path,
          condition: -> { can?(:admin, Spree::OptionType) }
        )
        menu.add_item(
          'products/properties',
          url: :admin_properties_path,
          condition: -> { can?(:admin, Spree::Property) }
        )
        menu.add_item(
          'products/taxonomies',
          condition: -> { can?(:admin, Spree::Taxonomy) }
        )
        menu.add_item(
          'products/taxons',
          condition: -> { can?(:admin, Spree::Taxon) },
          label: :display_order
        )

        menu.add_section(
          :reports,
          icon: 'file'
        )
        menu.add_item(
          'reports/reports',
          condition: -> { can?(:admin, :reports) },
        )

        menu.add_section(
          'settings',
          icon: 'wrench'
        )

        menu.add_item(
          'settings/stores',
          label: :stores,
          url: :admin_stores_path,
          condition: -> { can?(:admin, Spree::Store) },
        )

        menu.add_item(
          'settings/payments',
          url: :admin_payment_methods_path,
          condition: -> { can?(:display, Spree::PaymentMethod) }
        )

        menu.add_item(
          'settings/areas',
          url: :admin_zones_path,
          condition: -> { can?(:display, Spree::Zone) || can?(:display, Spree::Country) || can?(:display, Spree::State) }
        )

        menu.add_item(
          'settings/taxes',
          url: :admin_tax_categories_path,
          condition: -> { can?(:display, Spree::TaxCategory) || can?(:display, Spree::TaxRate) }
        )

        menu.add_item(
          'settings/checkout',
          url: :admin_refund_reasons_path,
          condition: -> { can?(:display, Spree::RefundReason) || can?(:display, Spree::ReimbursementType) || can?(:display, Spree::ReturnReason) || can?(:display, Spree::AdjustmentReason) }
        )

        menu.add_item(
          'settings/shipping',
          url: :admin_shipping_methods_path,
          condition: -> { can?(:display, Spree::ShippingMethod) || can?(:display, Spree::ShippingCategory) || can?(:display, Spree::StockLocation) }
        )

        menu.add_section(
          'promotions',
          icon: 'bullhorn',
        )
        menu.add_item(
          'promotions/promotions',
          condition: -> { can?(:admin, Spree::Promotion) },
          url: :admin_promotions_path
        )
        menu.add_item(
          'promotions/promotion_categories',
          url: :admin_promotion_categories_path
        )

        menu.add_section(
          'stock',
          icon: 'cubes'
        )

        menu.add_item(
          'stock/stock',
          condition: -> { can?(:admin, Spree::StockItem) },
          label: :stock,
          url: :admin_stock_items_path
        )

        menu.add_item(
          'stock/stock_transfers',
          url: :admin_stock_transfers_path
        )

        menu.add_section(
          :users,
          icon: 'user'
        )
        menu.add_item(
          'users/users',
          condition: -> { Spree.user_class && can?(:admin, Spree.user_class) },
          url: :admin_users_path
        )
      end
    end
  end
end
