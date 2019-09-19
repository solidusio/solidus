# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::LegacyUser, type: :model do
  context "#last_incomplete_order" do
    let!(:user) { create(:user) }

    it "excludes orders that are not frontend_viewable" do
      create(:order, user: user, frontend_viewable: false)
      expect(user.last_incomplete_spree_order).to eq nil
    end

    it "can include orders that are not frontend viewable" do
      order = create(:order, user: user, frontend_viewable: false)
      expect(user.last_incomplete_spree_order(only_frontend_viewable: false)).to eq order
    end

    it "can scope to a store" do
      store = create(:store)
      store_1_order = create(:order, user: user, store: store)
      create(:order, user: user, store: create(:store))
      expect(user.last_incomplete_spree_order(store: store)).to eq store_1_order
    end

    it "excludes completed orders" do
      create(:completed_order_with_totals, user: user, created_by: user)
      expect(user.last_incomplete_spree_order).to eq nil
    end

    it "excludes orders created prior to the user's last completed order" do
      create(:order, user: user, created_by: user, created_at: 1.second.ago)
      create(:completed_order_with_totals, user: user, created_by: user)
      expect(user.last_incomplete_spree_order).to eq nil
    end

    context "with completable_order_created_cutoff set" do
      before do
        stub_spree_preferences(completable_order_created_cutoff_days: 1)
      end

      it "excludes orders updated outside of the cutoff date" do
        create(:order, user: user, created_by: user, created_at: 3.days.ago, updated_at: 2.days.ago)
        expect(user.last_incomplete_spree_order).to eq nil
      end
    end

    context "with completable_order_created_cutoff set" do
      before do
        stub_spree_preferences(completable_order_updated_cutoff_days: 1)
      end

      it "excludes orders updated outside of the cutoff date" do
        create(:order, user: user, created_by: user, created_at: 3.days.ago, updated_at: 2.days.ago)
        expect(user.last_incomplete_spree_order).to eq nil
      end
    end

    it "chooses the most recently created incomplete order" do
      create(:order, user: user, created_at: 1.second.ago)
      order_2 = create(:order, user: user)
      expect(user.last_incomplete_spree_order).to eq order_2
    end

    context "persists order address" do
      let(:bill_address) { create(:address) }
      let(:ship_address) { create(:address) }
      let(:order) { create(:order, user: user, bill_address: bill_address, ship_address: ship_address) }

      it "doesn't create new addresses" do
        user.user_addresses.create(address: bill_address)
        user.user_addresses.create(address: ship_address)
        user.reload

        expect {
          user.persist_order_address(order)
        }.not_to change { Spree::Address.count }
      end

      it "associates both the bill and ship address to the user" do
        user.persist_order_address(order)
        user.save!
        user.user_addresses.reload

        expect(user.user_addresses.find_first_by_address_values(order.bill_address.attributes)).to_not be_nil
        expect(user.user_addresses.find_first_by_address_values(order.ship_address.attributes)).to_not be_nil
      end
    end

    context "payment source" do
      let(:payment_method) { create(:credit_card_payment_method) }
      let!(:cc) do
        create(:credit_card, user_id: user.id, payment_method: payment_method, gateway_customer_profile_id: "2342343")
      end

      it "has payment sources" do
        Spree::Deprecation.silence do
          expect(user.payment_sources.first.gateway_customer_profile_id).not_to be_empty
        end
      end
    end
  end
end

RSpec.describe Spree.user_class, type: :model do
  context "reporting" do
    let(:order_value) { BigDecimal("80.94") }
    let(:order_count) { 4 }
    let(:orders) { Array.new(order_count, double(total: order_value)) }

    before do
      allow(orders).to receive(:pluck).with(:total).and_return(orders.map(&:total))
      allow(orders).to receive(:count).and_return(orders.length)
    end

    def load_orders
      allow(subject).to receive(:spree_orders).and_return(double(complete: orders))
    end

    describe "#lifetime_value" do
      context "with orders" do
        before { load_orders }
        it "returns the total of completed orders for the user" do
          expect(subject.lifetime_value).to eq(order_count * order_value)
        end
      end
      context "without orders" do
        it "returns 0.00" do
          expect(subject.lifetime_value).to eq BigDecimal("0.00")
        end
      end
    end

    describe "#display_lifetime_value" do
      it "returns a Spree::Money version of lifetime_value" do
        value = BigDecimal("500.05")
        allow(subject).to receive(:lifetime_value).and_return(value)
        expect(subject.display_lifetime_value).to eq Spree::Money.new(value)
      end
    end

    describe "#order_count" do
      before { load_orders }
      it "returns the count of completed orders for the user" do
        expect(subject.order_count).to eq order_count
      end
    end

    describe "#average_order_value" do
      context "with orders" do
        before { load_orders }
        it "returns the average completed order price for the user" do
          expect(subject.average_order_value).to eq order_value
        end
      end
      context "without orders" do
        it "returns 0.00" do
          expect(subject.average_order_value).to eq BigDecimal("0.00")
        end
      end
    end

    describe "#display_average_order_value" do
      before { load_orders }
      it "returns a Spree::Money version of average_order_value" do
        value = BigDecimal("500.05")
        allow(subject).to receive(:average_order_value).and_return(value)
        expect(subject.display_average_order_value).to eq Spree::Money.new(value)
      end
    end
  end

  # TODO: Remove this after the method has been fully removed
  describe "#total_available_store_credit" do
    before do
      allow_any_instance_of(Spree::LegacyUser).to receive(:total_available_store_credit).and_wrap_original do |method, *args|
        Spree::Deprecation.silence do
          method.call(*args)
        end
      end
    end

    context "user does not have any associated store credits" do
      subject { create(:user) }

      it "returns 0" do
        expect(subject.total_available_store_credit).to be_zero
      end
    end

    context "user has several associated store credits" do
      let(:user)                     { create(:user) }
      let(:amount)                   { 120.25 }
      let(:additional_amount)        { 55.75 }
      let(:store_credit)             { create(:store_credit, user: user, amount: amount, amount_used: 0.0) }
      let!(:additional_store_credit) { create(:store_credit, user: user, amount: additional_amount, amount_used: 0.0) }

      subject { store_credit.user }

      context "part of the store credit has been used" do
        let(:amount_used) { 35.00 }

        before { store_credit.update(amount_used: amount_used) }

        context "part of the store credit has been authorized" do
          let(:authorized_amount) { 10 }

          before { additional_store_credit.update(amount_authorized: authorized_amount) }

          it "returns sum of amounts minus used amount and authorized amount" do
            expect(subject.total_available_store_credit.to_f).to eq(amount + additional_amount - amount_used - authorized_amount)
          end
        end

        context "there are no authorized amounts on any of the store credits" do
          it "returns sum of amounts minus used amount" do
            expect(subject.total_available_store_credit.to_f).to eq(amount + additional_amount - amount_used)
          end
        end
      end

      context "store credits have never been used" do
        context "part of the store credit has been authorized" do
          let(:authorized_amount) { 10 }

          before { additional_store_credit.update(amount_authorized: authorized_amount) }

          it "returns sum of amounts minus authorized amount" do
            expect(subject.total_available_store_credit.to_f).to eq(amount + additional_amount - authorized_amount)
          end
        end

        context "there are no authorized amounts on any of the store credits" do
          it "returns sum of amounts" do
            expect(subject.total_available_store_credit.to_f).to eq(amount + additional_amount)
          end
        end
      end

      context "all store credits have never been used or authorized" do
        it "returns sum of amounts" do
          expect(subject.total_available_store_credit.to_f).to eq(amount + additional_amount)
        end
      end
    end
  end
end
