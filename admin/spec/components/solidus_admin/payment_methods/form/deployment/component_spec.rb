# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::PaymentMethods::Form::Deployment::Component, type: :component do
  let(:component) { described_class.new(form:) }

  let(:form) {
    ActionView::Helpers::FormBuilder.new :object,
      form_object,
      self,
      {}
  }
  let(:form_object) { Spree::PaymentMethod::BogusCreditCard.new }

  before do
    component.instance_variable_set :@type, form_object.class.to_s
  end

  describe "#f" do
    subject { component.f }

    it { is_expected.to eq form }
  end

  describe "#available_preference_sources" do
    subject { component.available_preference_sources }

    before do
      allow(Spree::PaymentMethod::BogusCreditCard)
        .to receive(:available_preference_sources)
        .and_return(["fake_static_preference_source_1"])
    end

    it { is_expected.to eq ["fake_static_preference_source_1"] }
  end

  describe "#available_type_select_options" do
    subject { component.available_type_select_options }

    it "returns all registered payment methods as select option form parameters" do
      expect(subject).to contain_exactly(
        ["Bogus Credit Card Payments", "Spree::PaymentMethod::BogusCreditCard"],
        ["Check Payments", "Spree::PaymentMethod::Check"],
        ["Simple Bogus Credit Card Payments", "Spree::PaymentMethod::SimpleBogusCreditCard"],
        ["Store Credit Payments", "Spree::PaymentMethod::StoreCredit"]
      )
    end
  end

  describe "#current_type_instance" do
    subject { component.current_type_instance }

    it { is_expected.to be_an_instance_of Spree::PaymentMethod::BogusCreditCard }
  end

  describe "#field_for" do
    subject { component.field_for(*args) }

    context "when the field is of boolean type" do
      let(:args) { [:bogus_boolean, false] }

      it "uses the given boolean value and delegates to the requested preference field component" do
        allow(SolidusAdmin::UI::PreferenceFields::Boolean::Component)
          .to receive(:new)

        subject

        expect(SolidusAdmin::UI::PreferenceFields::Boolean::Component)
          .to have_received(:new)
          .with(disabled: false,
            form:,
            type: "Spree::PaymentMethod::BogusCreditCard",
            name: "payment_method[preferred_bogus_boolean]",
            preference_name: :bogus_boolean,
            value: "false")
      end
    end

    context "when the field is not of boolean type" do
      let(:args) { [:bogus_string, "given-value"] }

      it "uses the given value and delegates to the requested preference field component" do
        allow(SolidusAdmin::UI::PreferenceFields::String::Component)
          .to receive(:new)

        subject

        expect(SolidusAdmin::UI::PreferenceFields::String::Component)
          .to have_received(:new)
          .with(disabled: false,
            form:,
            type: "Spree::PaymentMethod::BogusCreditCard",
            name: "payment_method[preferred_bogus_string]",
            preference_name: :bogus_string,
            value: "given-value")
      end
    end

    context "when the field has no current value" do
      let(:args) { [:bogus_string, nil] }

      it "uses the default preference value and delegates to the requested preference field component" do
        allow(SolidusAdmin::UI::PreferenceFields::String::Component)
          .to receive(:new)

        subject

        expect(SolidusAdmin::UI::PreferenceFields::String::Component)
          .to have_received(:new)
          .with(disabled: false,
            form:,
            type: "Spree::PaymentMethod::BogusCreditCard",
            name: "payment_method[preferred_bogus_string]",
            preference_name: :bogus_string,
            value: "string-value")
      end
    end
  end

  describe "#static_preference_source?" do
    subject { component.static_preference_source? }

    before do
      allow(Spree::PaymentMethod::BogusCreditCard)
        .to receive(:available_preference_sources)
        .and_return(["fake_static_preference_source_1"])
    end

    context "when a preference source has been set before render" do
      before do
        component.instance_variable_set(
          :@preference_source,
          "fake_static_preference_source_1"
        )
      end

      it { is_expected.to eq true }
    end

    context "when no preference source has been set" do
      it { is_expected.to eq false }
    end
  end

  describe "#selected_preference_source_settings" do
    subject { component.selected_preference_source_settings }

    before do
      allow(Spree::PaymentMethod::BogusCreditCard)
        .to receive(:available_preference_sources)
        .and_return(["fake_static_preference_source_1"])
    end

    context "when no preference source is selected" do
      it { is_expected.to eq({}) }
    end

    context "when a preference source has been selected" do
      let(:fake_static_preferences) {
        instance_double Spree::Preferences::StaticModelPreferences::Definition,
          preferences: {bogus_text: "static-value"}
      }

      before do
        component.instance_variable_set(
          :@preference_source,
          "fake_static_preference_source_1"
        )

        allow(Spree::PaymentMethod::BogusCreditCard)
          .to receive(:preference_sources)
          .and_return("fake_static_preference_source_1" => fake_static_preferences)
      end

      it { is_expected.to eq({bogus_text: "static-value"}) }
    end
  end
end
