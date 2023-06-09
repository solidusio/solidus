# frozen_string_literal: true

require "solidus_admin/container"
require "solidus_admin/main_nav_item"

module SolidusAdmin
  module Providers
    Container.register_provider("main_nav") do
      start do
        container.namespace("main_nav") do
          register("first_item", MainNavItem.new(title: "First item", position: "10"))
          register("second_item", MainNavItem.new(title: "Second item", position: "20"))
          register("third_item", MainNavItem.new(title: "Third item", position: "30"))
        end

        container.register("main_nav_items") do
          Container.within_namespace("main_nav")
        end
      end
    end
  end
end
