# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/payment_method_factory'

RSpec.describe 'payment method factory' do
  let(:factory_class) { Spree::PaymentMethod }

  describe 'plain payment method' do
    let(:factory) { :payment_method }

    it_behaves_like 'a working factory'
  end

  describe 'check payment method' do
    let(:factory) { :check_payment_method }

    it_behaves_like 'a working factory'
  end

  describe 'store credit payment method' do
    let(:factory) { :store_credit_payment_method }

    it_behaves_like 'a working factory'
  end

  describe 'simple credit card payment method' do
    let(:factory) { :simple_credit_card_payment_method }

    it_behaves_like 'a working factory'
  end
end
