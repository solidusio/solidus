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

  context 'as Guest User' do
    context 'for Order' do
      context 'guest_token is empty string' do
        let(:ability) { Spree::Ability.new(nil) }
        let(:resource) { build(:order) }
        let(:token) { '' }

        it 'should not be allowed to read or update the order' do
          allow(resource).to receive_messages(guest_token: '')

          expect(ability).to_not be_able_to(:show, resource, token)
          expect(ability).to_not be_able_to(:show, resource, token)
        end
      end
    end
  end
end
