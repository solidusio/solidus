# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::Orders::Show::Shipment::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  # it "renders something useful" do
  #   render_inline(described_class.new(shipment: "shipment"))
  #
  #   expect(page).to have_text "Hello, components!"
  #   expect(page).to have_css '.value'
  # end
end
