# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tax rate factory' do
  let(:factory_class) { Spree::TaxRate }

  describe 'tax rate' do
    let(:factory) { :tax_rate }

    it_behaves_like 'a working factory'
  end
end
