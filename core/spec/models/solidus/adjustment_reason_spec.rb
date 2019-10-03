# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::AdjustmentReason do
  describe 'creation' do
    it 'is successful' do
      create(:adjustment_reason)
    end
  end
end
