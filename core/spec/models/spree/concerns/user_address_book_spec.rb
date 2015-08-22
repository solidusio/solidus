require 'spec_helper'

module Spree
  describe UserAddressBook do

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
    end
  end
end
