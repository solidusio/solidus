# frozen_string_literal: true

require 'rails_helper'
require 'solidus/testing_support/factories/adjustment_reason_factory'

RSpec.describe 'adjustment reason factory' do
  let(:factory_class) { Solidus::AdjustmentReason }

  describe 'adjustment reason' do
    let(:factory) { :adjustment_reason }

    it_behaves_like 'a working factory'
  end
end
