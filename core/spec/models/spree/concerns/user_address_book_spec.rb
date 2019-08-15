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
      context "saving a default address" do
        let(:user_address) { user.user_addresses.find_first_by_address_values(address.attributes) }

        subject { user.save_in_address_book(address.attributes, true) }

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
          end

          it "adds the address to the user's the associated addresses" do
            expect { subject }.to change { user.reload.addresses.count }.by(1)
          end
        end

        context "user already has a default address" do
          let(:address) { create(:address) }
          let(:original_default_address) { create(:ship_address) }
          let(:original_user_address) { user.user_addresses.find_first_by_address_values(original_default_address.attributes) }

          before do
            user.user_addresses.create(address: original_default_address, default: true)
          end

          it "makes all the other associated addresses not be the default" do
            expect { subject }.to change { original_user_address.reload.default }.from(true).to(false)
          end

          context "an odd flip-flop corner case discovered running backfill rake task" do
            before do
              user.save_in_address_book(original_default_address.attributes, true)
              user.save_in_address_book(address.attributes, true)
            end

            it "handles setting 2 addresses as default without a reload of user" do
              user.save_in_address_book(original_default_address.attributes, true)
              user.save_in_address_book(address.attributes, true)
              expect(user.addresses.count).to eq 2
              expect(user.default_address.address1).to eq address.address1
            end
          end
        end

        context "changing existing address to default" do
          let(:address) { create(:address) }

          before do
            user.user_addresses.create(address: address, default: false)
          end

          it "properly sets the default flag" do
            expect(subject).to eq user.default_address
          end

          context "and changing another address field at the same time" do
            let(:updated_address_attributes) { address.attributes.tap { |value| value[:first_name] = "Newbie" } }

            subject { user.save_in_address_book(updated_address_attributes, true) }

            it "changes first name" do
              expect(subject.first_name).to eq updated_address_attributes[:first_name]
            end

            it "preserves last name" do
              expect(subject.last_name).to eq address.last_name
            end

            it "is a new immutable address instance" do
              expect(subject.id).to_not eq address.id
            end

            it "is the new default" do
              expect(subject).to eq user.default_address
            end
          end
        end
      end

      context "updating an address and making default at once" do
        let(:address1) { create(:address) }
        let(:address2) { create(:address, firstname: "Different") }
        let(:updated_attrs) do
          address2.attributes.tap { |value| value[:firstname] = "Johnny" }
        end

        before do
          user.save_in_address_book(address1.attributes, true)
          user.save_in_address_book(address2.attributes, false)
        end

        it "returns the edit as the first address" do
          user.save_in_address_book(updated_attrs, true)
          expect(user.user_addresses.first.address.firstname).to eq "Johnny"
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
            it "sets the UserAddress default flag to false" do
              expect { subject }.to change { Spree::UserAddress.count }.by(1)
              expect(user_address.default).to eq false
            end
          end

          context "it is the first address" do
            it "sets the UserAddress default flag to true" do
              subject
              expect(user_address.default).to eq true
            end
          end

          it "adds the address to the user's the associated addresses" do
            expect { subject }.to change { user.reload.addresses.count }.by(1)
          end
        end
      end

      context "resurrecting a previously saved (but now archived) address" do
        let(:address) { create(:address) }
        before do
          user.save_in_address_book(address.attributes, true)
          user.remove_from_address_book(address.id)
        end
        subject { user.save_in_address_book(address.attributes, true) }

        it "returns the address" do
          expect(subject).to eq address
        end

        it "sets it as default" do
          subject
          expect(user.default_address).to eq address
        end

        context "via an edit to another address" do
          let(:address2) { create(:address, firstname: "Different") }
          let(:edited_attributes) do
            # conceptually edit address2 to match the values of address
            edited_attributes = address.attributes
            edited_attributes[:id] = address2.id
            edited_attributes
          end

          before { user.save_in_address_book(address2.attributes, true) }

          subject { user.save_in_address_book(edited_attributes) }

          it "returns the address" do
            expect(subject).to eq address
          end

          it "archives address2" do
            subject
            user_address_two = user.user_addresses.all_historical.find_by(address_id: address2.id)
            expect(user_address_two.archived).to be true
          end

          context "via a new address that matches an archived one" do
            let(:added_attributes) do
              added_attributes = address.attributes
              added_attributes.delete(:id)
              added_attributes
            end

            subject { user.save_in_address_book(added_attributes) }

            it "returns the address" do
              expect(subject).to eq address
            end

            it "no longer has archived user_addresses" do
              subject
              expect(user.user_addresses.all_historical).to eq user.user_addresses
            end
          end
        end
      end
    end

    context "#remove_from_address_book" do
      let(:address1) { create(:address) }
      let(:address2) { create(:address, firstname: "Different") }
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

      it "leaves user_address record in an archived state" do
        subject
        archived_user_address = user.user_addresses.all_historical.find_first_by_address_values(address1.attributes)
        expect(archived_user_address).to be_archived
      end

      it "returns false if the addresses is not there" do
        expect(user.remove_from_address_book(0)).to be false
      end
    end

    context "#persist_order_address" do
      it 'will save the bill/ship_address reference if it can' do
        order = create :order
        user.persist_order_address(order)

        expect( user.bill_address_id ).to eq order.bill_address_id
        expect( user.ship_address_id ).to eq order.ship_address_id
        expect( user.bill_address_id ).not_to eq user.ship_address_id
      end

      context "when automatic_default_address preference is at a default of true" do
        before do
          stub_spree_preferences(automatic_default_address: true)
          expect(user).to receive(:save_in_address_book).with(kind_of(Hash), true)
          expect(user).to receive(:save_in_address_book).with(kind_of(Hash), false)
        end

        it "does set the default: true flag" do
          order = build(:order)
          user.persist_order_address(order)
        end
      end

      context "when automatic_default_address preference is false" do
        before do
          stub_spree_preferences(automatic_default_address: false)
          expect(user).to receive(:save_in_address_book).with(kind_of(Hash), false).twice
          # and not the optional 2nd argument
        end

        it "does not set the default: true flag" do
          order = build(:order)
          user.persist_order_address(order)
        end
      end

      context "when address is nil" do
        context "when automatic_default_address preference is at a default of true" do
          before do
            stub_spree_preferences(automatic_default_address: true)
            expect(user).to receive(:save_in_address_book).with(kind_of(Hash), true).once
          end

          it "does not call save_in_address_book on ship address" do
            order = build(:order)
            order.ship_address = nil

            user.persist_order_address(order)
          end

          it "does not call save_in_address_book on bill address" do
            order = build(:order)
            order.bill_address = nil

            user.persist_order_address(order)
          end
        end
      end

      context "when automatic_default_address preference is false" do
        before do
          stub_spree_preferences(automatic_default_address: false)
          expect(user).to receive(:save_in_address_book).with(kind_of(Hash), false).once
        end

        it "does not call save_in_address_book on ship address" do
          order = build(:order)
          order.ship_address = nil

          user.persist_order_address(order)
        end

        it "does not call save_in_address_book on bill address" do
          order = build(:order)
          order.bill_address = nil

          user.persist_order_address(order)
        end
      end
    end

    describe "generating a new user with a ship_address at once" do
      let(:ship_address) { build(:ship_address) }
      subject { create(:user, ship_address: ship_address) }

      it "stores the ship_address" do
        expect(subject.ship_address).to eq ship_address
      end

      it "is also available as default_address" do
        expect(subject.default_address).to eq ship_address
      end
    end

    describe "ship_address=" do
      let!(:user) { create(:user) }
      let!(:address) { create(:address) }

      # https://github.com/solidusio/solidus/issues/1241
      it "resets the association and persists" do
        # Load (which will cache) the has_one association
        expect(user.ship_address).to be_nil

        user.update!(ship_address: address)
        expect(user.ship_address).to eq(address)

        user.reload
        expect(user.ship_address).to eq(address)
      end
    end
  end
end
