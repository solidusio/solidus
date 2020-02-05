# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::StoreCreditCategory, type: :model do
  describe "#non_expiring?" do
    let(:store_credit_category) { build(:store_credit_category, name: category_name) }

    context "non-expiring type store credit" do
      let(:category_name) { "Non-expiring" }
      it { expect(store_credit_category).to be_non_expiring }
    end

    context "expiring type store credit" do
      let(:category_name) { "Expiring" }
      it { expect(store_credit_category).not_to be_non_expiring }
    end
  end

  describe '.reimbursement_category' do
    it 'raises a dreprecation warning' do
      allow(Spree::Deprecation).to receive(:warn)

      described_class.reimbursement_category(Spree::Reimbursement.new)

      expect(Spree::Deprecation).to have_received(:warn)
        .with(/reimbursement_category /, any_args)
    end
  end

  describe '.reimbursement_category_name' do
    it 'raises a dreprecation warning' do
      allow(Spree::Deprecation).to receive(:warn)

      described_class.reimbursement_category_name

      expect(Spree::Deprecation).to have_received(:warn)
        .with(/reimbursement_category_name /, any_args)
    end
  end
end
