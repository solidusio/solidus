# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::ItemTotal do
  describe "#recalculate!" do
    subject { described_class.new(item).recalculate! }

    let(:item) { create :line_item, adjustments: [adjustment] }
    let(:adjustment) { create :adjustment, amount: 19.99 }

    it "sets the adjustment total on the item" do
      expect { subject }
        .to change { item.adjustment_total }
        .from(0).to(19.99)
    end

    it "does not factor in included adjustments" do
      adjustment.update!(included: true)
      expect { subject }.not_to change { item.adjustment_total }.from(0)
    end
  end
end
