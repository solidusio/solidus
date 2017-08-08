require 'spec_helper'

describe Spree::UserMethods do
  let(:test_user) { create :user }

  describe '#has_spree_role?' do
    subject { test_user.has_spree_role? name }

    let(:role) { Spree::Role.create(name: name) }
    let(:name) { 'test' }

    context 'with a role' do
      before { test_user.spree_roles << role }
      it     { is_expected.to be_truthy }
    end

    context 'without a role' do
      it { is_expected.to be_falsy }
    end
  end

  describe '#last_incomplete_spree_order' do
    subject { test_user.last_incomplete_spree_order }

    context 'with an incomplete order' do
      let(:last_incomplete_order) { create :order, user: test_user }

      before do
        create(:order, user: test_user, created_at: 1.day.ago)
        create(:order, user: create(:user))
        last_incomplete_order
      end

      it { is_expected.to eq last_incomplete_order }
    end

    context 'without an incomplete order' do
      it { is_expected.to be_nil }
    end
  end

  describe "deleting user" do
    context "with no orders" do
      it "fails validation" do
        test_user.destroy!
        expect(test_user).to be_destroyed
      end
    end

    context "with an order" do
      let!(:order) { create(:order, user: test_user) }

      it "fails validation" do
        expect {
          test_user.destroy!
        }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end
end
