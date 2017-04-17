require 'spec_helper'

describe Spree::CheckoutHelper, type: :helper do
  include Spree::CheckoutHelper

  context '#checkout_progress' do
    before do
      @order = create(:order, state: 'address')
    end

    it 'does not include numbers by default' do
      output = checkout_progress
      expect(output).to_not include('1.')
    end

    it 'has an option to include numbers' do
      output = checkout_progress(numbers: true)
      expect(output).to include('1.')
    end
  end
end
