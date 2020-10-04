# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/property_factory'

RSpec.describe 'property factory' do
  let(:factory_class) { Spree::Property }

  describe 'plain property' do
    let(:factory) { :property }

    it_behaves_like 'a working factory'
  end
end
