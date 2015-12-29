require 'spec_helper'
require 'spree/testing_support/factories/payment_factory'

RSpec.describe 'payment factory' do
  let(:factory_class) { Spree::Payment }

  describe 'plain (credit card) payment' do
    let(:factory) { :payment }

    it_behaves_like 'a working factory'
  end

  describe 'check payment' do
    let(:factory) { :check_payment }

    it_behaves_like 'a working factory'
  end

  describe 'store credit payment' do
    let(:factory) { :store_credit_payment }

    it_behaves_like 'a working factory'
  end
end
