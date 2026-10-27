# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Address::Fields::CountryAndState::Component, type: :component do
  it "gives the Stimulus controller the states URL from the engine's routes" do
    render_inline(described_class.new(addressable: Spree::Address.new, form_field_name: "address"))

    controller = page.find("[data-controller='#{described_class.stimulus_id}']", visible: :all)

    expect(controller["data-#{described_class.stimulus_id}-url-value"]).to eq("/admin/countries/:country_id/states")
  end
end
