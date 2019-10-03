# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::OrderDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:display, Solidus::Order) }
    it { is_expected.to be_able_to(:display, Solidus::Payment) }
    it { is_expected.to be_able_to(:display, Solidus::Shipment) }
    it { is_expected.to be_able_to(:display, Solidus::Adjustment) }
    it { is_expected.to be_able_to(:display, Solidus::LineItem) }
    it { is_expected.to be_able_to(:display, Solidus::ReturnAuthorization) }
    it { is_expected.to be_able_to(:display, Solidus::CustomerReturn) }
    it { is_expected.to be_able_to(:admin, Solidus::Order) }
    it { is_expected.to be_able_to(:admin, Solidus::Payment) }
    it { is_expected.to be_able_to(:admin, Solidus::Shipment) }
    it { is_expected.to be_able_to(:admin, Solidus::Adjustment) }
    it { is_expected.to be_able_to(:admin, Solidus::LineItem) }
    it { is_expected.to be_able_to(:admin, Solidus::ReturnAuthorization) }
    it { is_expected.to be_able_to(:admin, Solidus::CustomerReturn) }
    it { is_expected.to be_able_to(:edit, Solidus::Order) }
    it { is_expected.to be_able_to(:cart, Solidus::Order) }
    it { is_expected.to be_able_to(:display, Solidus::Reimbursement) }
    it { is_expected.to be_able_to(:display, Solidus::ReturnItem) }
    it { is_expected.to be_able_to(:display, Solidus::Refund) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:display, Solidus::Order) }
    it { is_expected.not_to be_able_to(:display, Solidus::Payment) }
    it { is_expected.not_to be_able_to(:display, Solidus::Shipment) }
    it { is_expected.not_to be_able_to(:display, Solidus::Adjustment) }
    it { is_expected.not_to be_able_to(:display, Solidus::LineItem) }
    it { is_expected.not_to be_able_to(:display, Solidus::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:display, Solidus::CustomerReturn) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Order) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Payment) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Shipment) }
    it { is_expected.not_to be_able_to(:admin, Solidus::Adjustment) }
    it { is_expected.not_to be_able_to(:admin, Solidus::LineItem) }
    it { is_expected.not_to be_able_to(:admin, Solidus::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:admin, Solidus::CustomerReturn) }
    it { is_expected.not_to be_able_to(:cart, Solidus::Order) }
    it { is_expected.not_to be_able_to(:display, Solidus::Reimbursement) }
    it { is_expected.not_to be_able_to(:display, Solidus::ReturnItem) }
    it { is_expected.not_to be_able_to(:display, Solidus::Refund) }
  end
end
