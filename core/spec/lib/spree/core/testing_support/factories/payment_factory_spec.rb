# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/payment_factory'

RSpec.describe 'payment factory' do
  let(:factory_class) { Spree::Payment }

  describe 'plain (credit card) payment' do
    let(:factory) { :payment }

    it_behaves_like 'a working factory'

    it "assigns the Order's user to the created Credit Card" do
      payment = create(factory)
      expect(payment.source.user).to be_present
      expect(payment.source.user).to eq payment.order.user
    end

    it 'uses the orders bill address for the credit card' do
      address = create(:address)
      order = create(:order, bill_address: address)
      payment = create(factory, order: order)

      expect(payment.source.address).to eq address
    end
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
