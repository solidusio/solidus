# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tax category factory' do
  let(:factory_class) { Spree::TaxCategory }

  describe 'tax category' do
    let(:factory) { :tax_category }

    it_behaves_like 'a working factory'
  end
end
