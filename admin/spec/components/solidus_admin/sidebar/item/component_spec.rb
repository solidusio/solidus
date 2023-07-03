# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Item::Component, type: :component do
  def url_helpers(routes)
    Module.new.tap do
      _1.module_eval do
        routes.each do |name, path|
          define_singleton_method("#{name}_path") { path }
        end
      end
    end
  end

  it "renders the item" do
    item = SolidusAdmin::MainNavItem.new(key: "orders", route: :orders_path, position: 1)
    component = described_class.new(
      item: item,
      url_helpers: url_helpers(orders: "/admin/orders")
    )

    render_inline(component)

    expect(page).to have_content("Orders")
  end

  it "renders nested items" do
    item = SolidusAdmin::MainNavItem
           .new(key: "products", route: :products_path, position: 1)
           .with_child(key: "option_types", route: :option_types_path, position: 1)
    component = described_class.new(
      item: item,
      url_helpers: url_helpers(products: "/admin/products", option_types: "/admin/option_types")
    )

    render_inline(component)

    expect(page).to have_content("Options")
  end

  it "syles top level items differently from nested items" do
    item = SolidusAdmin::MainNavItem
           .new(key: "products", route: :products_path, position: 1)
           .with_child(key: "option_types", route: :option_types_path, position: 1)
    component = described_class.new(
      item: item,
      url_helpers: url_helpers(products: "/admin/products", option_types: "/admin/option_types")
    )

    render_inline(component)

    expect(
      page.find("a", text: "Products")[:class]
    ).not_to eq(
      page.find("a", text: "Options")[:class]
    )
  end
end
