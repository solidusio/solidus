# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/dummy_ability'

RSpec.describe Spree::PermissionSets::OrderManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Spree::Order) }
    it { is_expected.to be_able_to(:manage, Spree::Payment) }
    it { is_expected.to be_able_to(:manage, Spree::Shipment) }
    it { is_expected.to be_able_to(:manage, Spree::Adjustment) }
    it { is_expected.to be_able_to(:manage, Spree::LineItem) }
    it { is_expected.to be_able_to(:manage, Spree::ReturnAuthorization) }
    it { is_expected.to be_able_to(:manage, Spree::CustomerReturn) }
    it { is_expected.to be_able_to(:read, Spree::ReimbursementType) }
    it { is_expected.to be_able_to(:manage, Spree::OrderCancellations) }
    it { is_expected.to be_able_to(:manage, Spree::Reimbursement) }
    it { is_expected.to be_able_to(:manage, Spree::ReturnItem) }
    it { is_expected.to be_able_to(:manage, Spree::Refund) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Spree::Order) }
    it { is_expected.not_to be_able_to(:manage, Spree::Payment) }
    it { is_expected.not_to be_able_to(:manage, Spree::Shipment) }
    it { is_expected.not_to be_able_to(:manage, Spree::Adjustment) }
    it { is_expected.not_to be_able_to(:manage, Spree::LineItem) }
    it { is_expected.not_to be_able_to(:manage, Spree::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:manage, Spree::CustomerReturn) }
    it { is_expected.not_to be_able_to(:read, Spree::ReimbursementType) }
    it { is_expected.not_to be_able_to(:manage, Spree::OrderCancellations) }
    it { is_expected.not_to be_able_to(:manage, Spree::Reimbursement) }
    it { is_expected.not_to be_able_to(:manage, Spree::ReturnItem) }
    it { is_expected.not_to be_able_to(:manage, Spree::Refund) }
  end

  describe ".privilege" do
    it "returns the correct privilege symbol" do
      expect(described_class.privilege).to eq(:management)
    end
  end

  describe ".category" do
    it "returns the correct category symbol" do
      expect(described_class.category).to eq(:order)
    end
  end
end
