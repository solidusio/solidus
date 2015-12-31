require 'spec_helper'

describe Solidus::AdjustmentReason do

  describe 'creation' do
    it 'is successful' do
      create(:adjustment_reason)
    end
  end

end
