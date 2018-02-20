# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/tax_category_factory'

RSpec.describe 'tax category factory' do
  let(:factory_class) { Spree::TaxCategory }

  describe 'tax category' do
    let(:factory) { :tax_category }

    it_behaves_like 'a working factory'
  end
end
