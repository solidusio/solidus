# frozen_string_literal: true

require "solidus_admin/container"
require "solidus_admin/main_nav_item"

module SolidusAdmin
  module Providers
    Container.register_provider("main_nav") do
      start do
        container.namespace("main_nav") do
          register("orders", MainNavItem.new(key: "orders", route: :orders_path, icon: "solidus_admin/inbox-line.svg", position: 10))
          register(
            "products",
            MainNavItem.new(
              key: "products",
              route: :products_path,
              icon: "solidus_admin/price-tag-3-line.svg",
              position: 20
            )
              .with_child(key: "option_types", route: :option_types_path, position: 10)
          )
          register("promotions", MainNavItem.new(key: "promotions", route: :promotions_path, icon: "solidus_admin/megaphone-line.svg", position: 30))
          register("stock", MainNavItem.new(key: "stock", route: :stock_items_path, icon: "solidus_admin/stack-line.svg", position: 40))
          register("users", MainNavItem.new(key: "users", route: :users_path, icon: "solidus_admin/user-line.svg", position: 50))
          register("settings", MainNavItem.new(key: "settings", route: :stores_path, icon: "solidus_admin/settings-line.svg", position: 60))
        end

        container.register("main_nav_items") do
          Container.within_namespace("main_nav")
        end
      end
    end
  end
end
