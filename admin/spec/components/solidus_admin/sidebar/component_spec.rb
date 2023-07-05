# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Component, type: :component do
  it "renders the solidus logo" do
    component = described_class.new(
      store: build(:store),
      items: []
    )

    render_inline(component)

    expect(page).to have_css("img[src*='solidus_admin/solidus_logo']")
  end

  it "renders the store link" do
    component = described_class.new(
      store: build(:store, url: "https://example.com"),
      items: []
    )

    render_inline(component)

    expect(page).to have_content("https://example.com")
  end

  it "renders the main navigation" do
    component = described_class.new(
      store: build(:store),
      items: []
    )

    render_inline(component)

    expect(page).to have_css("nav[data-controller='main-nav']")
  end
end
