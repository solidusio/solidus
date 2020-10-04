# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ReturnItem::EligibilityValidator::TimeSincePurchase, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:return_item) { instance_double(Spree::ReturnItem) }
  let(:validator) { described_class.new(return_item) }

  describe "#eligible_for_return?" do
    subject { validator.eligible_for_return? }

    let(:interval) { Spree::Config[:return_eligibility_number_of_days] }

    before do
      allow(return_item).
        to receive_message_chain('inventory_unit.order.completed_at').
        and_return(completed_at)
    end

    around(:each) do |e|
      travel_to(Time.current) { e.run }
    end

    context "it is within the return timeframe" do
      let(:completed_at) { 1.day.ago }
      it { is_expected.to be_truthy }
    end

    context "it is past the return timeframe" do
      let(:completed_at) { interval.day.ago }

      it { is_expected.to be_falsy }

      it "sets an error" do
        subject
        expect(validator.errors[:number_of_days]).to eq I18n.t('spree.return_item_time_period_ineligible')
      end
    end
  end
end
