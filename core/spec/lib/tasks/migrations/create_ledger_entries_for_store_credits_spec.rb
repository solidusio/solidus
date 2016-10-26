require 'spec_helper'

describe 'solidus:migrations:create_ledger_entries_for_store_credits' do
  include_context(
    'rake',
    task_name: 'solidus:migrations:create_ledger_entries_for_store_credits:up',
    task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/create_ledger_entries_for_store_credits.rake'),
  )

  let(:store_credit) { create(:store_credit, store_credit_attr) }
  let(:store_credit_attr) { {} }

  context "Store credit without any changes" do
    let(:store_credit_attr) { { amount: 250 } }

    it 'will create a ledger entry with the right amount' do
      store_credit
      Spree::StoreCreditLedgerEntry.destroy_all
      expect {
        task.invoke
      }.to change { Spree::StoreCreditLedgerEntry.count }.by(1)

      expect(store_credit.liability_balance).to eql 250
    end
  end

  context "Store credit with some used amounts" do
    let(:store_credit_attr) { { amount: 250, amount_used: 100 } }

    it 'will create a ledger entry with the right amount' do
      store_credit
      Spree::StoreCreditLedgerEntry.destroy_all
      expect {
        task.invoke
      }.to change { Spree::StoreCreditLedgerEntry.count }.by(1)

      expect(store_credit.liability_balance).to eql 150
    end
  end

  context "Store credit with some used amounts and authorised amounts" do
    let(:store_credit_attr) { { amount: 250, amount_used: 100, amount_authorized: 50 } }

    it 'will create a ledger entry with the right amount' do
      store_credit
      Spree::StoreCreditLedgerEntry.destroy_all
      expect {
        task.invoke
      }.to change { Spree::StoreCreditLedgerEntry.count }.by(2)

      expect(store_credit.liability_balance).to eql 150
    end
  end

  context "Invalidated store credit" do
    let(:store_credit_attr) { { amount: 250, amount_used: 100 } }
    let(:invalidation_user) { create(:user) }
    let(:invalidation_reason) { create(:store_credit_update_reason) }

    it 'will create a ledger entry with the right amount' do
      store_credit.invalidate(invalidation_reason, invalidation_user)
      Spree::StoreCreditLedgerEntry.destroy_all
      expect {
        task.invoke
      }.to change { Spree::StoreCreditLedgerEntry.count }.by(1)

      expect(store_credit.liability_balance).to eql 0
    end
  end
end
