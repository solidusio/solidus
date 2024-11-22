# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ItemTotalUpdater do
  describe ".recalculate" do
    subject { described_class.recalculate(item) }

    let(:item) { create :line_item, adjustments: [adjustment] }
    let(:adjustment) { create :adjustment, amount: 1}

    it "sets the adjustment total on the item" do
      expect { subject }
        .to change { item.adjustment_total }
        .from(0).to(1)
    end
  end
end
