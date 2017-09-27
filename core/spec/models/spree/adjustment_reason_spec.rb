require 'db_helper'
require 'spree/adjustment_reason'
require 'spree/testing_support/factories/adjustment_reason_factory'

RSpec.describe Spree::AdjustmentReason do
  describe 'creation' do
    it 'is successful' do
      create(:adjustment_reason)
    end
  end
end
