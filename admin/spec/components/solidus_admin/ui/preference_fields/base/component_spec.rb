# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::PreferenceFields::Base::Component, type: :component do
  shared_context "with translation stubs" do
    before do
      allow(I18n).to receive(:t).and_call_original

      i18n_stubs.each do |key, value|
        allow(I18n).to receive(:t).with(key.to_s, default: nil).and_return(value)
      end
    end
  end

  let(:component) { test_subclass.new(**component_args) }
  let(:component_args) {
    {
      form: double,
      type: "Spree::PaymentMethod::BogusCreditCard",
      preference_name: :bogus_name
    }
  }
  let(:test_subclass) {
    Class.new(described_class) do
      def component_input_attributes = {type: :text}
    end
  }

  before do
    # Because testing against the base class can raise +NotImplementError+s
    # and Standard does not like it when we create arbitrary constants within
    # test files, we can create an anonymous class and ensure it has a class
    # name so that Active Support class methods like +.name+ and +.demodulize+
    # continue to work.
    allow(test_subclass).to receive(:name).and_return("NotARealAnonymousClass")
  end

  describe "#call" do
    before do
      allow(SolidusAdmin::UI::Forms::Field::Component)
        .to receive(:new)
        .and_call_original
    end

    context "when there is a translated value for the preference field name" do
      let(:component_args) {
        {
          form: double,
          type: "Spree::PaymentMethod::BogusCreditCard",
          preference_name: :bogus_boolean
        }
      }

      it "renders the translated label string when delegating to the field component" do
        render_inline(component)

        expect(SolidusAdmin::UI::Forms::Field::Component)
          .to have_received(:new)
          .with(label: "Bogus Boolean Preference",
            hint: "Hint for no-op bogus boolean preference.",
            input_attributes: {error: nil, type: :text})
      end
    end

    context "when there is both an HTML and a non-HTML translation for the preference field" do
      include_context "with translation stubs" do
        let(:i18n_stubs) {
          {
            "spree.hints.spree/payment_method/bogus_credit_card.preferred_bogus_name_html": "<p>HTML STRING</p>",
            "spree.hints.spree/payment_method/bogus_credit_card.preferred_bogus_name": "TEXT STRING"
          }
        }
      end

      it "renders the HTML hint translation when delegating to the field component" do
        render_inline(component)

        expect(SolidusAdmin::UI::Forms::Field::Component)
          .to have_received(:new)
          .with(label: "Preferred bogus name",
            hint: "<p>HTML STRING</p>",
            input_attributes: {error: nil, type: :text})
      end
    end

    context "when there is a translation for the preference field" do
      include_context "with translation stubs" do
        let(:i18n_stubs) {
          {"spree.hints.spree/payment_method/bogus_credit_card.preferred_bogus_name": "TEXT STRING"}
        }
      end

      it "renders the hint translation when delegating to the field component" do
        render_inline(component)

        expect(SolidusAdmin::UI::Forms::Field::Component)
          .to have_received(:new)
          .with(label: "Preferred bogus name",
            hint: "TEXT STRING",
            input_attributes: {error: nil, type: :text})
      end
    end

    context "when there is a translation for the preference field on the current class and a base class" do
      include_context "with translation stubs" do
        let(:i18n_stubs) {
          {
            "spree.hints.spree/payment_method/bogus_credit_card.preferred_bogus_name": "SUBCLASS STRING",
            "spree.hints.spree/payment_method.preferred_bogus_name": "BASE CLASS STRING"
          }
        }
      end

      it "renders the subclass translation when delegating to the field component" do
        render_inline(component)

        expect(SolidusAdmin::UI::Forms::Field::Component)
          .to have_received(:new)
          .with(label: "Preferred bogus name",
            hint: "SUBCLASS STRING",
            input_attributes: {error: nil, type: :text})
      end
    end

    context "when there is only a translation for the preference field on a base class" do
      include_context "with translation stubs" do
        let(:i18n_stubs) {
          {"spree.hints.spree/payment_method.preferred_bogus_name": "BASE CLASS STRING"}
        }
      end

      before do
        allow(I18n)
          .to receive(:t)
          .with(
            "spree.hints.spree/payment_method.preferred_bogus_name",
            default: nil
          )
          .and_return("BASE CLASS STRING")
      end

      it "renders the hint translation when delegating to the field component" do
        render_inline(component)

        expect(SolidusAdmin::UI::Forms::Field::Component)
          .to have_received(:new)
          .with(label: "Preferred bogus name",
            hint: "BASE CLASS STRING",
            input_attributes: {error: nil, type: :text})
      end
    end

    context "when there is no translation for the preference field" do
      it "renders a nil hint" do
        render_inline(component)

        expect(SolidusAdmin::UI::Forms::Field::Component)
          .to have_received(:new)
          .with(label: "Preferred bogus name",
            hint: nil,
            input_attributes: {error: nil, type: :text})
      end
    end
  end
end
