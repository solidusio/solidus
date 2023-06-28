# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Item::Component, type: :component do
  it "renders the item" do
    item = SolidusAdmin::MainNavItem.new(key: "orders", position: 1)

    render_inline(described_class.new(item: item))

    expect(page).to have_content("Orders")
  end

  it "renders nested items" do
    item = SolidusAdmin::MainNavItem
           .new(key: "products", position: 1)
           .with_child(key: "option_types", position: 1)

    render_inline(described_class.new(item: item))

    expect(page).to have_content("Options")
  end

  it "syles top level items differently from nested items" do
    item = SolidusAdmin::MainNavItem
           .new(key: "products", position: 1)
           .with_child(key: "option_types", position: 1)

    render_inline(described_class.new(item: item))

    expect(
      page.find("a", text: "Products")[:class]
    ).not_to eq(
      page.find("a", text: "Options")[:class]
    )
  end
end
