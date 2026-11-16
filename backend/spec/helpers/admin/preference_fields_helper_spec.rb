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
  end
end
