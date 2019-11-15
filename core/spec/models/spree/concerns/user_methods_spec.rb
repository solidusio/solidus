# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UserMethods do
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

  describe '#available_store_credit_total' do
    subject do
      test_user.reload.available_store_credit_total(currency: 'USD')
    end

    context 'when the user does not have any credit' do
      it { is_expected.to eq(0) }
    end

    context 'when the user has credits' do
      let!(:credit_1) { create(:store_credit, user: test_user, amount: 100) }
      let!(:credit_2) { create(:store_credit, user: test_user, amount: 200) }

      it { is_expected.to eq(100 + 200) }

      context 'when some has been used' do
        before { credit_1.update!(amount_used: 35) }

        it { is_expected.to eq(100 + 200 - 35) }

        context 'when some has been authorized' do
          before { credit_1.update!(amount_authorized: 10) }

          it { is_expected.to eq(100 + 200 - 35 - 10) }
        end
      end

      context 'when some has been authorized' do
        before { credit_1.update!(amount_authorized: 10) }

        it { is_expected.to eq(100 + 200 - 10) }
      end

      context 'with credits of multiple currencies' do
        let!(:credit_3) { create(:store_credit, user: test_user, amount: 400, currency: 'GBP') }
        before { test_user.reload }

        it 'separates the currencies' do
          expect(test_user.available_store_credit_total(currency: 'USD')).to eq(100 + 200)
          expect(test_user.available_store_credit_total(currency: 'GBP')).to eq(400)
        end
      end
    end
  end

  describe '#display_available_store_credit_total' do
    subject do
      test_user.display_available_store_credit_total(currency: 'USD')
    end

    context 'without credit' do
      it { is_expected.to eq(Spree::Money.new(0)) }
    end

    context 'with credit' do
      let!(:credit) { create(:store_credit, user: test_user, amount: 100) }
      it { is_expected.to eq(Spree::Money.new(100)) }
    end
  end
end
