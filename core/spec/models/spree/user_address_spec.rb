# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UserAddress, type: :model do
  context "::default" do
    let(:deprecation_message) do
      "This scope is deprecated. Please start using ::default_shipping."
    end

    it "calls ::default_shipping and warns caller of deprecation" do
      expect(described_class).to receive(:default_shipping)
      expect(Spree::Deprecation).to receive(:warn).with deprecation_message

      described_class.default
    end
  end
end
