# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::OrderDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:read, Spree::Order) }
    it { is_expected.to be_able_to(:read, Spree::Payment) }
    it { is_expected.to be_able_to(:read, Spree::Shipment) }
    it { is_expected.to be_able_to(:read, Spree::Adjustment) }
    it { is_expected.to be_able_to(:read, Spree::LineItem) }
    it { is_expected.to be_able_to(:read, Spree::ReturnAuthorization) }
    it { is_expected.to be_able_to(:read, Spree::CustomerReturn) }
    it { is_expected.to be_able_to(:admin, Spree::Order) }
    it { is_expected.to be_able_to(:admin, Spree::Payment) }
    it { is_expected.to be_able_to(:admin, Spree::Shipment) }
    it { is_expected.to be_able_to(:admin, Spree::Adjustment) }
    it { is_expected.to be_able_to(:admin, Spree::LineItem) }
    it { is_expected.to be_able_to(:admin, Spree::ReturnAuthorization) }
    it { is_expected.to be_able_to(:admin, Spree::CustomerReturn) }
    it { is_expected.to be_able_to(:edit, Spree::Order) }
    it { is_expected.to be_able_to(:cart, Spree::Order) }
    it { is_expected.to be_able_to(:read, Spree::Reimbursement) }
    it { is_expected.to be_able_to(:read, Spree::ReturnItem) }
    it { is_expected.to be_able_to(:read, Spree::Refund) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:read, Spree::Order) }
    it { is_expected.not_to be_able_to(:read, Spree::Payment) }
    it { is_expected.not_to be_able_to(:read, Spree::Shipment) }
    it { is_expected.not_to be_able_to(:read, Spree::Adjustment) }
    it { is_expected.not_to be_able_to(:read, Spree::LineItem) }
    it { is_expected.not_to be_able_to(:read, Spree::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:read, Spree::CustomerReturn) }
    it { is_expected.not_to be_able_to(:admin, Spree::Order) }
    it { is_expected.not_to be_able_to(:admin, Spree::Payment) }
    it { is_expected.not_to be_able_to(:admin, Spree::Shipment) }
    it { is_expected.not_to be_able_to(:admin, Spree::Adjustment) }
    it { is_expected.not_to be_able_to(:admin, Spree::LineItem) }
    it { is_expected.not_to be_able_to(:admin, Spree::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:admin, Spree::CustomerReturn) }
    it { is_expected.not_to be_able_to(:cart, Spree::Order) }
    it { is_expected.not_to be_able_to(:read, Spree::Reimbursement) }
    it { is_expected.not_to be_able_to(:read, Spree::ReturnItem) }
    it { is_expected.not_to be_able_to(:read, Spree::Refund) }
  end
end
