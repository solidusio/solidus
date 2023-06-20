# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Sidebar::Component, type: :component do
  it "renders the solidus logo" do
    render_inline(described_class.new)

    expect(page).to have_css("img[src*='solidus_admin/solidus_logo']")
  end

  it "renders the main navigation" do
    render_inline(described_class.new)

    render_inline(described_class.new)

    expect(page).to have_css("nav[data-controller='main-nav']")
  end
end
