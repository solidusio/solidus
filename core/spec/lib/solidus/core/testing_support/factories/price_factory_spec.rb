# frozen_string_literal: true

require 'rails_helper'
require 'solidus/testing_support/factories/price_factory'

RSpec.describe 'price factory' do
  let(:factory_class) { Solidus::Price }

  describe 'plain price' do
    let(:factory) { :price }

    it_behaves_like 'a working factory'
  end
end
