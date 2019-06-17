# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Tax::OrderAdjuster do
  subject(:adjuster) { described_class.new(order) }

  describe 'initialization' do
    let(:order) { Spree::Order.new }

    it 'sets order to adjustable' do
      expect(adjuster.order).to eq(order)
    end
  end

  describe '#adjust!' do
    let(:order) { Spree::Order.new }

    let(:custom_calculator_class) { double }
    let(:custom_calculator_instance) { double }

    before do
      stub_spree_preferences(tax_calculator_class: custom_calculator_class)
    end

    it 'calls the configured tax calculator' do
      expect(custom_calculator_class).to receive(:new).with(order).at_least(:once).and_return(custom_calculator_instance)
      expect(custom_calculator_instance).to receive(:calculate).at_least(:once).and_return(
        Spree::Tax::OrderTax.new(order_id: order.id, line_item_taxes: [], shipment_taxes: [])
      )

      adjuster.adjust!
    end
  end
end
