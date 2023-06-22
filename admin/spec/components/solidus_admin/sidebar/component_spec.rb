# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Component, type: :component do
  it "renders the solidus logo" do
    render_inline(described_class.new(store: build(:store)))

    expect(page).to have_css("img[src*='solidus_admin/solidus_logo']")
  end

  it "renders the store link" do
    render_inline(described_class.new(store: build(:store, url: "https://example.com")))

    expect(page).to have_content("https://example.com")
  end

  it "renders the main navigation" do
    render_inline(described_class.new(store: build(:store)))

    expect(page).to have_css("nav[data-controller='main-nav']")
  end
end
