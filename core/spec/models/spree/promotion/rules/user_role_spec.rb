# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Rules::UserRole, type: :model do
  let(:rule) { described_class.new(preferred_role_ids: roles_for_rule) }
  let(:user) { create(:user, spree_roles: roles_for_user) }
  let(:roles_for_rule) { [] }
  let(:roles_for_user) { [] }

  subject { rule }

  shared_examples 'eligibility' do
    context 'no roles on rule' do
      let(:roles_for_user) { [create(:role)] }
      it 'should not be eligible' do
        expect(rule).to_not be_eligible(order)
      end
    end

    context 'no roles on user' do
      let(:roles_for_rule) { [create(:role)] }
      it 'should not be eligible' do
        expect(rule).to_not be_eligible(order)
      end
    end

    context 'mismatched roles' do
      let(:roles_for_user) { [create(:role)] }
      let(:roles_for_rule) { [create(:role)] }
      it 'should not be eligible' do
        expect(rule).to_not be_eligible(order)
      end
    end

    context 'matching all roles' do
      let(:roles_for_user) { [create(:role), create(:role)] }
      let(:roles_for_rule) { roles_for_user }
      it 'should be eligible' do
        expect(rule).to be_eligible(order)
      end
    end
  end

  context '#eligible?(order)' do
    context 'order with no user' do
      let(:order) { Spree::Order.new }

      it 'should not be eligible' do
        expect(rule).to_not be_eligible(order)
      end
    end

    context 'order with user' do
      let(:order) { Spree::Order.new(user: user) }

      context 'with any match policy' do
        before { rule.preferred_match_policy = 'any' }

        include_examples 'eligibility'

        context 'one shared role' do
          let(:shared_role) { create(:role) }
          let(:roles_for_user) { [create(:role), shared_role] }
          let(:roles_for_rule) { [create(:role), shared_role] }
          it 'should be eligible' do
            expect(rule).to be_eligible(order)
          end
        end
      end

      context 'with all match policy' do
        before { rule.preferred_match_policy = 'all' }

        include_examples 'eligibility'

        context 'one shared role' do
          let(:shared_role) { create(:role) }
          let(:roles_for_user) { [create(:role), shared_role] }
          let(:roles_for_rule) { [create(:role), shared_role] }
          it 'should not be eligible' do
            expect(rule).to_not be_eligible(order)
          end
        end
      end
    end
  end
end
