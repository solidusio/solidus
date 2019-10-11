# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::PermissionSets::OrderManagement do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:manage, Solidus::Order) }
    it { is_expected.to be_able_to(:manage, Solidus::Payment) }
    it { is_expected.to be_able_to(:manage, Solidus::Shipment) }
    it { is_expected.to be_able_to(:manage, Solidus::Adjustment) }
    it { is_expected.to be_able_to(:manage, Solidus::LineItem) }
    it { is_expected.to be_able_to(:manage, Solidus::ReturnAuthorization) }
    it { is_expected.to be_able_to(:manage, Solidus::CustomerReturn) }
    it { is_expected.to be_able_to(:display, Solidus::ReimbursementType) }
    it { is_expected.to be_able_to(:manage, Solidus::OrderCancellations) }
    it { is_expected.to be_able_to(:manage, Solidus::Reimbursement) }
    it { is_expected.to be_able_to(:manage, Solidus::ReturnItem) }
    it { is_expected.to be_able_to(:manage, Solidus::Refund) }
  end

  context "when not activated" do
    it { is_expected.not_to be_able_to(:manage, Solidus::Order) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Payment) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Shipment) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Adjustment) }
    it { is_expected.not_to be_able_to(:manage, Solidus::LineItem) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ReturnAuthorization) }
    it { is_expected.not_to be_able_to(:manage, Solidus::CustomerReturn) }
    it { is_expected.not_to be_able_to(:display, Solidus::ReimbursementType) }
    it { is_expected.not_to be_able_to(:manage, Solidus::OrderCancellations) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Reimbursement) }
    it { is_expected.not_to be_able_to(:manage, Solidus::ReturnItem) }
    it { is_expected.not_to be_able_to(:manage, Solidus::Refund) }
  end
end
