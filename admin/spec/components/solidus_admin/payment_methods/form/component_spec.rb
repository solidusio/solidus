# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::PaymentMethods::Form::Component, type: :component do
  let(:component) {
    described_class.new payment_method: create(:payment_method),
      url: "/test-url",
      form_id: "test-form-id"
  }

  describe "#auto_capture_select_options" do
    subject { component.auto_capture_select_options }

    before do
      allow(Spree::Config).to receive(:auto_capture).and_return(true)

      # The component must be rendered to provide view context for the i18n strings.
      render_inline component
    end

    it { is_expected.to contain_exactly ["Use App Default (Yes)", ""], ["Yes", true], ["No", false] }
  end

  describe "#store_select_values" do
    subject { component.store_select_values }

    let!(:store) { create :store, name: "Selectable Store" }

    it "gets all store name and IDs for a form <select>" do
      expect(subject).to eq [["Selectable Store", store.id]]
    end
  end
end
