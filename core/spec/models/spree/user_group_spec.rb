# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UserGroup, type: :model do
  describe 'associations' do
    it 'has many users' do
      association = described_class.reflect_on_association(:users)

      expect(association.macro).to eq :has_many
      expect(association.class_name).to eq Spree::UserClassHandle.new.to_s
    end

    it 'has one store' do
      association = described_class.reflect_on_association(:store)

      expect(association.macro).to eq :has_one
      expect(association.class_name).to eq 'Spree::Store'
      expect(association.options[:foreign_key]).to eq 'default_cart_user_group_id'
    end
  end

  describe 'validations' do
    context 'when validating presence' do
      it 'validates presence of group_name' do
        user_group = Spree::UserGroup.new
        user_group.valid?

        expect(user_group.errors[:group_name]).to include("can't be blank")
      end
    end

    context 'when creating a valid user group' do
      it 'is valid with a group_name' do
        user_group = Spree::UserGroup.new(group_name: 'Test Group')

        expect(user_group).to be_valid
      end
    end
  end

  describe 'user group relations' do
    let(:user_group) { create(:user_group) }

    context '#users' do
      let(:user) { create(:user) }

      before do
        user_group.users << user
      end

      it 'returns the associated users' do
        expect(user_group.users).to include(user)
      end
    end

    context '#store' do
      let(:store) { create(:store, default_cart_user_group: user_group) }

      it 'returns the associated store' do
        store.reload
        user_group.reload

        expect(user_group.store).to eq(store)
      end
    end
  end
end
