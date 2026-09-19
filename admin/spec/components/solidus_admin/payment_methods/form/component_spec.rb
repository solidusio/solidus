# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::PaymentMethods::Form::Component, type: :component do
  let(:component) {
    described_class.new payment_method: create(:payment_method),
      url: "/test-url",
      form_id: "test-form-id"
  }

  describe "#available_preference_sources" do
    subject { component.available_preference_sources }

    it "requests available sources from Spree::PaymentMethod" do
      allow(Spree::PaymentMethod).to receive(:available_preference_sources)

      subject

      expect(Spree::PaymentMethod)
        .to have_received(:available_preference_sources)
        .once
    end
  end

  describe ".available_types" do
    subject { component.available_types }

    let(:fake_payment_methods_set) {
      Spree::Core::ClassConstantizer::Set.new(
        default: [
          "Spree::PaymentMethod::CreditCard",
          "Spree::PaymentMethod::Check"
        ]
      )
    }
    let(:fake_subconfig) { double(payment_methods: fake_payment_methods_set) }

    before do
      allow(Rails.application)
        .to receive(:config)
        .and_return(double(spree: fake_subconfig))
    end

    it "requests available payment method types from the Rails application configuration", :aggregate_failures do
      subject

      expect(Rails.application).to have_received(:config).once
      expect(fake_subconfig).to have_received(:payment_methods).once
    end

    it "sorts the available payment method types by name" do
      expect(subject).to eq [
        Spree::PaymentMethod::Check,
        Spree::PaymentMethod::CreditCard
      ]
    end
  end

  describe "#store_select_values" do
    subject { component.store_select_values }

    let!(:store) { create :store, name: "Selectable Store" }

    it "gets all store name and IDs for a form <select>" do
      expect(subject).to eq [["Selectable Store", store.id]]
    end
  end
end
