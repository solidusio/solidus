# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::UnitCancel::OrderCancellationsRecalculator do
  let(:inventory_unit) { create(:inventory_unit, line_item: line_item) }
  let(:line_item) { create(:line_item) }
  let(:unit_cancel) { Spree::UnitCancel.create!(inventory_unit: inventory_unit, reason: Spree::UnitCancel::SHORT_SHIP) }
  let(:cancellation) { unit_cancel.adjust! }

  before do
    cancellation.update_columns(amount: 10, finalized: false)
    cancellation.reload
    line_item.reload
  end

  subject { described_class.new(line_item.order).call }

  it "recalculates the cancellation adjustment to the correct amount" do
    expect { subject }.to change { cancellation.reload.amount }.from(10).to(-20)
  end
end
