# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Address::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  context "with include_name_field: false" do
    it "does not render name field" do
      component = described_class.new(
        fieldset_name: "",
        addressable: Spree::Address.new(country: Spree::Country.find_or_initialize_by(iso: "US")),
        include_name_field: false
      )

      render_inline(component)
      expect(page).not_to have_content("Name")
    end
  end
end
