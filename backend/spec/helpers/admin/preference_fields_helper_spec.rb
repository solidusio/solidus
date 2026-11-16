# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::Admin::PreferenceFieldsHelper, type: :helper do
  describe "#preference_field_for" do
    subject { helper.preference_field_for(form, name) }

    let(:form) { double(object:, check_box: "[CHECKBOX INPUT]") }
    let(:name) { :test_mode }
    let(:object) { create :payment_method }

    it "calls render with the correct preference field view partial" do
      expect(subject.strip).to eq <<~HTML.strip
        <div class="field">
          <label>
              [CHECKBOX INPUT]
            Test Mode
          </label>
        </div>
      HTML
    end

    context "with a select preference whose options have no translations" do
      subject do
        helper.form_for(object, as: :calculator, url: "/") do |form|
          concat helper.preference_field_for(form, :speed)
        end
      end

      let(:object) { calculator_class.new }
      let(:calculator_class) do
        Class.new(Spree::Calculator) do
          preference :speed, :select, options: [:fast, :slow]
        end
      end

      before { stub_const("UntranslatedCalculator", calculator_class) }

      it "falls back to the option itself for the label" do
        expect(subject).to have_css("option[value='fast']", exact_text: "fast")
        expect(subject).to have_css("option[value='slow']", exact_text: "slow")
      end
    end
  end
end
