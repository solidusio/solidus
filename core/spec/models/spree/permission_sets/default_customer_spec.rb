# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/dummy_ability'

RSpec.describe Spree::PermissionSets::DefaultCustomer do
  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:other)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:default_customer)
    end
  end
end
