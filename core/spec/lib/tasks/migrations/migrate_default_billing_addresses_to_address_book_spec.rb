# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'solidus:migrations:migrate_default_billing_addresses_to_address_book' do
  describe 'up' do
    include_context(
      'rake',
      task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/migrate_default_billing_addresses_to_address_book.rake'),
      task_name: 'solidus:migrations:migrate_default_billing_addresses_to_address_book:up',
    )

    context "migrate from Solidus 2.11" do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let(:bill_address1) { FactoryBot.create(:address) }
      let(:bill_address2) { FactoryBot.create(:address) }
      let(:bill_address3) { FactoryBot.create(:address) }

      before do
        # Set two billing addresses for User1, the second address is the default.
        user1.save_in_address_book(bill_address1.attributes, false, :billing)
        user1.save_in_address_book(bill_address2.attributes, true, :billing)

        # Update the "bill_address_id" for user1 to be different from the address_book's default address.
        user1.update!(bill_address_id: bill_address1.id)

        # Set user2's bill address using old `bill_address_id` method.
        user2.save_in_address_book(bill_address3.attributes, false, :billing)
        user2.update!(bill_address_id: bill_address3.id)
        Spree::UserAddress.where(user_id: user2.id).first.update!(default_billing: false)
      end

      it 'runs' do
        expect { task.invoke }.to output(
          "Migrating default billing addresses to address book in batches of 100000 ... Success\n"
        ).to_stdout
      end

      it "does not migrate a user's `bill_address_id` when a user already has a default `bill_address` in the address book" do
        task.invoke
        expect(user1.bill_address_id).not_to eq bill_address2.id
        expect(user1.bill_address).to eq bill_address2
      end

      it "migrates a user's `bill_address_id` when a user does not have a default `bill_address` in the address book" do
        task.invoke
        expect(user2.bill_address_id).to eq bill_address3.id
        expect(user2.bill_address).to eq bill_address3
      end
    end

    context "migrate from Solidus 2.10" do
      let(:user) { create(:user) }
      let(:bill_address) { FactoryBot.create(:address) }

      before do
        # Set the user's bill address using old `bill_address_id` method.
        user.save_in_address_book(bill_address.attributes, false, :billing)
        user.update!(bill_address_id: bill_address.id)
        Spree::UserAddress.where(default_billing: true).update_all(default_billing: false)
      end

      it 'runs' do
        expect { task.invoke }.to output(
          "Migrating default billing addresses to address book in batches of 100000 ... Success\n"
        ).to_stdout
      end

      it "migrates a user's `bill_address_id` when a user does not have a default `bill_address` in the address book" do
        task.invoke
        expect(user.bill_address_id).to eq bill_address.id
        expect(user.bill_address).to eq bill_address
      end
    end
  end

  describe 'down' do
    include_context(
      'rake',
      task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/migrate_default_billing_addresses_to_address_book.rake'),
      task_name: 'solidus:migrations:migrate_default_billing_addresses_to_address_book:down',
    )

    let(:user) { create(:user) }
    let(:bill_address) { FactoryBot.create(:address) }

    before do
      user.save_in_address_book(bill_address.attributes, true, :billing)
    end

    it 'runs' do
      expect { task.invoke }.to output(
        "Rolled back default billing address migration to address book\n"
      ).to_stdout
    end

    it "Rolls back default billing address migration to address book" do
      task.invoke
      expect(user.bill_address).to eq nil
    end
  end
end
