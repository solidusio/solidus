# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe UserAddressBook do
    #
    # Using LegacyUser as a subject
    # since it uses the UserAddressBookExtension
    #
    let!(:user) { create(:user) }

    describe "#save_in_address_book" do
      context "saving a default shipping address" do
        let(:user_address) { user.user_addresses.find_first_by_address_values(address.attributes) }
        let(:force_default) { true }
        subject { user.save_in_address_book(address.attributes, force_default) }

        context "the address is a new record" do
          let(:address) { build(:address) }

          it "creates a new Address" do
            expect { subject }.to change { Spree::Address.count }.by(1)
          end

          it "creates a UserAddress" do
            expect { subject }.to change { Spree::UserAddress.count }.by(1)
          end

          it "sets the UserAddress default flag to true" do
            subject

            expect(user_address.default).to eq true
            expect(user_address.default_billing).to be_falsey
          end

          context "saving a billing address" do
            subject { user.save_in_address_book(address.attributes, true, :billing) }

            it "sets the UserAddress default_billing flag to true" do
              subject
              expect(user_address.default).to be_falsey
              expect(user_address.default_billing).to eq true
            end
          end

          it "adds the address to the user's associated addresses" do
            expect { subject }.to change { user.reload.addresses.count }.by(1)
          end
        end

        context "user already has default addresses" do
          let(:address) { create(:address) }
          let(:original_default_address) { create(:ship_address) }
          let(:original_default_bill_address) { create(:bill_address) }
          let(:original_user_address) { user.user_addresses.find_first_by_address_values(original_default_address.attributes) }
          let(:original_user_bill_address) { user.user_addresses.find_first_by_address_values(original_default_bill_address.attributes) }
          let(:force_default) { false }

          before do
            user.user_addresses.create(address: original_default_address, default: true)
            user.user_addresses.create(address: original_default_bill_address, default_billing: true)
          end

          context "saving a shipping address" do
            context "makes all the other associated shipping addresses not be the default and ignores the billing ones" do
              it { expect { subject }.not_to change { original_user_address.reload.default }.from(true) }
              it { expect { subject }.not_to change { original_user_bill_address.reload.default_billing } }
            end

            context "an odd flip-flop corner case discovered running backfill rake task" do
              before do
                user.save_in_address_book(original_default_address.attributes, true)
                user.save_in_address_book(address.attributes, true)
              end

              it "handles setting 2 addresses as default without a reload of user" do
                user.save_in_address_book(original_default_address.attributes, true)
                user.save_in_address_book(address.attributes, true)
                expect(user.addresses.count).to eq 3
                expect(user.ship_address.address1).to eq address.address1
              end
            end
          end

          context "saving a billing address" do
            subject { user.save_in_address_book(address.attributes, true, :billing) }

            context "makes all the other associated billing addresses not be the default and ignores the shipping ones" do
              it { expect { subject }.not_to change { original_user_address.reload.default } }
              it { expect { subject }.to change { original_user_bill_address.reload.default_billing }.from(true).to(false) }
            end

            context "an odd flip-flop corner case discovered running backfill rake task" do
              before do
                user.save_in_address_book(original_default_bill_address.attributes, true, :billing)
                user.save_in_address_book(address.attributes, true, :billing)
              end

              it "handles setting 2 addresses as default without a reload of user" do
                user.save_in_address_book(original_default_address.attributes, true, :billing)
                user.save_in_address_book(address.attributes, true, :billing)
                expect(user.addresses.count).to eq 3
                expect(user.bill_address.address1).to eq address.address1
              end
            end
          end
        end

        context "changing existing address to default" do
          let(:address) { create(:address) }

          before do
            user.user_addresses.create(address:, default: false)
          end

          context "properly sets the default flag" do
            context "shipping address" do
              it { expect(subject).to eq user.ship_address }
            end

            context "billing address" do
              subject { user.save_in_address_book(address.attributes, true, :billing) }
              it { expect(subject).to eq user.bill_address }
            end
          end

          context "and changing another address field at the same time" do
            let(:updated_address_attributes) { address.attributes.tap { |value| value[:city] = "Dallas" } }

            subject { user.save_in_address_book(updated_address_attributes, true) }

            it "changes city" do
              expect(subject.city).to eq updated_address_attributes[:city]
            end

            it "preserves firstname" do
              expect(subject.firstname).to eq address.firstname
            end

            it "preserves name" do
              expect(subject.name).to eq address.name
            end

            it "is a new immutable address instance" do
              expect(subject.id).to_not eq address.id
            end

            context "is the new default" do
              context "shipping address" do
                it { expect(subject).to eq user.ship_address }
              end

              context "billing address" do
                subject { user.save_in_address_book(address.attributes, true, :billing) }
                it { expect(subject).to eq user.bill_address }
              end
            end
          end
        end
      end

      context "updating an address and making default at once" do
        let(:address1) { create(:address) }
        let(:address2) { create(:address, firstname: "Different", name: "Different") }
        let(:updated_attrs) do
          address2.attributes.tap do |value|
            value[:firstname] = "Johnny"
            value[:name] = "Johnny"
          end
        end

        before do
          user.save_in_address_book(address1.attributes, true)
          user.save_in_address_book(address2.attributes, false)
        end

        it "returns the edit as the first address" do
          user.save_in_address_book(updated_attrs, true)
          expect(user.user_addresses.first.address.firstname).to eq "Johnny"
          expect(user.user_addresses.first.address.name).to eq "Johnny"
        end
      end

      context "saving a non-default address" do
        let(:user_address) { user.user_addresses.find_first_by_address_values(address.attributes) }

        subject { user.save_in_address_book(address.attributes) }

        context "the address is a new record" do
          let(:address) { build(:address) }

          it "creates a new Address" do
            expect { subject }.to change { Spree::Address.count }.by(1)
          end

          it "creates a UserAddress" do
            expect { subject }.to change { Spree::UserAddress.count }.by(1)
          end

          context "it is not the first address" do
            before { user.user_addresses.create!(address: create(:address)) }

            it "sets the UserAddress default flags to false" do
              expect { subject }.to change { Spree::UserAddress.count }.by(1)
              expect(user_address.default).to eq false
              expect(user_address.default_billing).to eq false
            end
          end

          context "it is the first address" do
            context "shipping address" do
              it "sets the UserAddress default flag to true" do
                subject
                expect(user_address.default).to eq true
                expect(user_address.default_billing).to be_falsey
              end
            end

            context "billing address" do
              subject { user.save_in_address_book(address.attributes, false, :billing) }

              it "sets the UserAddress default flag to true" do
                subject
                expect(user_address.default).to be_falsey
                expect(user_address.default_billing).to eq true
              end
            end
          end

          it "adds the address to the user's the associated addresses" do
            expect { subject }.to change { user.reload.addresses.count }.by(1)
          end
        end
      end
    end

    context "#remove_from_address_book" do
      let(:address1) { create(:address) }
      let(:address2) { create(:address, firstname: "Different", name: "Different") }
      let(:remove_id) { address1.id }

      subject { user.remove_from_address_book(remove_id) }

      before do
        user.save_in_address_book(address1.attributes)
        user.save_in_address_book(address2.attributes)
      end

      it "removes the address from user_addresses" do
        subject
        expect(user.user_addresses.find_first_by_address_values(address1.attributes)).to be_nil
      end

      it "deletes user_address record" do
        subject
        expect(user.user_addresses.map(&:address)).to eq([address2])
      end

      it "returns false if the addresses is not there" do
        expect(user.remove_from_address_book(0)).to be false
      end

      context 'when user has previous order addresses' do
        let(:order) { create(:order, ship_address: address1, bill_address: address2) }

        before { user.persist_order_address(order) }

        context 'when address does not match any user address references' do
          let(:another_address) { create(:address) }

          let(:remove_id) { another_address.id }

          it 'leaves current user ship address' do
            expect { subject }.not_to change(user, :ship_address_id).from(address1.id)
          end

          it 'leaves current user bill address' do
            expect { subject }.not_to change(user, :bill_address_id).from(address2.id)
          end
        end

        context 'when address matches user ship address' do
          it 'removes the ship address reference from user' do
            expect { subject }.to change(user, :ship_address_id).from(address1.id).to(nil)
          end
        end

        context 'when address matches user bill address' do
          let(:remove_id) { address2.id }

          it 'removes the bill address reference from user' do
            expect { subject }.to change(user, :bill_address_id).from(address2.id).to(nil)
          end
        end

        context 'when address matches user bill and ship address' do
          let(:order) { create(:order, ship_address: address1, bill_address: address1) }

          it 'removes the address references from user' do
            expect { subject }.to change(user, :ship_address_id).from(address1.id).to(nil)
              .and change(user, :bill_address_id).from(address1.id).to(nil)
          end
        end
      end
    end

    context "#persist_order_address" do
      context "when automatic_default_address preference is at a default of true" do
        let(:order) { create :order }

        it 'will save both bill/ship_address references' do
          user.persist_order_address(order)

          expect( user.bill_address_id ).to eq order.bill_address_id
          expect( user.ship_address_id ).to eq order.ship_address_id
          expect( user.bill_address_id ).not_to eq user.ship_address_id

          expect( user.bill_address).to eq order.bill_address
          expect( user.ship_address).to eq order.ship_address
        end
      end

      context "when automatic_default_address preference is false" do
        let(:order) { create :order }

        before do
          stub_spree_preferences(automatic_default_address: false)
        end

        it "will save only the default ship address on user as it is the first address at all" do
          user.persist_order_address(order)

          expect( user.bill_address_id ).to eq order.bill_address_id
          expect( user.ship_address_id ).to eq order.ship_address_id

          expect( user.bill_address).to be_nil
          expect( user.ship_address).to eq order.ship_address
        end
      end

      context "when either ship_address or bill_address is nil" do
        context "when automatic_default_address preference is at a default of true" do
          before do
            stub_spree_preferences(automatic_default_address: true)
          end

          it "does not call save_in_address_book on ship address" do
            order = build(:order)
            order.ship_address = nil

            expect(user).to receive(:save_in_address_book).with(kind_of(Hash), true, :billing).once
            user.persist_order_address(order)
          end

          it "does not call save_in_address_book on bill address" do
            order = build(:order)
            order.bill_address = nil

            expect(user).to receive(:save_in_address_book).with(kind_of(Hash), true).once
            user.persist_order_address(order)
          end
        end

        context "when automatic_default_address preference is false" do
          let(:order) { build(:order) }

          before do
            stub_spree_preferences(automatic_default_address: false)
          end

          it "does not call save_in_address_book on ship address" do
            order.ship_address = nil

            expect(user).to receive(:save_in_address_book).with(kind_of(Hash), false, :billing).once
            user.persist_order_address(order)
          end

          it "does not call save_in_address_book on bill address" do
            order.bill_address = nil

            expect(user).to receive(:save_in_address_book).with(kind_of(Hash), false).once
            user.persist_order_address(order)
          end
        end
      end
    end

    describe "generating a new user with a ship_address at once" do
      let(:ship_address) { build(:ship_address) }
      subject { create(:user, ship_address:) }

      it "stores the ship_address" do
        expect(subject.ship_address).to eq ship_address
      end
    end

    describe "#ship_address=" do
      let!(:user) { create(:user) }
      let!(:address) { create(:address) }

      # https://github.com/solidusio/solidus/issues/1241
      it "resets the association and persists the ship_address" do
        # Load (which will cache) the has_one association
        expect(user.ship_address).to be_nil

        user.update!(ship_address: address)
        expect(user.ship_address).to eq(address)

        user.reload
        expect(user.ship_address).to eq(address)
      end
    end

    describe "#bill_address=" do
      let!(:user) { create(:user) }
      let!(:address) { create(:address) }

      # https://github.com/solidusio/solidus/issues/1241
      it "resets the association and persists the bill_address" do
        # Load (which will cache) the has_one association
        expect(user.bill_address).to be_nil

        user.update!(bill_address: address)
        expect(user.bill_address).to eq(address)

        user.reload
        expect(user.bill_address).to eq(address)
      end
    end

    describe "#ship_address_attributes=" do
      let(:attributes) { {} }
      let(:address) { build :address }

      before do
        allow(Spree::Address).to receive(:immutable_merge).and_return address
      end

      it "updates ship_address with its present attributes merged with the passed ones" do
        expect(Spree::Address).to receive(:immutable_merge).with(user.ship_address, attributes)
        expect(user).to receive(:ship_address=).with address

        user.ship_address_attributes = attributes
      end
    end

    describe "#mark_default_ship_address" do
      let(:user_address) { user.user_addresses.create(address: build(:address), default: false) }

      it "marks address specified as default shipping" do
        user.mark_default_ship_address(user_address.address)
        expect(user_address.reload.default).to be_truthy
      end
    end

    describe "#mark_default_bill_address" do
      let(:user) { create(:user_with_addresses) }
      let(:user_address) { user.user_addresses.find_by(default_billing: false) }

      it "marks address specified as default billing" do
        user.mark_default_bill_address(user_address.address)
        expect(user_address.reload.default_billing).to be_truthy
      end
    end
  end
end
