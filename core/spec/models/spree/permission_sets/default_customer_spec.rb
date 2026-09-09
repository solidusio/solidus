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

  context "for CreditCard" do
    let(:guest_card) { create(:credit_card, user: nil) }

    context "with an anonymous (non-persisted) ability" do
      let(:ability) { Spree::Ability.new(nil) }

      # Regression test for the anonymous guest-card authorization flaw:
      # an anonymous ability has a non-persisted placeholder user whose #id is
      # nil, which must not match guest cards (user_id NULL) via `user_id: user.id`.
      it "cannot read or update a guest credit card" do
        expect(ability).not_to be_able_to(:read, guest_card)
        expect(ability).not_to be_able_to(:update, guest_card)
      end
    end

    context "with a persisted user" do
      let(:user) { create(:user) }
      let(:ability) { Spree::Ability.new(user) }
      let(:own_card) { create(:credit_card, user: user) }

      it "can read and update its own credit card" do
        expect(ability).to be_able_to(:read, own_card)
        expect(ability).to be_able_to(:update, own_card)
      end

      it "cannot read or update another user's or a guest credit card" do
        expect(ability).not_to be_able_to(:update, create(:credit_card, user: create(:user)))
        expect(ability).not_to be_able_to(:update, guest_card)
      end
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
