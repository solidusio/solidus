# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/adjustment_factory'

RSpec.describe 'adjustment factory' do
  let(:factory_class) { Spree::Adjustment }

  describe 'plain adjustment' do
    let(:factory) { :adjustment }

    it_behaves_like 'a working factory'
  end

  describe 'tax adjustment' do
    let(:factory) { :tax_adjustment }

    it_behaves_like 'a working factory'
  end
end
