# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Item::Component, type: :component do
  def url_helpers(solidus_admin: {}, spree: {})
    double(
      solidus_admin: double(**solidus_admin),
      spree: double(**spree)
    )
  end

  it "renders the overview preview" do
    render_preview(:overview)
  end

  it "renders the item" do
    item = SolidusAdmin::MainNavItem.new(key: "orders", route: :orders_path, position: 1)
    component = described_class.new(
      item: item,
      url_helpers: url_helpers(solidus_admin: { orders_path: "/admin/foo" })
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
      url_helpers: url_helpers(solidus_admin: { products_path: "/admin/products", option_types_path: "/admin/option_types" })
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
      url_helpers: url_helpers(solidus_admin: { products_path: "/admin/products", option_types_path: "/admin/option_types" })
    )

    render_inline(component)

    expect(
      page.find("a", text: "Products")[:class]
    ).not_to eq(
      page.find("a", text: "Options")[:class]
    )
  end

  it "syles active items differently from the others" do
    inactive_item = SolidusAdmin::MainNavItem
                    .new(key: "orders", route: :orders_path, position: 1)
    active_item = SolidusAdmin::MainNavItem
                  .new(key: "products", route: :products_path, position: 1)
    inactive_component = described_class.new(
      item: inactive_item,
      url_helpers: url_helpers(solidus_admin: { orders_path: "/admin/orders" }),
      fullpath: "/admin/products"
    )
    active_component = described_class.new(
      item: active_item,
      url_helpers: url_helpers(solidus_admin: { products_path: "/admin/products" }),
      fullpath: "/admin/products"
    )

    render_inline(inactive_component)
    inactive_classes = page.find("a", text: "Orders")[:class]
    render_inline(active_component)
    active_classes = page.find("a", text: "Products")[:class]

    expect(inactive_classes).not_to eq(active_classes)
  end
end
