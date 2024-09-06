# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/dummy_ability'

RSpec.describe Spree::PermissionSets::SuperUser do
  let(:ability) { DummyAbility.new }

  subject { described_class.new(ability) }

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:other)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:super_user)
    end
  end
end
