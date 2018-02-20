# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/store_credit_type_factory'

RSpec.describe 'store credit type factory' do
  let(:factory_class) { Spree::StoreCreditType }

  describe 'primary credit type' do
    let(:factory) { :primary_credit_type }

    it_behaves_like 'a working factory'
  end

  describe 'secondary credit type' do
    let(:factory) { :secondary_credit_type }

    it_behaves_like 'a working factory'
  end
end
