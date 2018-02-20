# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PermissionSets::OrderDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Spree::Order) }
    it { is_expected.to be_able_to(:display, Spree::Payment) }
    it { is_expected.to be_able_to(:display, Spree::Shipment) }
    it { is_expected.to be_able_to(:display, Spree::Adjustment) }
    it { is_expected.to be_able_to(:display, Spree::LineItem) }
    it { is_expected.to be_able_to(:display, Spree::ReturnAuthorization) }
    it { is_expected.to be_able_to(:display, Spree::CustomerReturn) }
    it { is_expected.to be_able_to(:admin, Spree::Order) }
    it { is_expected.to be_able_to(:admin, Spree::Payment) }
    it { is_expected.to be_able_to(:admin, Spree::Shipment) }
    it { is_expected.to be_able_to(:admin, Spree::Adjustment) }
    it { is_expected.to be_able_to(:admin, Spree::LineItem) }
    it { is_expected.to be_able_to(:admin, Spree::ReturnAuthorization) }
    it { is_expected.to be_able_to(:admin, Spree::CustomerReturn) }
    it { is_expected.to be_able_to(:edit, Spree::Order) }
    it { is_expected.to be_able_to(:cart, Spree::Order) }
    it { is_expected.to be_able_to(:display, Spree::Reimbursement) }
    it { is_expected.to be_able_to(:display, Spree::ReturnItem) }
    it { is_expected.to be_able_to(:display, Spree::Refund) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Spree::Order) }
    it { is_expected.not_to be_able_to(:display, Spree::Payment) }
    it { is_expected.not_to be_able_to(:display, Spree::Shipment) }
    it { is_expected.not_to be_able_to(:display, Spree::Adjustment) }
    it { is_expected.not_to be_able_to(:display, Spree::LineItem) }
    it { is_expected.not_to be_able_to(:display, Spree::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:display, Spree::CustomerReturn) }
    it { is_expected.not_to be_able_to(:admin, Spree::Order) }
    it { is_expected.not_to be_able_to(:admin, Spree::Payment) }
    it { is_expected.not_to be_able_to(:admin, Spree::Shipment) }
    it { is_expected.not_to be_able_to(:admin, Spree::Adjustment) }
    it { is_expected.not_to be_able_to(:admin, Spree::LineItem) }
    it { is_expected.not_to be_able_to(:admin, Spree::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:admin, Spree::CustomerReturn) }
    it { is_expected.not_to be_able_to(:cart, Spree::Order) }
    it { is_expected.not_to be_able_to(:display, Spree::Reimbursement) }
    it { is_expected.not_to be_able_to(:display, Spree::ReturnItem) }
    it { is_expected.not_to be_able_to(:display, Spree::Refund) }
  end
end
