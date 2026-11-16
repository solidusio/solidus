# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::PreferenceFields::Select::Component, type: :component do
  it "renders the overview preview" do
    render_preview(:overview)
  end

  context "when the options have no translations" do
    before do
      stub_const("UntranslatedPaymentMethod", Class.new(Spree::PaymentMethod) {
        preference :speed, :select, options: [:fast, :slow]
      })
    end

    it "falls back to the option itself for the label" do
      render_inline described_class.new(
        type: "UntranslatedPaymentMethod",
        preference_name: :speed,
        name: "payment_method[preferred_speed]"
      )

      expect(page).to have_css("option[value='fast']", exact_text: "fast")
      expect(page).to have_css("option[value='slow']", exact_text: "slow")
    end
  end
end
