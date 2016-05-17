require 'spec_helper'

describe Spree::Promotion::Rules::UserRole, type: :model do
  let(:rule) { Spree::Promotion::Rules::UserRole.new }
  let(:special_role) { create(:role, name: :special) }
  let(:roles) { create_list(:role, 3) }
  let(:user) { create(:user, spree_roles: [special_role]) }

  context '#eligible?(order)' do
    let(:order) { Spree::Order.new }

    it 'should not be eligible if order don\'t have a user' do
      allow(rule).to receive_messages(roles: roles.append(special_role))

      expect(rule).not_to be_eligible(order)
    end

    it 'should not be eligible if roles are not provided' do
      allow(rule).to receive_messages(roles: [])
      allow(order).to receive_messages(user: user)

      expect(rule).not_to be_eligible(order)
    end

    it 'should be eligible if roles include almost one role of user placing the order' do
      allow(rule).to receive_messages(roles: roles.append(special_role))
      allow(order).to receive_messages(user: user)

      expect(rule).to be_eligible(order)
    end

    it 'should not be eligible if user placing the order not have almost one listed role' do
      allow(rule).to receive_messages(roles: roles)
      allow(order).to receive_messages(user: user)

      expect(rule).to_not be_eligible(order)
    end
  end
end
