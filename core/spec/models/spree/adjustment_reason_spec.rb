require 'spec_helper'

describe Spree::AdjustmentReason do

  describe 'creation' do
    it 'is successful' do
      expect {
        create(:adjustment_reason)
      }.to_not raise_error
    end
  end

end
