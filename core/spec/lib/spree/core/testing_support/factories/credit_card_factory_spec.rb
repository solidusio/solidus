# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/credit_card_factory'

RSpec.describe 'credit card factory' do
  let(:factory_class) { Spree::CreditCard }

  describe 'plain credit card' do
    let(:factory) { :credit_card }

    it_behaves_like 'a working factory'
  end
end
