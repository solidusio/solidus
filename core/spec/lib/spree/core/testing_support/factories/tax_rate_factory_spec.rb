# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/tax_rate_factory'

RSpec.describe 'tax rate factory' do
  let(:factory_class) { Spree::TaxRate }

  describe 'tax rate' do
    let(:factory) { :tax_rate }

    it_behaves_like 'a working factory'
  end
end
