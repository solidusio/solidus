require 'spec_helper'

describe Spree::AdjustmentReason do
  describe 'creation' do
    it 'is successful' do
      create(:adjustment_reason)
    end
  end
end
