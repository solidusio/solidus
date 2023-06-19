# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::SolidusLogo::Component, type: :component do
  it "renders the solidus logo" do
    render_inline(described_class.new)

    expect(page).to have_css("img[src*='solidus_admin/solidus_logo']")
  end
end
